// washer_service.dart
import 'package:flutter/material.dart'; // ✅ ADDED: For Color class
import 'package:cloud_firestore/cloud_firestore.dart'; // ✅ ADDED: For Timestamp class
import 'package:firebase_auth/firebase_auth.dart';
import 'database_service.dart';
import 'auth_service.dart';

class WasherService {
  final DatabaseService _databaseService = DatabaseService();
  final AuthService _authService = AuthService();

  // Get available bookings for washers
  Stream<List<Map<String, dynamic>>> getAvailableBookings() {
    return _databaseService.getAvailableBookings().map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        return {
          'id': doc.id,
          ...data,
        };
      }).toList();
    });
  }

  // Get washer's accepted bookings
  Stream<List<Map<String, dynamic>>> getWasherBookings() {
    final User? currentUser = _authService.currentUser;
    
    if (currentUser == null) {
      throw Exception('User not authenticated');
    }

    return _databaseService.getWasherBookings(currentUser.uid).map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        return {
          'id': doc.id,
          ...data,
        };
      }).toList();
    });
  }

  // Get washer's completed bookings
  Stream<List<Map<String, dynamic>>> getCompletedBookings() {
    final User? currentUser = _authService.currentUser;
    
    if (currentUser == null) {
      throw Exception('User not authenticated');
    }

    return _databaseService.getCompletedBookings(currentUser.uid).map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        return {
          'id': doc.id,
          ...data,
        };
      }).toList();
    });
  }

  // Get washer's upcoming bookings
  Stream<List<Map<String, dynamic>>> getUpcomingBookings() {
    final User? currentUser = _authService.currentUser;
    
    if (currentUser == null) {
      throw Exception('User not authenticated');
    }

    return _databaseService.getUpcomingBookings(currentUser.uid).map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        return {
          'id': doc.id,
          ...data,
        };
      }).toList();
    });
  }

  // Accept a booking
  Future<void> acceptBooking(String bookingId) async {
    final User? currentUser = _authService.currentUser;
    
    if (currentUser == null) {
      throw Exception('User not authenticated');
    }

    // Get washer data to include washer name
    Map<String, dynamic>? userData = await _authService.getUserData(currentUser.uid);
    
    if (userData == null) {
      throw Exception('User data not found');
    }

    await _databaseService.assignWasherToBooking(
      bookingId, 
      currentUser.uid,
      userData['fullName'] ?? 'Washer',
    );
  }

  // Complete a booking
  Future<void> completeBooking(String bookingId) async {
    await _databaseService.updateBookingStatus(bookingId, 'completed');
  }

  // Cancel a booking
  Future<void> cancelBooking(String bookingId) async {
    await _databaseService.updateBookingStatus(bookingId, 'cancelled');
  }

  // ✅ NEW: Washer cancellation with reason
  Future<void> cancelBookingWithReason(String bookingId, String cancelReason) async {
    final User? currentUser = _authService.currentUser;
    
    if (currentUser == null) {
      throw Exception('User not authenticated');
    }

    // Get washer data
    Map<String, dynamic>? userData = await _authService.getUserData(currentUser.uid);
    
    if (userData == null) {
      throw Exception('User data not found');
    }

    await _databaseService.cancelBookingByWasher(
      bookingId: bookingId,
      washerId: currentUser.uid,
      washerName: userData['fullName'] ?? 'Washer',
      cancelReason: cancelReason,
    );
  }

  // ✅ NEW: Get washer workload statistics
  Future<Map<String, dynamic>> getWasherWorkload() async {
    final User? currentUser = _authService.currentUser;
    
    if (currentUser == null) {
      return {
        'activeOrders': 0,
        'todayCompleted': 0,
        'canAcceptASAP': false,
        'totalEarnings': 0.0,
      };
    }

    try {
      return await _databaseService.getWasherWorkload(currentUser.uid);
    } catch (e) {
      return {
        'activeOrders': 0,
        'todayCompleted': 0,
        'canAcceptASAP': false,
        'totalEarnings': 0.0,
        'error': e.toString(),
      };
    }
  }

  // ✅ NEW: Get washer status summary (used by washer_home_page.dart)
  Future<Map<String, dynamic>> getWasherStatusSummary() async {
    return await getWasherWorkload();
  }

  // ✅ NEW: Check if washer can accept a specific booking
  Future<Map<String, dynamic>> canAcceptBooking(String bookingId) async {
    final User? currentUser = _authService.currentUser;
    
    if (currentUser == null) {
      return {
        'canAccept': false,
        'reason': 'User not authenticated',
        'showButton': false,
      };
    }

    try {
      // Get booking details first - use proper Firestore access
      final bookingDoc = await FirebaseFirestore.instance.collection('bookings').doc(bookingId).get();
      if (!bookingDoc.exists) {
        return {
          'canAccept': false,
          'reason': 'Booking not found',
          'showButton': false,
        };
      }

      final bookingData = bookingDoc.data() as Map<String, dynamic>;
      final isASAP = bookingData['isASAP'] ?? false;

      // Check if booking is already expired
      final isExpired = bookingData['isExpired'] ?? false;
      if (isExpired) {
        return {
          'canAccept': false,
          'reason': 'Order has expired',
          'showButton': false,
        };
      }

      // Check expiry timestamp
      final expiryTimestamp = bookingData['expiryTimestamp'];
      if (expiryTimestamp != null) {
        final expiryDate = (expiryTimestamp as Timestamp).toDate();
        if (DateTime.now().isAfter(expiryDate)) {
          return {
            'canAccept': false,
            'reason': 'Order has expired',
            'showButton': false,
          };
        }
      }

      // For ASAP orders, check if washer can accept
      if (isASAP) {
        final canAcceptASAP = await _databaseService.canWasherAcceptASAP(currentUser.uid);
        if (!canAcceptASAP) {
          return {
            'canAccept': false,
            'reason': 'You already have an active ASAP order. Complete it first.',
            'showButton': true, // Show button but disabled
          };
        }
      }

      // All checks passed
      return {
        'canAccept': true,
        'reason': '',
        'showButton': true,
        'isASAP': isASAP,
      };
    } catch (e) {
      return {
        'canAccept': false,
        'reason': 'Error checking booking availability: $e',
        'showButton': false,
      };
    }
  }

  // Get formatted status text for UI display
  String getOrderStatusText(Map<String, dynamic> booking) {
    final isASAP = booking['isASAP'] ?? false;
    final status = booking['status'] ?? 'pending';
    final expiryTimestamp = booking['expiryTimestamp'];
    
    if (status != 'pending') {
      return status.toUpperCase();
    }
    
    if (isASAP) {
      if (expiryTimestamp != null) {
        final expiryDate = (expiryTimestamp as Timestamp).toDate();
        final timeLeft = expiryDate.difference(DateTime.now());
        
        if (timeLeft.isNegative) {
          return 'EXPIRED';
        } else if (timeLeft.inMinutes < 60) {
          return 'ASAP • ${timeLeft.inMinutes}m left';
        } else {
          return 'ASAP • ${timeLeft.inHours}h left';
        }
      }
      return 'ASAP';
    } else {
      return 'SCHEDULED';
    }
  }

  // Get color for order status
  Color getOrderStatusColor(Map<String, dynamic> booking) {
    final isASAP = booking['isASAP'] ?? false;
    final status = booking['status'] ?? 'pending';
    final expiryTimestamp = booking['expiryTimestamp'];
    
    if (status == 'expired' || status == 'cancelled') {
      return Colors.red;
    }
    
    if (isASAP && expiryTimestamp != null) {
      final expiryDate = (expiryTimestamp as Timestamp).toDate();
      final timeLeft = expiryDate.difference(DateTime.now());
      
      if (timeLeft.isNegative) {
        return Colors.red;
      } else if (timeLeft.inMinutes <= 15) {
        return Colors.red;
      } else if (timeLeft.inMinutes <= 30) {
        return Colors.orange;
      } else {
        return Colors.amber; // ASAP but not urgent
      }
    }
    
    if (isASAP) {
      return Colors.amber;
    } else {
      return Colors.blue; // Scheduled orders
    }
  }
}