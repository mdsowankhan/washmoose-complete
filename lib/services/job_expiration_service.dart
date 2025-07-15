import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';

class JobExpirationService {
  static final JobExpirationService _instance = JobExpirationService._internal();
  factory JobExpirationService() => _instance;
  JobExpirationService._internal();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  Timer? _cleanupTimer;
  
  // Duration constants
  static const Duration JOB_EXPIRATION_DURATION = Duration(hours: 1);
  static const Duration CLEANUP_INTERVAL = Duration(minutes: 5); // Check every 5 minutes

  /// Initialize the job expiration service
  /// This should be called when the app starts
  void initialize() {
    // Start periodic cleanup
    _startPeriodicCleanup();
    
    // Run initial cleanup
    _cleanupExpiredJobs();
    
    print('JobExpirationService: Initialized with 1-hour expiration');
  }

  /// Stop the expiration service
  void dispose() {
    _cleanupTimer?.cancel();
    _cleanupTimer = null;
    print('JobExpirationService: Disposed');
  }

  /// Start periodic cleanup timer that runs every 5 minutes
  void _startPeriodicCleanup() {
    _cleanupTimer?.cancel();
    
    _cleanupTimer = Timer.periodic(CLEANUP_INTERVAL, (timer) {
      _cleanupExpiredJobs();
    });
  }

  /// Main cleanup method - finds and expires old jobs
  Future<void> _cleanupExpiredJobs() async {
    try {
      final now = DateTime.now();
      final expirationCutoff = now.subtract(JOB_EXPIRATION_DURATION);
      
      print('JobExpirationService: Starting cleanup at ${now.toIso8601String()}');
      
      // Find jobs that should be expired
      final QuerySnapshot expiredJobs = await _firestore
          .collection('bookings')
          .where('status', isEqualTo: 'pending')
          .where('washerId', isNull: true) // Not yet accepted
          .where('isExpired', isEqualTo: false) // Not already expired
          .where('createdAt', isLessThanOrEqualTo: Timestamp.fromDate(expirationCutoff))
          .get();

      if (expiredJobs.docs.isEmpty) {
        print('JobExpirationService: No expired jobs found');
        return;
      }

      // Batch update expired jobs
      final batch = _firestore.batch();
      int expiredCount = 0;

      for (final doc in expiredJobs.docs) {
        final data = doc.data() as Map<String, dynamic>;
        final createdAt = (data['createdAt'] as Timestamp?)?.toDate();
        
        if (createdAt != null) {
          final age = now.difference(createdAt);
          
          if (age >= JOB_EXPIRATION_DURATION) {
            // Mark as expired
            batch.update(doc.reference, {
              'isExpired': true,
              'status': 'expired',
              'expiredAt': FieldValue.serverTimestamp(),
              'updatedAt': FieldValue.serverTimestamp(),
              'expirationReason': 'No washer accepted within 1 hour',
            });
            
            expiredCount++;
            
            print('JobExpirationService: Expiring job ${doc.id} (age: ${age.inMinutes} minutes)');
          }
        }
      }

      // Commit batch update
      if (expiredCount > 0) {
        await batch.commit();
        print('JobExpirationService: Expired $expiredCount jobs');
        
        // Notify customers about expired jobs
        await _notifyCustomersOfExpiredJobs(expiredJobs.docs);
      }

    } catch (e) {
      print('JobExpirationService: Error during cleanup: $e');
    }
  }

  /// Notify customers when their jobs expire
  Future<void> _notifyCustomersOfExpiredJobs(List<QueryDocumentSnapshot> expiredJobs) async {
    try {
      final batch = _firestore.batch();
      
      for (final jobDoc in expiredJobs) {
        final data = jobDoc.data() as Map<String, dynamic>;
        final customerId = data['customerId'] as String?;
        final customerName = data['customerName'] as String?;
        final packageName = data['packageName'] as String?;
        
        if (customerId != null) {
          // Create notification for customer
          final notificationRef = _firestore.collection('notifications').doc();
          batch.set(notificationRef, {
            'userId': customerId,
            'type': 'job_expired',
            'title': 'Job Request Expired',
            'message': 'Your $packageName request expired after 1 hour. No washers were available. Please try booking again.',
            'jobId': jobDoc.id,
            'isRead': false,
            'createdAt': FieldValue.serverTimestamp(),
          });
        }
      }
      
      await batch.commit();
      print('JobExpirationService: Created notifications for ${expiredJobs.length} expired jobs');
      
    } catch (e) {
      print('JobExpirationService: Error creating notifications: $e');
    }
  }

  /// Check if a specific job is expired
  static bool isJobExpired(Map<String, dynamic> jobData) {
    // Check explicit expiration flag
    if (jobData['isExpired'] == true) {
      return true;
    }
    
    // Check age-based expiration
    final createdAt = (jobData['createdAt'] as Timestamp?)?.toDate();
    if (createdAt == null) {
      return false;
    }
    
    final age = DateTime.now().difference(createdAt);
    return age >= JOB_EXPIRATION_DURATION;
  }

