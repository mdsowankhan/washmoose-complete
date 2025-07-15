// lib/services/washer_connection_service.dart
import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class WasherConnectionService {
  static final WasherConnectionService _instance = WasherConnectionService._internal();
  factory WasherConnectionService() => _instance;
  WasherConnectionService._internal();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  
  // Connection monitoring
  Timer? _connectionCheckTimer;
  Timer? _sessionTimer;
  DateTime? _sessionStartTime;
  bool _isConnectionLost = false;
  
  // Constants
  static const Duration _connectionCheckInterval = Duration(minutes: 1);
  static const Duration _connectionLostTimeout = Duration(minutes: 10);
  static const Duration _maxSessionDuration = Duration(hours: 8);

  // Initialize connection monitoring
  void startConnectionMonitoring() {
    if (kDebugMode) {
      print('🔄 Starting connection monitoring...');
    }
    
    // Start periodic connection check
    _connectionCheckTimer?.cancel();
    _connectionCheckTimer = Timer.periodic(_connectionCheckInterval, (_) {
      _checkConnection();
    });
  }

  // Stop connection monitoring
  void stopConnectionMonitoring() {
    if (kDebugMode) {
      print('🛑 Stopping connection monitoring...');
    }
    
    _connectionCheckTimer?.cancel();
    _sessionTimer?.cancel();
    _connectionCheckTimer = null;
    _sessionTimer = null;
  }

  // Start a new work session
  Future<void> startWorkSession() async {
    try {
      final user = _auth.currentUser;
      if (user == null) return;

      _sessionStartTime = DateTime.now();
      
      // Update session start time in Firebase
      await _firestore.collection('users').doc(user.uid).update({
        'sessionStartTime': FieldValue.serverTimestamp(),
        'isOnline': true,
        'lastOnlineAt': FieldValue.serverTimestamp(),
      });

      // Start 8-hour session timer
      _sessionTimer?.cancel();
      _sessionTimer = Timer(_maxSessionDuration, () {
        _autoOfflineSessionExpired();
      });

      if (kDebugMode) {
        print('✅ Work session started - 8 hour timer activated');
      }

    } catch (e) {
      if (kDebugMode) {
        print('❌ Error starting work session: $e');
      }
    }
  }

  // End work session
  Future<void> endWorkSession() async {
    try {
      final user = _auth.currentUser;
      if (user == null) return;

      // Cancel session timer
      _sessionTimer?.cancel();
      _sessionTimer = null;
      _sessionStartTime = null;

      // Update Firebase
      await _firestore.collection('users').doc(user.uid).update({
        'isOnline': false,
        'lastOfflineAt': FieldValue.serverTimestamp(),
        'sessionStartTime': null, // Reset session timer
      });

      if (kDebugMode) {
        print('✅ Work session ended - timer reset');
      }

    } catch (e) {
      if (kDebugMode) {
        print('❌ Error ending work session: $e');
      }
    }
  }

  // Check if user is online and connection is stable
  Future<void> _checkConnection() async {
    try {
      final user = _auth.currentUser;
      if (user == null) return;

      // Get current user status from Firebase
      final userDoc = await _firestore.collection('users').doc(user.uid).get();
      if (!userDoc.exists) return;

      final userData = userDoc.data() as Map<String, dynamic>;
      final isOnline = userData['isOnline'] ?? false;
      
      if (!isOnline) {
        // User is offline, no need to monitor
        return;
      }

      // Test Firebase connection by updating heartbeat
      try {
        await _firestore.collection('users').doc(user.uid).update({
          'lastHeartbeat': FieldValue.serverTimestamp(),
        });
        
        // Connection is good
        if (_isConnectionLost) {
          _isConnectionLost = false;
          if (kDebugMode) {
            print('🟢 Connection restored');
          }
        }
        
      } catch (e) {
        // Connection failed
        if (!_isConnectionLost) {
          _isConnectionLost = true;
          if (kDebugMode) {
            print('🔴 Connection lost - starting 10 minute timer');
          }
          
          // Start 10-minute timeout for auto-offline
          Timer(_connectionLostTimeout, () {
            if (_isConnectionLost) {
              _autoOfflineConnectionLost();
            }
          });
        }
      }

    } catch (e) {
      if (kDebugMode) {
        print('❌ Error checking connection: $e');
      }
    }
  }

  // Auto go offline due to connection loss
  Future<void> _autoOfflineConnectionLost() async {
    try {
      final user = _auth.currentUser;
      if (user == null) return;

      await _firestore.collection('users').doc(user.uid).update({
        'isOnline': false,
        'lastOfflineAt': FieldValue.serverTimestamp(),
        'autoOfflineReason': 'Connection lost for 10+ minutes',
      });

      _sessionTimer?.cancel();
      _sessionTimer = null;
      _sessionStartTime = null;

      if (kDebugMode) {
        print('🔴 Auto-offline: Connection lost');
      }

    } catch (e) {
      if (kDebugMode) {
        print('❌ Error in auto-offline (connection): $e');
      }
    }
  }

  // Auto go offline due to 8-hour session limit
  Future<void> _autoOfflineSessionExpired() async {
    try {
      final user = _auth.currentUser;
      if (user == null) return;

      await _firestore.collection('users').doc(user.uid).update({
        'isOnline': false,
        'lastOfflineAt': FieldValue.serverTimestamp(),
        'autoOfflineReason': '8-hour session limit reached',
        'sessionStartTime': null,
      });

      _sessionTimer?.cancel();
      _sessionTimer = null;
      _sessionStartTime = null;

      if (kDebugMode) {
        print('🕐 Auto-offline: 8-hour session limit reached');
      }

    } catch (e) {
      if (kDebugMode) {
        print('❌ Error in auto-offline (session): $e');
      }
    }
  }

  // Force offline on logout
  Future<void> forceOfflineOnLogout() async {
    try {
      final user = _auth.currentUser;
      if (user == null) return;

      await _firestore.collection('users').doc(user.uid).update({
        'isOnline': false,
        'lastOfflineAt': FieldValue.serverTimestamp(),
        'autoOfflineReason': 'User logged out',
        'sessionStartTime': null,
      });

      // Stop all monitoring
      stopConnectionMonitoring();

      if (kDebugMode) {
        print('🚪 Force offline: User logged out');
      }

    } catch (e) {
      if (kDebugMode) {
        print('❌ Error in force offline (logout): $e');
      }
    }
  }

  // Force offline on app close/minimize
  Future<void> forceOfflineOnAppClose() async {
    try {
      final user = _auth.currentUser;
      if (user == null) return;

      await _firestore.collection('users').doc(user.uid).update({
        'isOnline': false,
        'lastOfflineAt': FieldValue.serverTimestamp(),
        'autoOfflineReason': 'App closed/minimized',
        'sessionStartTime': null,
      });

      // Stop all monitoring
      stopConnectionMonitoring();

      if (kDebugMode) {
        print('📱 Force offline: App closed/minimized');
      }

    } catch (e) {
      if (kDebugMode) {
        print('❌ Error in force offline (app close): $e');
      }
    }
  }

  // Get remaining session time
  Duration? getRemainingSessionTime() {
    if (_sessionStartTime == null) return null;
    
    final elapsed = DateTime.now().difference(_sessionStartTime!);
    final remaining = _maxSessionDuration - elapsed;
    
    return remaining.isNegative ? Duration.zero : remaining;
  }

  // Check if session is about to expire (30 minutes warning)
  bool isSessionExpiringSoon() {
    final remaining = getRemainingSessionTime();
    if (remaining == null) return false;
    
    return remaining.inMinutes <= 30 && remaining.inMinutes > 0;
  }

  // Dispose all resources
  void dispose() {
    stopConnectionMonitoring();
  }
}