// rating_service.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'database_service.dart';
import 'auth_service.dart';

class RatingService {
  final DatabaseService _databaseService = DatabaseService();
  final AuthService _authService = AuthService();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  
  // Submit a rating for a completed booking
  Future<void> submitRating({
    required String bookingId,
    required int rating,
    required String review,
  }) async {
    final User? currentUser = _authService.currentUser;
    
    if (currentUser == null) {
      throw Exception('User not authenticated');
    }
    
    // Update the booking with rating and review
    await _databaseService.rateBooking(bookingId, rating, review);
    
    // Get the booking details to get washer ID
    final bookingDoc = await _firestore.collection('bookings').doc(bookingId).get();
    
    if (!bookingDoc.exists) {
      throw Exception('Booking not found');
    }
    
    final bookingData = bookingDoc.data();
    
    if (bookingData == null) {
      throw Exception('Booking data is null');
    }
    
    final washerId = bookingData['washerId'];
    
    if (washerId == null) {
      throw Exception('Washer ID not found in booking');
    }
    
    // Update washer's average rating
    await _updateWasherRating(washerId);
  }
  
  // Calculate and update washer's average rating
  Future<void> _updateWasherRating(String washerId) async {
    // Get all completed bookings for this washer that have ratings
    final QuerySnapshot snapshot = await _firestore
        .collection('bookings')
        .where('washerId', isEqualTo: washerId)
        .where('status', isEqualTo: 'completed')
        .where('rating', isGreaterThan: 0)
        .get();
    
    if (snapshot.docs.isEmpty) {
      return; // No rated bookings for this washer
    }
    
    // Calculate average rating
    double totalRating = 0;
    int ratingCount = 0;
    
    for (final doc in snapshot.docs) {
      final data = doc.data() as Map<String, dynamic>;
      if (data.containsKey('rating')) {
        totalRating += (data['rating'] as num).toDouble();
        ratingCount++;
      }
    }
    
    double averageRating = totalRating / ratingCount;
    
    // Update washer profile with new rating
    await _firestore.collection('washerProfiles').doc(washerId).update({
      'rating': averageRating,
      'ratingCount': ratingCount,
      'updatedAt': FieldValue.serverTimestamp(),
    });
    
    // Also update user record
    await _firestore.collection('users').doc(washerId).update({
      'rating': averageRating,
      'ratingCount': ratingCount,
    });
  }
  
  // Get ratings for a washer
  Future<List<Map<String, dynamic>>> getWasherRatings(String washerId) async {
    final QuerySnapshot snapshot = await _firestore
        .collection('bookings')
        .where('washerId', isEqualTo: washerId)
        .where('status', isEqualTo: 'completed')
        .where('rating', isGreaterThan: 0)
        .orderBy('rating', descending: true)
        .get();
    
    return snapshot.docs.map((doc) {
      final data = doc.data() as Map<String, dynamic>;
      return {
        'id': doc.id,
        'rating': data['rating'] ?? 0,
        'review': data['review'] ?? '',
        'customerName': data['customerName'] ?? 'Customer',
        'date': data['date'] ?? '',
        'vehicleType': data['vehicleType'] ?? '',
        'packageName': data['packageName'] ?? '',
      };
    }).toList();
  }
  
  // Check if a booking can be rated
  Future<bool> canRateBooking(String bookingId) async {
    final User? currentUser = _authService.currentUser;
    
    if (currentUser == null) {
      return false;
    }
    
    final DocumentSnapshot bookingDoc = await _firestore.collection('bookings').doc(bookingId).get();
    
    if (!bookingDoc.exists) {
      return false;
    }
    
    final data = bookingDoc.data() as Map<String, dynamic>?;
    
    if (data == null) {
      return false;
    }
    
    // Check if the booking is completed and not yet rated
    return data['status'] == 'completed' && 
           data['customerId'] == currentUser.uid && 
           (data['rating'] == null || data['rating'] == 0);
  }
}