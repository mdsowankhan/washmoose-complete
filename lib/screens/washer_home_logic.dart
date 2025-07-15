import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../services/washer_service.dart';
import '../services/washer_connection_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:url_launcher/url_launcher.dart';

mixin WasherHomeLogic<T extends StatefulWidget> on State<T> {
  // Access to the main widget properties and state
  WasherService get washerService;
  List<Map<String, dynamic>> get availableBookings;
  List<Map<String, dynamic>> get myBookings;
  List<Map<String, dynamic>> get marketplaceBookings;
  Map<String, dynamic>? get userData;
  Map<String, dynamic>? get washerWorkload;
  bool get soundEnabled;
  bool get isExpertMoose;
  bool get isVerified;
  bool get isOnline;
  bool get canReceiveOrders;
  bool get isLoadingUser;
  Function(int)? get onNavigateToTab;

  final WasherConnectionService _connectionService = WasherConnectionService();

  // Additional getters for loading states
  bool get isLoadingAvailable;
  bool get isLoadingMyBookings;
  bool get isLoadingMarketplace;

  // Setters for state updates (abstract - implemented in main class)
  set availableBookings(List<Map<String, dynamic>> value);
  set myBookings(List<Map<String, dynamic>> value);
  set marketplaceBookings(List<Map<String, dynamic>> value);
  set userData(Map<String, dynamic>? value);
  set washerWorkload(Map<String, dynamic>? value);
  set isLoadingAvailable(bool value);
  set isLoadingMyBookings(bool value);
  set isLoadingMarketplace(bool value);
  set isLoadingWorkload(bool value);
  set isLoadingUser(bool value);
  set availableError(String? value);
  set myBookingsError(String? value);
  set marketplaceError(String? value);
  set indexError(bool value);

  void initializeConnectionService() {
    _connectionService.startConnectionMonitoring();
  }

  void disposeConnectionService() {
    _connectionService.dispose();
  }

  // Generate clean order number
  String generateOrderNumber(String bookingId) {
    final cleanId = bookingId.length > 6 ? bookingId.substring(bookingId.length - 6) : bookingId;
    return 'WM${cleanId.toUpperCase()}';
  }

  // Calculate correct washer earnings
  double calculateWasherEarnings(double totalPrice) {
    if (isExpertMoose) {
      return totalPrice * 0.90; // Expert gets 90%, platform gets 10%
    } else {
      return totalPrice * 0.85; // Everyday gets 85%, platform gets 15%
    }
  }

  // Play notification sound
  Future<void> playNotificationSound() async {
    if (soundEnabled) {
      try {
        // Use haptic feedback instead of sound for now
        HapticFeedback.mediumImpact();
        HapticFeedback.lightImpact();
      } catch (e) {
        print('Error playing haptic: $e');
      }
    }
  }

  // Load washer workload information
  Future<void> loadWasherWorkload() async {
    if (!mounted) return;

    setState(() {
      isLoadingWorkload = true;
    });

    try {
      final workload = await washerService.getWasherStatusSummary();
      if (mounted) {
        setState(() {
          washerWorkload = workload;
          isLoadingWorkload = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          washerWorkload = null;
          isLoadingWorkload = false;
        });
      }
    }
  }

  Future<void> getCurrentUserData() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final doc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
      if (mounted) {
        setState(() {
          userData = doc.data();
          isLoadingUser = false;
        });
      }
    } else {
      if (mounted) {
        setState(() {
          userData = null;
          isLoadingUser = false;
        });
      }
    }
  }

  Future<void> goOnline() async {
    if (!isVerified) {
      showVerificationRequiredDialog();
      return;
    }

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        await _connectionService.startWorkSession();

        setState(() {
          if (userData != null) {
            userData!['isOnline'] = true;
          }
        });

        if (mounted) {
          playNotificationSound();
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Row(
                children: [
                  Icon(Icons.radio_button_checked, color: Colors.white),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text('🟢 You are now ONLINE! 8-hour work session started.'),
                  ),
                ],
              ),
              backgroundColor: Colors.green,
              duration: Duration(seconds: 4),
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to go online: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> goOffline() async {
    try {
      await _connectionService.endWorkSession();

      setState(() {
        if (userData != null) {
          userData!['isOnline'] = false;
        }
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Row(
              children: [
                Icon(Icons.radio_button_off, color: Colors.white),
                SizedBox(width: 8),
                Text('🟡 You are now OFFLINE - Session timer reset'),
              ],
            ),
            backgroundColor: Colors.orange,
            duration: Duration(seconds: 3),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to go offline: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  String getSessionTimeRemaining() {
    final remaining = _connectionService.getRemainingSessionTime();
    if (remaining == null) return '';
    
    final hours = remaining.inHours;
    final minutes = remaining.inMinutes % 60;
    
    if (hours > 0) {
      return '${hours}h ${minutes}m remaining';
    } else if (minutes > 0) {
      return '${minutes}m remaining';
    } else {
      return 'Session expired';
    }
  }

  bool isSessionExpiringSoon() {
    return _connectionService.isSessionExpiringSoon();
  }

  // Navigate to Profile Function
  void navigateToProfile() {
    if (onNavigateToTab != null) {
      onNavigateToTab!(4);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please go to Profile tab to upload documents'),
          backgroundColor: Colors.amber,
        ),
      );
    }
  }

  // Verification Required Dialog
  void showVerificationRequiredDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.grey[850],
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Row(
            children: [
              Icon(Icons.verified_user, color: Colors.amber, size: 28),
              SizedBox(width: 12),
              Text(
                'Verification Required',
                style: TextStyle(color: Colors.white, fontSize: 18),
              ),
            ],
          ),
          content: const Text(
            'You need to upload and verify your documents before you can go online and start receiving orders.',
            style: TextStyle(color: Colors.white70, fontSize: 16),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
            ),
            ElevatedButton.icon(
              onPressed: () {
                Navigator.pop(context);
                navigateToProfile();
              },
              icon: const Icon(Icons.upload_file),
              label: const Text('Upload Documents'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.amber,
                foregroundColor: Colors.black,
              ),
            ),
          ],
        );
      },
    );
  }

  // ✅ FIXED: Check for scheduling conflicts with strict enforcement
  Future<Map<String, dynamic>> checkSchedulingConflicts(String bookingId) async {
    try {
      // Get the booking details from available bookings
      Map<String, dynamic>? targetBooking;
      for (final booking in availableBookings) {
        if (booking['id'] == bookingId) {
          targetBooking = booking;
          break;
        }
      }
      
      if (targetBooking == null) {
        return {
          'hasConflict': false,
          'canAccept': true,
          'message': 'Booking details not found'
        };
      }
      
      final isTargetASAP = targetBooking['isASAP'] ?? false;
      final targetDate = targetBooking['date'] ?? '';
      final targetTime = targetBooking['time'] ?? '';
      final targetDuration = targetBooking['duration'] ?? 60;
      
      // Check existing confirmed bookings for conflicts
      final confirmedBookings = myBookings.where((booking) {
        final status = booking['status']?.toString().toLowerCase() ?? '';
        return status == 'confirmed' || status == 'in_progress';
      }).toList();
      
      List<String> conflicts = [];
      final now = DateTime.now();
      
      for (final existingBooking in confirmedBookings) {
        final existingIsASAP = existingBooking['isASAP'] ?? false;
        final existingDate = existingBooking['date'] ?? '';
        final existingTime = existingBooking['time'] ?? '';
        final existingDuration = existingBooking['duration'] ?? 60;
        final customerName = existingBooking['customerName'] ?? 'Customer';
        
        // RULE 1: ASAP vs ASAP - STRICTLY FORBIDDEN (Hard Block)
        if (isTargetASAP && existingIsASAP) {
          conflicts.add('❌ BLOCKED: You already have an active ASAP order for $customerName. Complete it first.');
          return {
            'hasConflict': true,
            'canAccept': false, // Hard block - no bypass allowed
            'conflicts': conflicts,
            'message': 'ASAP conflict - cannot accept multiple ASAP orders'
          };
        }
        
        // RULE 2: Calculate actual time blocks with 30-min travel buffer
        DateTime existingStartTime;
        DateTime existingEndTime;
        
        if (existingIsASAP) {
          // ASAP job: starts now, ends at job completion + 30min travel
          existingStartTime = now;
          existingEndTime = now.add(Duration(minutes: existingDuration + 30));
        } else {
          // Scheduled job: use actual scheduled time + 30min travel
          existingStartTime = _parseScheduledDateTime(existingDate, existingTime);
          existingEndTime = existingStartTime.add(Duration(minutes: existingDuration + 30));
        }
        
        DateTime targetStartTime;
        DateTime targetEndTime;
        
        if (isTargetASAP) {
          // Target ASAP: starts now, ends at completion + 30min travel
          targetStartTime = now;
          targetEndTime = now.add(Duration(minutes: targetDuration + 30));
        } else {
          // Target scheduled: use actual scheduled time + 30min travel
          targetStartTime = _parseScheduledDateTime(targetDate, targetTime);
          targetEndTime = targetStartTime.add(Duration(minutes: targetDuration + 30));
        }
        
        // RULE 3: Check for time overlap (Hard Block)
        if (targetStartTime.isBefore(existingEndTime) && targetEndTime.isAfter(existingStartTime)) {
          final existingTimeStr = existingIsASAP 
              ? 'now (ASAP)' 
              : _formatDateTime(existingStartTime);
          final targetTimeStr = isTargetASAP 
              ? 'now (ASAP)' 
              : _formatDateTime(targetStartTime);
          final availableAfter = _formatDateTime(existingEndTime);
          
          conflicts.add('❌ BLOCKED: Time conflict detected. Existing job ($existingTimeStr) for $customerName conflicts with new job ($targetTimeStr). Available after $availableAfter.');
          
          return {
            'hasConflict': true,
            'canAccept': false, // Hard block - no bypass allowed
            'conflicts': conflicts,
            'message': 'Time conflict - jobs overlap'
          };
        }
      }
      
      return {
        'hasConflict': false,
        'canAccept': true,
        'conflicts': [],
        'message': 'No conflicts detected'
      };
      
    } catch (e) {
      print('Error checking conflicts: $e');
      return {
        'hasConflict': false,
        'canAccept': true,
        'message': 'Error checking conflicts: $e'
      };
    }
  }

  // ✅ FIXED: Parse date and time strings to DateTime with improved parsing
  DateTime _parseScheduledDateTime(String date, String time) {
    try {
      final now = DateTime.now();
      
      // Handle "today" and "tomorrow"
      DateTime baseDate;
      if (date.toLowerCase().contains('today')) {
        baseDate = DateTime(now.year, now.month, now.day);
      } else if (date.toLowerCase().contains('tomorrow')) {
        final tomorrow = now.add(const Duration(days: 1));
        baseDate = DateTime(tomorrow.year, tomorrow.month, tomorrow.day);
      } else {
        // Try to parse date formats like "May 25, 2025" or "25/05/2025"
        try {
          if (date.contains(',')) {
            // Format: "May 25, 2025"
            final parts = date.split(' ');
            if (parts.length >= 3) {
              final month = _getMonthFromName(parts[0]);
              final day = int.parse(parts[1].replaceAll(',', ''));
              final year = int.parse(parts[2]);
              baseDate = DateTime(year, month, day);
            } else {
              baseDate = DateTime(now.year, now.month, now.day);
            }
          } else if (date.contains('/')) {
            // Format: "25/05/2025"
            final parts = date.split('/');
            if (parts.length >= 3) {
              final day = int.parse(parts[0]);
              final month = int.parse(parts[1]);
              final year = int.parse(parts[2]);
              baseDate = DateTime(year, month, day);
            } else {
              baseDate = DateTime(now.year, now.month, now.day);
            }
          } else {
            baseDate = DateTime(now.year, now.month, now.day); // Fallback to today
          }
        } catch (e) {
          print('Date parsing error: $e');
          baseDate = DateTime(now.year, now.month, now.day); // Fallback to today
        }
      }
      
      // Parse time like "2:00 PM", "14:00", "10:00 AM"
      int hour = 12; // Default to noon instead of 9am
      int minute = 0;
      
      final timeClean = time.toLowerCase().trim();
      
      if (timeClean.contains('pm') || timeClean.contains('am')) {
        final isPM = timeClean.contains('pm');
        final timeOnly = timeClean.replaceAll(RegExp(r'[^\d:]'), '');
        final parts = timeOnly.split(':');
        
        if (parts.isNotEmpty) {
          hour = int.tryParse(parts[0]) ?? 12;
          if (parts.length > 1) {
            minute = int.tryParse(parts[1]) ?? 0;
          }
          
          // Convert to 24-hour format
          if (isPM && hour != 12) {
            hour += 12;
          } else if (!isPM && hour == 12) {
            hour = 0;
          }
        }
      } else {
        // 24-hour format like "14:00"
        final parts = timeClean.split(':');
        if (parts.isNotEmpty) {
          hour = int.tryParse(parts[0]) ?? 12;
          if (parts.length > 1) {
            minute = int.tryParse(parts[1]) ?? 0;
          }
        }
      }
      
      final result = DateTime(baseDate.year, baseDate.month, baseDate.day, hour, minute);
      print('🕐 Parsed time: "$date $time" -> ${_formatDateTime(result)}');
      return result;
      
    } catch (e) {
      print('Error parsing date/time: $date $time - $e');
      // Fallback to current time + 2 hours
      return DateTime.now().add(const Duration(hours: 2));
    }
  }

  // Helper method to get month number from name
  int _getMonthFromName(String monthName) {
    final months = {
      'jan': 1, 'january': 1,
      'feb': 2, 'february': 2,
      'mar': 3, 'march': 3,
      'apr': 4, 'april': 4,
      'may': 5,
      'jun': 6, 'june': 6,
      'jul': 7, 'july': 7,
      'aug': 8, 'august': 8,
      'sep': 9, 'september': 9,
      'oct': 10, 'october': 10,
      'nov': 11, 'november': 11,
      'dec': 12, 'december': 12,
    };
    
    return months[monthName.toLowerCase()] ?? DateTime.now().month;
  }

  // Format DateTime for display
  String _formatDateTime(DateTime dateTime) {
    final hour = dateTime.hour;
    final minute = dateTime.minute.toString().padLeft(2, '0');
    final period = hour >= 12 ? 'PM' : 'AM';
    final displayHour = hour > 12 ? hour - 12 : (hour == 0 ? 12 : hour);
    
    return '$displayHour:$minute $period';
  }

  // ✅ FIXED: Show conflict warning dialog - NO BYPASS ALLOWED, CLEAN CODE
  void showConflictWarningDialog(List<String> conflicts, String bookingId, VoidCallback onProceed) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.grey[900],
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Row(
          children: [
            Icon(Icons.block, color: Colors.red, size: 24),
            SizedBox(width: 8),
            Text(
              'Cannot Accept Order',
              style: TextStyle(color: Colors.white, fontSize: 18),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'This order cannot be accepted due to scheduling conflicts:',
              style: TextStyle(color: Colors.grey, fontSize: 14),
            ),
            const SizedBox(height: 12),
            ...conflicts.map((conflict) => Padding(
              padding: const EdgeInsets.only(bottom: 8.0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.block, color: Colors.red, size: 16),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      conflict,
                      style: const TextStyle(color: Colors.white, fontSize: 14),
                    ),
                  ),
                ],
              ),
            )),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.red.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.red.withOpacity(0.3)),
              ),
              child: const Row(
                children: [
                  Icon(Icons.info_outline, color: Colors.red, size: 20),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Complete your current jobs or wait for the scheduled time to pass before accepting new orders.',
                      style: TextStyle(
                        color: Colors.red,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.grey[700],
              foregroundColor: Colors.white,
            ),
            child: const Text('Understood'),
          ),
        ],
      ),
    );
  }

  // Load available bookings
  void loadAvailableBookings() {
    try {
      getSimplifiedAvailableBookingsStream().listen((bookings) {
        if (mounted) {
          setState(() {
            availableBookings = bookings;
            isLoadingAvailable = false;
            indexError = false;
            availableError = null;
          });

          if (bookings.isNotEmpty && canReceiveOrders) {
            playNotificationSound();
          }
        }
      }, onError: (error) {
        if (mounted) {
          setState(() {
            if (error.toString().contains('index') || error.toString().contains('requires an index')) {
              indexError = true;
              availableError = 'Database index is being created. Please wait a few minutes and refresh.';
            } else {
              availableError = 'Error loading available bookings: $error';
            }
            isLoadingAvailable = false;
          });
        }
      });
    } catch (e) {
      if (mounted) {
        setState(() {
          availableError = 'Error loading available bookings: $e';
          isLoadingAvailable = false;
        });
      }
    }

    Future.delayed(const Duration(seconds: 5), () {
      if (mounted && isLoadingAvailable) {
        setState(() {
          availableBookings = getMockAvailableBookings();
          isLoadingAvailable = false;
          availableError = null;
        });
      }
    });
  }

  Stream<List<Map<String, dynamic>>> getSimplifiedAvailableBookingsStream() {
    return FirebaseFirestore.instance
        .collection('bookings')
        .where('washerId', isNull: true)
        .where('status', isEqualTo: 'pending')
        .orderBy('createdAt', descending: true)
        .limit(20)
        .snapshots()
        .map((snapshot) {
      final now = DateTime.now();
      return snapshot.docs
          .map((doc) {
            final data = doc.data();
            return {'id': doc.id, ...data};
          })
          .where((booking) {
            // ✅ FIXED: Proper expiry check with 30-minute limit
            final createdAt = booking['createdAt'] as Timestamp?;
            
            if (createdAt != null) {
              final createdTime = createdAt.toDate();
              final expiryTime = createdTime.add(const Duration(minutes: 30)); // 30 minutes expiry
              
              // If job has expired, don't show it
              if (now.isAfter(expiryTime)) {
                print('🕐 Job ${booking['id']} expired: created at ${createdTime}, expired at ${expiryTime}');
                return false;
              }
            }
            
            // Additional expiry check for explicit expiry timestamp
            final expiryTimestamp = booking['expiryTimestamp'] as Timestamp?;
            if (expiryTimestamp != null) {
              final expiryTime = expiryTimestamp.toDate();
              if (now.isAfter(expiryTime)) {
                print('🕐 Job ${booking['id']} expired via expiryTimestamp: ${expiryTime}');
                return false;
              }
            }
            
            final isExpired = booking['isExpired'] ?? false;
            if (isExpired) {
              print('🕐 Job ${booking['id']} marked as expired');
              return false;
            }
            
            return true;
          })
          .toList()
        ..sort((a, b) {
          final aIsASAP = a['isASAP'] ?? false;
          final bIsASAP = b['isASAP'] ?? false;

          if (aIsASAP && !bIsASAP) return -1;
          if (!aIsASAP && bIsASAP) return 1;

          final aTime = a['createdAt'] as Timestamp?;
          final bTime = b['createdAt'] as Timestamp?;

          if (aTime == null && bTime == null) return 0;
          if (aTime == null) return 1;
          if (bTime == null) return -1;

          return bTime.compareTo(aTime);
        });
    });
  }

  void loadMyBookings() {
    try {
      washerService.getWasherBookings().listen((bookings) {
        if (mounted) {
          setState(() {
            myBookings = bookings;
            isLoadingMyBookings = false;
            myBookingsError = null;
          });
        }
      }, onError: (error) {
        if (mounted) {
          setState(() {
            if (error.toString().contains('index') || error.toString().contains('requires an index')) {
              myBookingsError = 'Database index is being created. Please wait a few minutes and refresh.';
            } else {
              myBookingsError = 'Error loading your bookings: $error';
            }
            isLoadingMyBookings = false;
          });
        }
      });
    } catch (e) {
      if (mounted) {
        setState(() {
          myBookingsError = 'Error loading your bookings: $e';
          isLoadingMyBookings = false;
        });
      }
    }

    Future.delayed(const Duration(seconds: 10), () {
      if (mounted && isLoadingMyBookings) {
        setState(() {
          myBookings = [];
          isLoadingMyBookings = false;
          myBookingsError = null;
        });
      }
    });
  }

  void loadMarketplaceBookings() {
    if (!isExpertMoose) return;
    try {
      getMarketplaceBookingsStream().listen((bookings) {
        if (mounted) {
          setState(() {
            marketplaceBookings = bookings;
            isLoadingMarketplace = false;
            marketplaceError = null;
          });
        }
      }, onError: (error) {
        if (mounted) {
          setState(() {
            marketplaceError = 'Error loading marketplace bookings: $error';
            isLoadingMarketplace = false;
          });
        }
      });
    } catch (e) {
      if (mounted) {
        setState(() {
          marketplaceError = 'Error loading marketplace bookings: $e';
          isLoadingMarketplace = false;
        });
      }
    }

    Future.delayed(const Duration(seconds: 10), () {
      if (mounted && isLoadingMarketplace) {
        setState(() {
          marketplaceBookings = getMockMarketplaceBookings();
          isLoadingMarketplace = false;
          marketplaceError = null;
        });
      }
    });
  }

  Stream<List<Map<String, dynamic>>> getMarketplaceBookingsStream() {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return Stream.value([]);

    return FirebaseFirestore.instance
        .collection('bookings')
        .where('washerType', isEqualTo: 'expert_moose')
        .where('washerId', isEqualTo: user.uid)
        .where('bookingSource', isEqualTo: 'marketplace')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data();
        return {'id': doc.id, ...data};
      }).toList();
    });
  }

  List<Map<String, dynamic>> getMockAvailableBookings() {
    final now = DateTime.now();
    return [
      {
        'id': 'mock_1',
        'vehicleType': 'Sedan',
        'packageName': 'Full Inside & Out',
        'customerName': 'John Smith',
        'location': 'Sydney CBD',
        'fullAddress': '123 Pitt Street, Sydney NSW 2000',
        'date': 'Today',
        'time': '3:30 PM', // ✅ FIXED: Realistic time instead of defaulting to 9am
        'totalPrice': 45.0,
        'duration': 60,
        'addOns': ['Pet Hair Removal'],
        'status': 'pending',
        'isASAP': false,
        'customerPhone': '+61 412 345 678',
        'specialInstructions': 'Please park in visitor spot 12',
        'createdAt': Timestamp.fromDate(now.subtract(const Duration(minutes: 10))), // 10 mins ago
      },
      {
        'id': 'mock_2',
        'vehicleType': 'SUV (5-Seater)',
        'packageName': isExpertMoose ? 'Premium Detail' : 'Interior Only',
        'customerName': 'Sarah Wilson',
        'location': 'Bondi Beach',
        'fullAddress': '456 Campbell Parade, Bondi Beach NSW 2026',
        'date': 'Today',
        'time': 'ASAP', // ✅ FIXED: ASAP orders show "ASAP" instead of confusing times
        'totalPrice': isExpertMoose ? 120.0 : 30.0,
        'duration': isExpertMoose ? 120 : 45,
        'addOns': [],
        'status': 'pending',
        'isASAP': true,
        'customerPhone': '+61 423 456 789',
        'specialInstructions': 'Urgent - need car ready for important meeting',
        'createdAt': Timestamp.fromDate(now.subtract(const Duration(minutes: 5))), // 5 mins ago
        'expiryTimestamp': Timestamp.fromDate(now.add(const Duration(minutes: 25))), // Expires in 25 mins
      }
    ];
  }

  List<Map<String, dynamic>> getMockMarketplaceBookings() {
    return [
      {
        'id': 'marketplace_1',
        'vehicleType': 'Large SUV',
        'packageName': 'Premium Detail Service',
        'customerName': 'Alex Thompson',
        'location': 'Chatswood',
        'fullAddress': '789 Victoria Avenue, Chatswood NSW 2067',
        'date': 'June 30, 2025',
        'time': '11:00 AM', // ✅ FIXED: Realistic time
        'totalPrice': 180.0,
        'duration': 150,
        'status': 'confirmed',
        'bookingSource': 'marketplace',
        'isASAP': false,
        'customerPhone': '+61 434 567 890',
        'customRequests': 'Please focus on interior leather seats - they need deep cleaning',
      },
    ];
  }

  Future<void> retryLoading() async {
    setState(() {
      isLoadingAvailable = true;
      isLoadingMyBookings = true;
      if (isExpertMoose) isLoadingMarketplace = true;
      availableError = null;
      myBookingsError = null;
      marketplaceError = null;
      indexError = false;
    });

    await Future.delayed(const Duration(seconds: 1));
    loadAvailableBookings();
    loadMyBookings();
    if (isExpertMoose) {
      loadMarketplaceBookings();
    }
  }

  // ✅ FIXED: Accept booking with strict conflict detection - NO BYPASS ALLOWED
  Future<void> acceptBooking(String bookingId) async {
    if (bookingId.startsWith('mock_') || bookingId.startsWith('marketplace_')) {
      playNotificationSound();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Mock booking accepted! (Real functionality coming soon)')),
      );
      return;
    }

    // ✅ FIXED: Check for scheduling conflicts before accepting
    final conflictCheck = await checkSchedulingConflicts(bookingId);
    
    if (conflictCheck['hasConflict'] == true) {
      final conflicts = conflictCheck['conflicts'] as List<String>;
      
      // Show conflict dialog - NO "Accept Anyway" option anymore
      showConflictWarningDialog(conflicts, bookingId, () {
        // Empty callback - no bypass allowed
      });
      return;
    }

    // No conflicts detected, proceed normally
    await _proceedWithBookingAcceptance(bookingId);
  }

  // Actual booking acceptance logic (separated for conflict handling)
  Future<void> _proceedWithBookingAcceptance(String bookingId) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const AlertDialog(
        backgroundColor: Colors.transparent,
        elevation: 0,
        content: Center(child: CircularProgressIndicator()),
      ),
    );

    try {
      await washerService.acceptBooking(bookingId);
      if (mounted) Navigator.pop(context);

      await loadWasherWorkload();
      setState(() {
        isLoadingAvailable = true;
        isLoadingMyBookings = true;
        if (isExpertMoose) isLoadingMarketplace = true;
      });

      loadAvailableBookings();
      loadMyBookings();
      if (isExpertMoose) loadMarketplaceBookings();

      if (mounted) {
        playNotificationSound();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Row(
              children: [
                Icon(Icons.check_circle, color: Colors.white),
                SizedBox(width: 8),
                Text('Order accepted successfully! 🎉'),
              ],
            ),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          ),
        );
      }
    } catch (e) {
      if (mounted) Navigator.pop(context);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.error, color: Colors.white),
                const SizedBox(width: 8),
                Expanded(child: Text('Error: $e')),
              ],
            ),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            duration: const Duration(seconds: 4),
          ),
        );
      }
    }
  }

  Future<void> completeBooking(String bookingId) async {
    if (bookingId.startsWith('mock_') || bookingId.startsWith('marketplace_')) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Mock booking completed! (Real functionality coming soon)')),
      );
      return;
    }

    try {
      await washerService.completeBooking(bookingId);
      await loadWasherWorkload();

      setState(() {
        isLoadingMyBookings = true;
        if (isExpertMoose) isLoadingMarketplace = true;
      });

      loadMyBookings();
      if (isExpertMoose) loadMarketplaceBookings();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Booking marked as completed')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error completing booking: $e')),
      );
    }
  }

  // Cancel booking with reason
  Future<void> cancelBookingWithReason(String bookingId, String reason) async {
    try {
      await washerService.cancelBookingWithReason(bookingId, reason);
      
      // Show success message
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✅ Order cancelled successfully. Customer has been notified.'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 3),
          ),
        );
      }
      
      // Reload my bookings to refresh the list
      loadMyBookings();
      
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ Failed to cancel order: $e'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 4),
          ),
        );
      }
    }
  }

  // Call customer function
  Future<void> callCustomer(String phoneNumber) async {
    final Uri phoneUri = Uri(scheme: 'tel', path: phoneNumber);
    if (await canLaunchUrl(phoneUri)) {
      await launchUrl(phoneUri);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not open phone dialer')),
      );
    }
  }

  bool canAcceptJob(String packageName) {
    final packageLower = packageName.toLowerCase();
    if (isExpertMoose) {
      return true;
    } else {
      return !packageLower.contains('detail') &&
          !packageLower.contains('premium') &&
          !packageLower.contains('custom');
    }
  }

  Color getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return Colors.orange;
      case 'confirmed':
      case 'in_progress':
        return Colors.blue;
      case 'completed':
        return Colors.green;
      case 'cancelled':
      case 'declined':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  // Method name getters to ensure compatibility
  Future<void> _loadWasherWorkload() => loadWasherWorkload();
  Future<void> _getCurrentUserData() => getCurrentUserData();
  void _loadAvailableBookings() => loadAvailableBookings();
  void _loadMyBookings() => loadMyBookings();
  void _loadMarketplaceBookings() => loadMarketplaceBookings();
  Future<void> _goOnline() => goOnline();
  Future<void> _goOffline() => goOffline();
  void _navigateToProfile() => navigateToProfile();
  void _showVerificationRequiredDialog() => showVerificationRequiredDialog();
  Future<void> _retryLoading() => retryLoading();
  Future<void> _acceptBooking(String bookingId) => acceptBooking(bookingId);
  Future<void> _completeBooking(String bookingId) => completeBooking(bookingId);
  Future<void> _callCustomer(String phoneNumber) => callCustomer(phoneNumber);
  bool _canAcceptJob(String packageName) => canAcceptJob(packageName);
  Color _getStatusColor(String status) => getStatusColor(status);
  String _generateOrderNumber(String bookingId) => generateOrderNumber(bookingId);
  double _calculateWasherEarnings(double totalPrice) => calculateWasherEarnings(totalPrice);
  Future<void> _playNotificationSound() => playNotificationSound();
}