  /// Get remaining time before a job expires
  static Duration? getTimeUntilExpiration(Map<String, dynamic> jobData) {
    if (jobData['isExpired'] == true) {
      return Duration.zero;
    }
    
    final createdAt = (jobData['createdAt'] as Timestamp?)?.toDate();
    if (createdAt == null) {
      return null;
    }
    
    final age = DateTime.now().difference(createdAt);
    final remaining = JOB_EXPIRATION_DURATION - age;
    
    return remaining.isNegative ? Duration.zero : remaining;
  }

  /// Format remaining time for display
  static String formatTimeRemaining(Duration timeRemaining) {
    if (timeRemaining <= Duration.zero) {
      return 'Expired';
    }
    
    final minutes = timeRemaining.inMinutes;
    final seconds = timeRemaining.inSeconds % 60;
    
    if (minutes > 0) {
      return '${minutes}m ${seconds}s remaining';
    } else {
      return '${seconds}s remaining';
    }
  }

  /// Force expire a specific job (for manual expiration)
  Future<void> expireJob(String jobId, {String? reason}) async {
    try {
      await _firestore.collection('bookings').doc(jobId).update({
        'isExpired': true,
        'status': 'expired',
        'expiredAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
        'expirationReason': reason ?? 'Manually expired',
      });
      
      print('JobExpirationService: Manually expired job $jobId');
      
    } catch (e) {
      print('JobExpirationService: Error expiring job $jobId: $e');
      throw Exception('Failed to expire job: $e');
    }
  }

  /// Get statistics about job expiration
  Future<Map<String, dynamic>> getExpirationStats() async {
    try {
      final now = DateTime.now();
      final dayStart = DateTime(now.year, now.month, now.day);
      
      // Count expired jobs today
      final expiredToday = await _firestore
          .collection('bookings')
          .where('status', isEqualTo: 'expired')
          .where('expiredAt', isGreaterThanOrEqualTo: Timestamp.fromDate(dayStart))
          .get();
      
      // Count currently pending jobs
      final pendingJobs = await _firestore
          .collection('bookings')
          .where('status', isEqualTo: 'pending')
          .where('washerId', isNull: true)
          .where('isExpired', isEqualTo: false)
          .get();
      
      // Count jobs expiring soon (within 15 minutes)
      final soonExpiring = pendingJobs.docs.where((doc) {
        final data = doc.data() as Map<String, dynamic>;
        final timeRemaining = getTimeUntilExpiration(data);
        return timeRemaining != null && timeRemaining <= Duration(minutes: 15);
      }).length;
      
      return {
        'expiredToday': expiredToday.docs.length,
        'pendingJobs': pendingJobs.docs.length,
        'expiringSoon': soonExpiring,
        'lastCleanup': now.toIso8601String(),
      };
      
    } catch (e) {
      print('JobExpirationService: Error getting stats: $e');
      return {
        'expiredToday': 0,
        'pendingJobs': 0,
        'expiringSoon': 0,
        'error': e.toString(),
      };
    }
  }

  /// Check for jobs expiring soon and notify customers
  Future<void> notifyExpiringJobs() async {
    try {
      final now = DateTime.now();
      final warningTime = now.subtract(Duration(minutes: 45)); // Warn at 15 minutes remaining
      
      final QuerySnapshot expiringSoon = await _firestore
          .collection('bookings')
          .where('status', isEqualTo: 'pending')
          .where('washerId', isNull: true)
          .where('isExpired', isEqualTo: false)
          .where('createdAt', isLessThanOrEqualTo: Timestamp.fromDate(warningTime))
          .where('expirationWarningShown', isEqualTo: false) // Don't warn twice
          .get();

      if (expiringSoon.docs.isEmpty) {
        return;
      }

      final batch = _firestore.batch();
      
      for (final jobDoc in expiringSoon.docs) {
        final data = jobDoc.data() as Map<String, dynamic>;
        final customerId = data['customerId'] as String?;
        final packageName = data['packageName'] as String?;
        
        if (customerId != null) {
          // Create warning notification
          final notificationRef = _firestore.collection('notifications').doc();
          batch.set(notificationRef, {
            'userId': customerId,
            'type': 'job_expiring_soon',
            'title': 'Job Request Expiring Soon',
            'message': 'Your $packageName request will expire in 15 minutes if no washer accepts it.',
            'jobId': jobDoc.id,
            'isRead': false,
            'createdAt': FieldValue.serverTimestamp(),
          });
          
          // Mark warning as shown
          batch.update(jobDoc.reference, {
            'expirationWarningShown': true,
            'updatedAt': FieldValue.serverTimestamp(),
          });
        }
      }
      
      await batch.commit();
      print('JobExpirationService: Sent expiration warnings for ${expiringSoon.docs.length} jobs');
      
    } catch (e) {
      print('JobExpirationService: Error sending expiration warnings: $e');
    }
  }

  /// Manual cleanup trigger (for testing or admin use)
  Future<void> runCleanupNow() async {
    print('JobExpirationService: Running manual cleanup...');
    await _cleanupExpiredJobs();
    await notifyExpiringJobs();
  }
}