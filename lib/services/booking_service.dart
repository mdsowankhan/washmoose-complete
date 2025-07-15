// booking_service.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'database_service.dart';
import 'auth_service.dart';

class BookingService {
  final DatabaseService _databaseService = DatabaseService();
  final AuthService _authService = AuthService();
  
  // ✅ ENHANCED: Create a new booking with isASAP support
  Future<String> createBooking({
    required String vehicleType,
    required String packageName,
    required List<String> addOns,
    required String date,
    required String time,
    required double totalPrice,
    required int duration,
    required String location,
    bool isASAP = false, // ✅ NEW: Add isASAP parameter with default false
  }) async {
    try {
      final User? currentUser = _authService.currentUser;
      
      if (currentUser == null) {
        throw Exception('User not authenticated');
      }
      
      // Get user data to include customer name
      Map<String, dynamic>? userData = await _authService.getUserData(currentUser.uid);
      
      if (userData == null) {
        throw Exception('User data not found');
      }
      
      // ✅ ENHANCED: Create the booking with isASAP parameter
      return await _databaseService.createBooking(
        customerId: currentUser.uid,
        customerName: userData['fullName'] ?? 'Customer',
        vehicleType: vehicleType,
        packageName: packageName,
        addOns: addOns,
        date: date,
        time: time,
        totalPrice: totalPrice,
        duration: duration,
        location: location,
        isASAP: isASAP, // ✅ NEW: Pass isASAP to database layer
      );
    } catch (e) {
      throw Exception('Failed to create booking: $e');
    }
  }
  
  // Get customer bookings
  Stream<List<Map<String, dynamic>>> getCustomerBookings() {
    final User? currentUser = _authService.currentUser;
    
    if (currentUser == null) {
      throw Exception('User not authenticated');
    }
    
    return _databaseService.getCustomerBookings(currentUser.uid).map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        return {
          'id': doc.id,
          ...data,
        };
      }).toList();
    });
  }
  
  // Accept a booking (washer)
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
  
  // Complete a booking (washer)
  Future<void> completeBooking(String bookingId) async {
    await _databaseService.updateBookingStatus(bookingId, 'completed');
  }
  
  // Cancel a booking
  Future<void> cancelBooking(String bookingId) async {
    await _databaseService.updateBookingStatus(bookingId, 'cancelled');
  }
  
  // Get booking details
  Future<Map<String, dynamic>> getBookingDetails(String bookingId) async {
    DocumentSnapshot doc = await _databaseService.getBookingDetails(bookingId);
    
    if (!doc.exists) {
      throw Exception('Booking not found');
    }
    
    return {
      'id': doc.id,
      ...(doc.data() as Map<String, dynamic>),
    };
  }
}