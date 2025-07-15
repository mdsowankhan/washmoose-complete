// database_service.dart (Complete with all required functionality + ORDER EXPIRY SYSTEM)
import 'package:cloud_firestore/cloud_firestore.dart';

class DatabaseService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // ✅ ENHANCED: Create a new booking with EXPIRY SYSTEM
  Future<String> createBooking({
    required String customerId,
    required String customerName,
    required String vehicleType,
    required String packageName,
    required List<String> addOns,
    required String date,
    required String time,
    required double totalPrice,
    required int duration,
    required String location,
    String? washerId,
    String status = 'pending', // pending, confirmed, completed, cancelled
    bool isASAP = false, // ✅ NEW: Track if this is an ASAP order
  }) async {
    try {
      // ✅ NEW: Calculate expiry timestamp based on order type
      DateTime? expiryTimestamp;
      
      if (isASAP) {
        // ASAP orders expire in 1 hour
        expiryTimestamp = DateTime.now().add(const Duration(hours: 1));
      } else {
        // Custom time orders expire 2 hours before scheduled time
        try {
          // Parse the date and time to create DateTime
          final scheduledDateTime = _parseScheduledDateTime(date, time);
          expiryTimestamp = scheduledDateTime.subtract(const Duration(hours: 2));
          
          // Don't set expiry if it's already past (for past bookings)
          if (expiryTimestamp.isBefore(DateTime.now())) {
            expiryTimestamp = null;
          }
        } catch (e) {
          // If parsing fails, don't set expiry
          expiryTimestamp = null;
        }
      }

      DocumentReference bookingRef = await _firestore.collection('bookings').add({
        'customerId': customerId,
        'customerName': customerName,
        'vehicleType': vehicleType,
        'packageName': packageName,
        'addOns': addOns,
        'date': date,
        'time': time,
        'totalPrice': totalPrice,
        'duration': duration,
        'location': location,
        'washerId': washerId,
        'status': status,
        
        // ✅ NEW: Order expiry fields
        'isASAP': isASAP,
        'expiryTimestamp': expiryTimestamp != null ? Timestamp.fromDate(expiryTimestamp) : null,
        'isExpired': false,
        'autoExpired': false, // Track if cancelled due to expiry
        
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });
      
      return bookingRef.id;
    } catch (e) {
      throw Exception('Failed to create booking: $e');
    }
  }

  // ✅ NEW: Helper method to parse scheduled date and time
  DateTime _parseScheduledDateTime(String date, String time) {
    try {
      // Handle different date formats
      final now = DateTime.now();
      DateTime parsedDate;
      
      // Try to parse common date formats
      if (date.toLowerCase() == 'today') {
        parsedDate = DateTime(now.year, now.month, now.day);
      } else if (date.toLowerCase() == 'tomorrow') {
        final tomorrow = now.add(const Duration(days: 1));
        parsedDate = DateTime(tomorrow.year, tomorrow.month, tomorrow.day);
      } else {
        // Try parsing various date formats
        final parts = date.split(RegExp(r'[,\s]+')).where((s) => s.isNotEmpty).toList();
        if (parts.length >= 3) {
          // Format: "Jan 15, 2025" or similar
          final monthStr = parts[0];
          final day = int.parse(parts[1]);
          final year = int.parse(parts[2]);
          final month = _getMonthNumber(monthStr);
          parsedDate = DateTime(year, month, day);
        } else {
          // Fallback to current date
          parsedDate = DateTime(now.year, now.month, now.day);
        }
      }
      
      // Parse time (format: "2:00 PM" or "14:00")
      final timeClean = time.trim();
      int hour = 0;
      int minute = 0;
      
      if (timeClean.toLowerCase().contains('pm') || timeClean.toLowerCase().contains('am')) {
        final isPM = timeClean.toLowerCase().contains('pm');
        final timeOnly = timeClean.replaceAll(RegExp(r'[^\d:]'), '');
        final timeParts = timeOnly.split(':');
        hour = int.parse(timeParts[0]);
        if (timeParts.length > 1) minute = int.parse(timeParts[1]);
        
        if (isPM && hour != 12) hour += 12;
        if (!isPM && hour == 12) hour = 0;
      } else {
        // 24-hour format
        final timeParts = timeClean.split(':');
        hour = int.parse(timeParts[0]);
        if (timeParts.length > 1) minute = int.parse(timeParts[1]);
      }
      
      return DateTime(parsedDate.year, parsedDate.month, parsedDate.day, hour, minute);
    } catch (e) {
      // If parsing fails, return a default time (2 hours from now)
      return DateTime.now().add(const Duration(hours: 2));
    }
  }

  // ✅ NEW: Helper to convert month name to number
  int _getMonthNumber(String monthStr) {
    const months = {
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
    return months[monthStr.toLowerCase()] ?? 1;
  }

  // Get bookings for a customer
  Stream<QuerySnapshot> getCustomerBookings(String customerId) {
    return _firestore
        .collection('bookings')
        .where('customerId', isEqualTo: customerId)
        .orderBy('createdAt', descending: true)
        .snapshots();
  }

  // Get bookings for a washer
  Stream<QuerySnapshot> getWasherBookings(String washerId) {
    return _firestore
        .collection('bookings')
        .where('washerId', isEqualTo: washerId)
        .orderBy('createdAt', descending: true)
        .snapshots();
  }

  // ✅ ENHANCED: Get available bookings (filtered by expiry and washer limits)
  Stream<QuerySnapshot> getAvailableBookings() {
    // First clean expired orders, then return active ones
    _cleanupExpiredOrders();
    
    return _firestore
        .collection('bookings')
        .where('washerId', isNull: true)
        .where('status', isEqualTo: 'pending')
        .where('isExpired', isEqualTo: false) // ✅ NEW: Filter expired orders
        .orderBy('isASAP', descending: true) // ✅ NEW: ASAP orders first
        .orderBy('createdAt', descending: true)
        .snapshots();
  }

  // Get completed bookings for a washer
  Stream<QuerySnapshot> getCompletedBookings(String washerId) {
    return _firestore
        .collection('bookings')
        .where('washerId', isEqualTo: washerId)
        .where('status', isEqualTo: 'completed')
        .orderBy('createdAt', descending: true)
        .snapshots();
  }

  // Get upcoming bookings for a washer
  Stream<QuerySnapshot> getUpcomingBookings(String washerId) {
    return _firestore
        .collection('bookings')
        .where('washerId', isEqualTo: washerId)
        .where('status', isEqualTo: 'confirmed')
        .orderBy('createdAt', descending: true)
        .snapshots();
  }

  // Update booking status
  Future<void> updateBookingStatus(String bookingId, String status) async {
    await _firestore.collection('bookings').doc(bookingId).update({
      'status': status,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  // ✅ ENHANCED: Assign washer to booking with ASAP concurrency check
  Future<void> assignWasherToBooking(String bookingId, String washerId, String washerName) async {
    try {
      // Get booking details first
      final bookingDoc = await _firestore.collection('bookings').doc(bookingId).get();
      if (!bookingDoc.exists) {
        throw Exception('Booking not found');
      }
      
      final bookingData = bookingDoc.data() as Map<String, dynamic>;
      final isASAP = bookingData['isASAP'] ?? false;
      
      // ✅ NEW: Check if washer can accept ASAP orders
      if (isASAP) {
        final canAccept = await canWasherAcceptASAP(washerId);
        if (!canAccept) {
          throw Exception('You already have an active ASAP order. Please complete it first.');
        }
      }

      // Get washer type from user profile
      final userDoc = await _firestore.collection('users').doc(washerId).get();
      final washerType = userDoc.data()?['washerType'] ?? 'everyday';

      await _firestore.collection('bookings').doc(bookingId).update({
        'washerId': washerId,
        'washerName': washerName,
        'washerType': washerType, // Store for commission calculation
        'status': 'confirmed',
        'acceptedAt': FieldValue.serverTimestamp(), // ✅ NEW: Track acceptance time
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw Exception('Failed to assign washer: $e');
    }
  }

  // Rate a completed booking
  Future<void> rateBooking(String bookingId, int rating, String review) async {
    await _firestore.collection('bookings').doc(bookingId).update({
      'rating': rating,
      'review': review,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  // Cancel a booking
  Future<void> cancelBooking(String bookingId, String? cancelReason) async {
    await _firestore.collection('bookings').doc(bookingId).update({
      'status': 'cancelled',
      'cancelReason': cancelReason,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  // ✅ NEW: Washer-specific cancellation with reason and customer notification
  Future<void> cancelBookingByWasher({
    required String bookingId, 
    required String washerId,
    required String washerName,
    required String cancelReason,
  }) async {
    try {
      // Get booking details first to notify customer
      final bookingDoc = await _firestore.collection('bookings').doc(bookingId).get();
      if (!bookingDoc.exists) {
        throw Exception('Booking not found');
      }
      
      final bookingData = bookingDoc.data() as Map<String, dynamic>;
      final customerId = bookingData['customerId'] as String?;
      final customerName = bookingData['customerName'] as String?;
      final packageName = bookingData['packageName'] as String?;
      final isASAP = bookingData['isASAP'] as bool? ?? false;
      
      // Update booking status
      await _firestore.collection('bookings').doc(bookingId).update({
        'status': 'cancelled',
        'cancelReason': cancelReason,
        'cancelledBy': 'washer',
        'cancelledByUserId': washerId,
        'cancelledByName': washerName,
        'cancelledAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });
      
      // Send notification to customer
      if (customerId != null) {
        await _firestore.collection('notifications').add({
          'userId': customerId,
          'type': 'booking_cancelled_by_washer',
          'title': 'Booking Cancelled',
          'message': '$washerName cancelled your ${isASAP ? "ASAP" : ""} $packageName booking. Reason: $cancelReason',
          'bookingId': bookingId,
          'isRead': false,
          'createdAt': FieldValue.serverTimestamp(),
        });
      }
      
      print('✅ Booking $bookingId cancelled by washer $washerName');
      
    } catch (e) {
      throw Exception('Failed to cancel booking: $e');
    }
  }

  // Get booking details
  Future<DocumentSnapshot> getBookingDetails(String bookingId) async {
    return await _firestore.collection('bookings').doc(bookingId).get();
  }
  
  // Create a new washer profile
  Future<void> createWasherProfile({
    required String washerId,
    required String washerType, // 'everyday' or 'expert'
    String? bio,
    List<String>? services,
    List<String>? certifications,
    List<String>? equipment,
  }) async {
    await _firestore.collection('washerProfiles').doc(washerId).set({
      'washerType': washerType,
      'bio': bio ?? '',
      'services': services ?? [],
      'certifications': certifications ?? [],
      'equipment': equipment ?? [],
      'rating': 0.0,
      'totalJobs': 0,
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  // Update washer profile
  Future<void> updateWasherProfile({
    required String washerId,
    String? bio,
    List<String>? services,
    List<String>? certifications,
    List<String>? equipment,
  }) async {
    Map<String, dynamic> data = {
      'updatedAt': FieldValue.serverTimestamp(),
    };
    
    if (bio != null) data['bio'] = bio;
    if (services != null) data['services'] = services;
    if (certifications != null) data['certifications'] = certifications;
    if (equipment != null) data['equipment'] = equipment;
    
    await _firestore.collection('washerProfiles').doc(washerId).update(data);
  }

  // Get washer profile
  Future<DocumentSnapshot> getWasherProfile(String washerId) async {
    return await _firestore.collection('washerProfiles').doc(washerId).get();
  }

  // Update washer availability
  Future<void> updateWasherAvailability(
    String washerId, 
    List<String> availableDays,
    Map<String, List<String>> availableHours,
  ) async {
    await _firestore.collection('washerProfiles').doc(washerId).update({
      'availability': {
        'days': availableDays,
        'hours': availableHours,
      },
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  // Get all washers by type
  Stream<QuerySnapshot> getWashersByType(String washerType) {
    return _firestore
        .collection('users')
        .where('userType', isEqualTo: 'washer')
        .where('washerType', isEqualTo: washerType)
        .snapshots();
  }

  // Calculate washer earnings - FIXED COMMISSION RATES
  Future<double> calculateWasherEarnings(String washerId) async {
    final QuerySnapshot snapshot = await _firestore
        .collection('bookings')
        .where('washerId', isEqualTo: washerId)
        .where('status', isEqualTo: 'completed')
        .get();
    
    double totalEarnings = 0.0;
    
    for (final doc in snapshot.docs) {
      final data = doc.data() as Map<String, dynamic>;
      final price = data['totalPrice'] as double;
      
      // FIXED: Correct commission rates
      // Everyday Moose: washer gets 85% (you get 15%)
      // Expert Moose: washer gets 90% (you get 10%)
      final commission = data['washerType'] == 'expert' ? 0.90 : 0.85;
      totalEarnings += price * commission;
    }
    
    return totalEarnings;
  }

  // Calculate pending earnings (confirmed but not completed)
  Future<double> calculatePendingEarnings(String washerId) async {
    final QuerySnapshot snapshot = await _firestore
        .collection('bookings')
        .where('washerId', isEqualTo: washerId)
        .where('status', whereIn: ['confirmed', 'in_progress'])
        .get();
    
    double totalPending = 0.0;
    
    for (final doc in snapshot.docs) {
      final data = doc.data() as Map<String, dynamic>;
      final price = data['totalPrice'] as double;
      
      // Same commission rates
      final commission = data['washerType'] == 'expert' ? 0.90 : 0.85;
      totalPending += price * commission;
    }
    
    return totalPending;
  }

  // Get washer earnings breakdown by time period
  Future<Map<String, double>> getWasherEarningsBreakdown(String washerId) async {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final thisWeekStart = today.subtract(Duration(days: today.weekday - 1));
    final thisMonthStart = DateTime(now.year, now.month, 1);

    // Get all completed bookings for this washer
    final QuerySnapshot snapshot = await _firestore
        .collection('bookings')
        .where('washerId', isEqualTo: washerId)
        .where('status', isEqualTo: 'completed')
        .get();

    double todayEarnings = 0.0;
    double thisWeekEarnings = 0.0;
    double thisMonthEarnings = 0.0;
    double allTimeEarnings = 0.0;

    for (final doc in snapshot.docs) {
      final data = doc.data() as Map<String, dynamic>;
      final price = data['totalPrice'] as double;
      final timestamp = data['createdAt'] as Timestamp?;
      
      if (timestamp == null) continue;
      
      final bookingDate = timestamp.toDate();
      final commission = data['washerType'] == 'expert' ? 0.90 : 0.85;
      final earnings = price * commission;

      // Add to all time
      allTimeEarnings += earnings;

      // Add to monthly if within this month
      if (bookingDate.isAfter(thisMonthStart) || bookingDate.isAtSameMomentAs(thisMonthStart)) {
        thisMonthEarnings += earnings;
      }

      // Add to weekly if within this week
      if (bookingDate.isAfter(thisWeekStart) || bookingDate.isAtSameMomentAs(thisWeekStart)) {
        thisWeekEarnings += earnings;
      }

      // Add to today if today
      if (bookingDate.year == today.year && 
          bookingDate.month == today.month && 
          bookingDate.day == today.day) {
        todayEarnings += earnings;
      }
    }

    return {
      'today': todayEarnings,
      'thisWeek': thisWeekEarnings,
      'thisMonth': thisMonthEarnings,
      'allTime': allTimeEarnings,
    };
  }

  // Get washer transaction history with earnings calculated
  Stream<List<Map<String, dynamic>>> getWasherTransactions(String washerId) {
    return _firestore
        .collection('bookings')
        .where('washerId', isEqualTo: washerId)
        .where('status', whereIn: ['completed', 'confirmed', 'in_progress'])
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        
        // Calculate washer earnings for this booking
        final price = data['totalPrice'] as double;
        final commission = data['washerType'] == 'expert' ? 0.90 : 0.85;
        final washerEarnings = price * commission;

        return {
          'id': doc.id,
          'customerName': data['customerName'] ?? 'Customer',
          'vehicleType': data['vehicleType'] ?? 'Unknown',
          'packageName': data['packageName'] ?? 'Service',
          'totalPrice': price,
          'washerEarnings': washerEarnings,
          'status': data['status'] ?? 'pending',
          'date': data['createdAt'],
          'washerType': data['washerType'] ?? 'everyday',
          ...data,
        };
      }).toList();
    });
  }

  // Create chat message
  Future<void> createChatMessage({
    required String bookingId,
    required String senderId,
    required String recipientId,
    required String message,
  }) async {
    await _firestore.collection('chats').doc(bookingId).collection('messages').add({
      'senderId': senderId,
      'recipientId': recipientId,
      'message': message,
      'timestamp': FieldValue.serverTimestamp(),
      'read': false,
    });
  }

  // Get chat messages for a booking
  Stream<QuerySnapshot> getChatMessages(String bookingId) {
    return _firestore
        .collection('chats')
        .doc(bookingId)
        .collection('messages')
        .orderBy('timestamp', descending: false)
        .snapshots();
  }

  // Mark messages as read
  Future<void> markMessagesAsRead(String bookingId, String userId) async {
    final QuerySnapshot snapshot = await _firestore
        .collection('chats')
        .doc(bookingId)
        .collection('messages')
        .where('recipientId', isEqualTo: userId)
        .where('read', isEqualTo: false)
        .get();
    
    for (final doc in snapshot.docs) {
      await doc.reference.update({'read': true});
    }
  }

  // ========== JOB POSTING & NEGOTIATION METHODS ==========

  // Create a custom job posting
  Future<String> createJobPosting({
    required String customerId,
    required String customerName,
    required String vehicleType,
    required String description,
    required String location,
    required List<String> photoUrls, // URLs of uploaded photos
    double? expectedPrice, // Optional price expectation
    String? timeline, // Optional timeline preference
    Map<String, dynamic>? additionalDetails,
  }) async {
    try {
      DocumentReference jobRef = await _firestore.collection('jobPostings').add({
        'customerId': customerId,
        'customerName': customerName,
        'vehicleType': vehicleType,
        'description': description,
        'location': location,
        'photoUrls': photoUrls,
        'expectedPrice': expectedPrice,
        'timeline': timeline,
        'additionalDetails': additionalDetails ?? {},
        'status': 'pending', // pending, negotiating, completed, declined, expired
        'totalOffers': 0,
        'activeNegotiations': 0,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });
      
      return jobRef.id;
    } catch (e) {
      throw Exception('Failed to create job posting: $e');
    }
  }

  // Get all active job postings (for washers to browse)
  Stream<QuerySnapshot> getActiveJobPostings() {
    return _firestore
        .collection('jobPostings')
        .where('status', whereIn: ['pending', 'negotiating'])
        .orderBy('createdAt', descending: true)
        .snapshots();
  }

  // Get customer's job postings
  Stream<QuerySnapshot> getCustomerJobPostings(String customerId) {
    return _firestore
        .collection('jobPostings')
        .where('customerId', isEqualTo: customerId)
        .orderBy('createdAt', descending: true)
        .snapshots();
  }

  // Create initial offer from washer
  Future<String> createOffer({
    required String jobPostingId,
    required String washerId,
    required String washerName,
    required double offerPrice,
    required String message,
    String? timeline,
    Map<String, dynamic>? serviceDetails,
  }) async {
    try {
      // Start transaction to ensure data consistency
      return await _firestore.runTransaction((transaction) async {
        // Get job posting
        DocumentSnapshot jobDoc = await transaction.get(
          _firestore.collection('jobPostings').doc(jobPostingId)
        );
        
        if (!jobDoc.exists) {
          throw Exception('Job posting not found');
        }
        
        final jobData = jobDoc.data() as Map<String, dynamic>;
        
        // Check if job is still available for offers
        if (jobData['status'] != 'pending') {
          throw Exception('Job posting is no longer accepting offers');
        }
        
        // Create the offer
        DocumentReference offerRef = await _firestore.collection('offers').add({
          'jobPostingId': jobPostingId,
          'customerId': jobData['customerId'],
          'customerName': jobData['customerName'],
          'washerId': washerId,
          'washerName': washerName,
          'offerPrice': offerPrice,
          'message': message,
          'timeline': timeline,
          'serviceDetails': serviceDetails ?? {},
          'status': 'pending', // pending, accepted, declined, countered
          'negotiationStatus': 'initial_offer', // initial_offer, customer_counter_1, washer_counter_1, customer_final, washer_final
          'washerOfferCount': 1,
          'customerOfferCount': 0,
          'createdAt': FieldValue.serverTimestamp(),
          'updatedAt': FieldValue.serverTimestamp(),
        });
        
        // Update job posting
        transaction.update(_firestore.collection('jobPostings').doc(jobPostingId), {
          'status': 'negotiating',
          'totalOffers': FieldValue.increment(1),
          'activeNegotiations': FieldValue.increment(1),
          'updatedAt': FieldValue.serverTimestamp(),
        });
        
        return offerRef.id;
      });
    } catch (e) {
      throw Exception('Failed to create offer: $e');
    }
  }

  // Create counter-offer (handles both customer and washer counters)
  Future<void> createCounterOffer({
    required String offerId,
    required String counterByUserId,
    required String counterByUserName,
    required double counterPrice,
    required String message,
    required bool isCustomerCounter, // true if customer countering, false if washer
  }) async {
    try {
      await _firestore.runTransaction((transaction) async {
        // Get current offer
        DocumentSnapshot offerDoc = await transaction.get(
          _firestore.collection('offers').doc(offerId)
        );
        
        if (!offerDoc.exists) {
          throw Exception('Offer not found');
        }
        
        final offerData = offerDoc.data() as Map<String, dynamic>;
        final currentStatus = offerData['negotiationStatus'] as String;
        final washerOfferCount = offerData['washerOfferCount'] as int;
        final customerOfferCount = offerData['customerOfferCount'] as int;
        
        // Validate negotiation rules
        String newStatus;
        Map<String, dynamic> updateData = {
          'status': 'countered',
          'updatedAt': FieldValue.serverTimestamp(),
        };
        
        if (isCustomerCounter) {
          // Customer is countering
          if (customerOfferCount >= 2) {
            throw Exception('Customer has already made maximum offers');
          }
          
          if (currentStatus == 'initial_offer') {
            newStatus = 'customer_counter_1';
          } else if (currentStatus == 'washer_counter_1') {
            newStatus = 'customer_final'; // Customer's final offer
          } else {
            throw Exception('Invalid negotiation state for customer counter');
          }
          
          updateData['customerOfferCount'] = FieldValue.increment(1);
          updateData['lastCustomerOffer'] = counterPrice;
          updateData['lastCustomerMessage'] = message;
          
        } else {
          // Washer is countering
          if (washerOfferCount >= 2) {
            throw Exception('Washer has already made maximum offers');
          }
          
          if (currentStatus == 'customer_counter_1') {
            newStatus = 'washer_final'; // Washer's final offer
          } else {
            throw Exception('Invalid negotiation state for washer counter');
          }
          
          updateData['washerOfferCount'] = FieldValue.increment(1);
          updateData['lastWasherOffer'] = counterPrice;
          updateData['lastWasherMessage'] = message;
        }
        
        updateData['negotiationStatus'] = newStatus;
        
        // Update the offer
        transaction.update(_firestore.collection('offers').doc(offerId), updateData);
      });
    } catch (e) {
      throw Exception('Failed to create counter offer: $e');
    }
  }

  // Accept an offer (final decision)
  Future<void> acceptOffer({
    required String offerId,
    required String acceptedByUserId,
    required bool isCustomerAccepting,
  }) async {
    try {
      await _firestore.runTransaction((transaction) async {
        // Get offer details
        DocumentSnapshot offerDoc = await transaction.get(
          _firestore.collection('offers').doc(offerId)
        );
        
        if (!offerDoc.exists) {
          throw Exception('Offer not found');
        }
        
        final offerData = offerDoc.data() as Map<String, dynamic>;
        final jobPostingId = offerData['jobPostingId'] as String;
        final negotiationStatus = offerData['negotiationStatus'] as String;
        
        // Validate acceptance rules
        if (isCustomerAccepting) {
          if (!['initial_offer', 'washer_counter_1', 'washer_final'].contains(negotiationStatus)) {
            throw Exception('Invalid state for customer acceptance');
          }
        } else {
          if (!['customer_counter_1', 'customer_final'].contains(negotiationStatus)) {
            throw Exception('Invalid state for washer acceptance');
          }
        }
        
        // Determine final accepted price
        double finalPrice;
        if (isCustomerAccepting) {
          // Customer accepting washer's offer
          finalPrice = offerData['lastWasherOffer'] ?? offerData['offerPrice'];
        } else {
          // Washer accepting customer's counter
          finalPrice = offerData['lastCustomerOffer'];
        }
        
        // Update offer status
        transaction.update(_firestore.collection('offers').doc(offerId), {
          'status': 'accepted',
          'finalPrice': finalPrice,
          'acceptedBy': acceptedByUserId,
          'acceptedAt': FieldValue.serverTimestamp(),
          'updatedAt': FieldValue.serverTimestamp(),
        });
        
        // Update job posting
        transaction.update(_firestore.collection('jobPostings').doc(jobPostingId), {
          'status': 'completed',
          'finalPrice': finalPrice,
          'acceptedOfferId': offerId,
          'updatedAt': FieldValue.serverTimestamp(),
        });
        
        // Create confirmed booking
        DocumentReference bookingRef = _firestore.collection('bookings').doc();
        transaction.set(bookingRef, {
          'customerId': offerData['customerId'],
          'customerName': offerData['customerName'],
          'washerId': offerData['washerId'],
          'washerName': offerData['washerName'],
          'jobPostingId': jobPostingId,
          'offerId': offerId,
          'vehicleType': '', // Will be filled from job posting
          'packageName': 'Custom Job',
          'addOns': [],
          'date': '', // To be scheduled
          'time': '', // To be scheduled
          'totalPrice': finalPrice,
          'duration': 0, // To be determined
          'location': '', // Will be filled from job posting
          'status': 'confirmed',
          'createdAt': FieldValue.serverTimestamp(),
          'updatedAt': FieldValue.serverTimestamp(),
        });
      });
    } catch (e) {
      throw Exception('Failed to accept offer: $e');
    }
  }

  // Decline an offer (final decision)
  Future<void> declineOffer({
    required String offerId,
    required String declinedByUserId,
    required bool isCustomerDeclining,
    String? declineReason,
  }) async {
    try {
      await _firestore.runTransaction((transaction) async {
        // Get offer details
        DocumentSnapshot offerDoc = await transaction.get(
          _firestore.collection('offers').doc(offerId)
        );
        
        if (!offerDoc.exists) {
          throw Exception('Offer not found');
        }
        
        final offerData = offerDoc.data() as Map<String, dynamic>;
        final jobPostingId = offerData['jobPostingId'] as String;
        final negotiationStatus = offerData['negotiationStatus'] as String;
        
        // Update offer status
        transaction.update(_firestore.collection('offers').doc(offerId), {
          'status': 'declined',
          'declinedBy': declinedByUserId,
          'declineReason': declineReason,
          'declinedAt': FieldValue.serverTimestamp(),
          'updatedAt': FieldValue.serverTimestamp(),
        });
        
        // Check if this is a final decline (ends all negotiation)
        bool isFinalDecline = false;
        
        if (isCustomerDeclining && negotiationStatus == 'washer_final') {
          // Customer declined washer's final offer - negotiation ends
          isFinalDecline = true;
        } else if (!isCustomerDeclining && negotiationStatus == 'customer_final') {
          // Washer declined customer's final offer - customer gets final choice on washer's last offer
          transaction.update(_firestore.collection('offers').doc(offerId), {
            'negotiationStatus': 'final_choice_pending',
          });
        }
        
        if (isFinalDecline) {
          // Update job posting as declined
          transaction.update(_firestore.collection('jobPostings').doc(jobPostingId), {
            'status': 'declined',
            'updatedAt': FieldValue.serverTimestamp(),
          });
        }
      });
    } catch (e) {
      throw Exception('Failed to decline offer: $e');
    }
  }

  // Get offers for a specific job posting
  Stream<QuerySnapshot> getJobOffers(String jobPostingId) {
    return _firestore
        .collection('offers')
        .where('jobPostingId', isEqualTo: jobPostingId)
        .orderBy('createdAt', descending: true)
        .snapshots();
  }

  // Get offers made by a washer
  Stream<QuerySnapshot> getWasherOffers(String washerId) {
    return _firestore
        .collection('offers')
        .where('washerId', isEqualTo: washerId)
        .orderBy('createdAt', descending: true)
        .snapshots();
  }

  // Get offers for jobs posted by a customer
  Stream<QuerySnapshot> getCustomerOffers(String customerId) {
    return _firestore
        .collection('offers')
        .where('customerId', isEqualTo: customerId)
        .orderBy('createdAt', descending: true)
        .snapshots();
  }

  // Get specific offer details
  Future<DocumentSnapshot> getOfferDetails(String offerId) async {
    return await _firestore.collection('offers').doc(offerId).get();
  }

  // Get job posting details
  Future<DocumentSnapshot> getJobPostingDetails(String jobPostingId) async {
    return await _firestore.collection('jobPostings').doc(jobPostingId).get();
  }

  // ========== PAYMENT SYSTEM METHODS ==========

  // Create payment record for two-step payment system
  Future<String> createPaymentRecord({
    required String bookingId,
    required double totalAmount,
    required double depositAmount,
    required double remainingAmount,
    String? depositPaymentId,
    String? remainingPaymentId,
    required String depositStatus, // 'pending', 'completed', 'failed'
    String remainingStatus = 'pending',
    required String paymentMethod, // 'paypal', 'pay_on_service'
  }) async {
    try {
      DocumentReference paymentRef = await _firestore.collection('payments').add({
        'bookingId': bookingId,
        'totalAmount': totalAmount,
        'depositAmount': depositAmount,
        'remainingAmount': remainingAmount,
        'depositPaymentId': depositPaymentId,
        'remainingPaymentId': remainingPaymentId,
        'depositStatus': depositStatus,
        'remainingStatus': remainingStatus,
        'paymentMethod': paymentMethod,
        'currency': 'AUD',
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });
      
      // Update booking with payment reference
      await _firestore.collection('bookings').doc(bookingId).update({
        'paymentId': paymentRef.id,
        'depositPaid': depositStatus == 'completed',
        'paymentMethod': paymentMethod,
      });
      
      return paymentRef.id;
    } catch (e) {
      throw Exception('Failed to create payment record: $e');
    }
  }

  // Mark job as complete and trigger remaining payment
  Future<void> markJobComplete(String bookingId) async {
    try {
      await _firestore.runTransaction((transaction) async {
        // Update booking status
        transaction.update(_firestore.collection('bookings').doc(bookingId), {
          'status': 'completed',
          'completedAt': FieldValue.serverTimestamp(),
          'remainingPaymentDue': true,
        });
        
        // Create notification for customer to pay remaining balance
        transaction.set(_firestore.collection('notifications').doc(), {
          'bookingId': bookingId,
          'type': 'payment_reminder',
          'title': 'Service Complete - Payment Due',
          'message': 'Your wash is complete! Please pay the remaining balance.',
          'status': 'pending',
          'createdAt': FieldValue.serverTimestamp(),
        });
      });
    } catch (e) {
      throw Exception('Failed to mark job complete: $e');
    }
  }

  // Get payment details for a booking
  Future<DocumentSnapshot> getPaymentDetails(String bookingId) async {
    final QuerySnapshot snapshot = await _firestore
        .collection('payments')
        .where('bookingId', isEqualTo: bookingId)
        .limit(1)
        .get();
    
    if (snapshot.docs.isEmpty) {
      throw Exception('Payment record not found');
    }
    
    return snapshot.docs.first;
  }

  // ========== ✅ NEW ORDER EXPIRY SYSTEM METHODS ==========

  // Check if washer can accept ASAP orders (limit 1 active ASAP per washer)
  Future<bool> canWasherAcceptASAP(String washerId) async {
    try {
      final QuerySnapshot activeASAP = await _firestore
          .collection('bookings')
          .where('washerId', isEqualTo: washerId)
          .where('isASAP', isEqualTo: true)
          .where('status', whereIn: ['confirmed', 'in_progress'])
          .limit(1)
          .get();
      
      return activeASAP.docs.isEmpty;
    } catch (e) {
      return true; // If error, allow acceptance
    }
  }

  // Get active ASAP orders for a washer
  Future<List<Map<String, dynamic>>> getActiveASAPOrders(String washerId) async {
    try {
      final QuerySnapshot snapshot = await _firestore
          .collection('bookings')
          .where('washerId', isEqualTo: washerId)
          .where('isASAP', isEqualTo: true)
          .where('status', whereIn: ['confirmed', 'in_progress'])
          .get();
      
      return snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        return {
          'id': doc.id,
          ...data,
        };
      }).toList();
    } catch (e) {
      return [];
    }
  }

  // Background cleanup of expired orders
  Future<void> _cleanupExpiredOrders() async {
    try {
      final now = DateTime.now();
      final QuerySnapshot expiredOrders = await _firestore
          .collection('bookings')
          .where('status', isEqualTo: 'pending')
          .where('isExpired', isEqualTo: false)
          .where('expiryTimestamp', isLessThan: Timestamp.fromDate(now))
          .get();

      for (final doc in expiredOrders.docs) {
        await doc.reference.update({
          'status': 'cancelled',
          'isExpired': true,
          'autoExpired': true,
          'cancelReason': 'Order expired - no washer accepted in time',
          'expiredAt': FieldValue.serverTimestamp(),
          'updatedAt': FieldValue.serverTimestamp(),
        });
      }
    } catch (e) {
      print('Error cleaning up expired orders: $e');
    }
  }

  // Manual cleanup method for admin/background service
  Future<int> checkAndCancelExpiredOrders() async {
    try {
      final now = DateTime.now();
      final QuerySnapshot expiredOrders = await _firestore
          .collection('bookings')
          .where('status', isEqualTo: 'pending')
          .where('isExpired', isEqualTo: false)
          .where('expiryTimestamp', isLessThan: Timestamp.fromDate(now))
          .get();

      int cancelledCount = 0;
      
      for (final doc in expiredOrders.docs) {
        await doc.reference.update({
          'status': 'cancelled',
          'isExpired': true,
          'autoExpired': true,
          'cancelReason': 'Order expired - no washer accepted in time',
          'expiredAt': FieldValue.serverTimestamp(),
          'updatedAt': FieldValue.serverTimestamp(),
        });
        cancelledCount++;
      }
      
      return cancelledCount;
    } catch (e) {
      print('Error in manual cleanup: $e');
      return 0;
    }
  }

  // Get orders expiring soon (for notifications)
  Future<List<Map<String, dynamic>>> getOrdersExpiringSoon({int minutesAhead = 15}) async {
    try {
      final now = DateTime.now();
      final soonTime = now.add(Duration(minutes: minutesAhead));
      
      final QuerySnapshot snapshot = await _firestore
          .collection('bookings')
          .where('status', isEqualTo: 'pending')
          .where('isExpired', isEqualTo: false)
          .where('expiryTimestamp', isGreaterThan: Timestamp.fromDate(now))
          .where('expiryTimestamp', isLessThan: Timestamp.fromDate(soonTime))
          .get();

      return snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        return {
          'id': doc.id,
          ...data,
        };
      }).toList();
    } catch (e) {
      return [];
    }
  }

  // Get orders older than specified days (for history cleanup)
  Future<List<String>> getOldOrderIds({int daysOld = 30}) async {
    try {
      final cutoffDate = DateTime.now().subtract(Duration(days: daysOld));
      
      final QuerySnapshot snapshot = await _firestore
          .collection('bookings')
          .where('createdAt', isLessThan: Timestamp.fromDate(cutoffDate))
          .where('status', whereIn: ['completed', 'cancelled'])
          .get();

      return snapshot.docs.map((doc) => doc.id).toList();
    } catch (e) {
      return [];
    }
  }

  // Archive old orders (move to archive collection)
  Future<int> archiveOldOrders({int daysOld = 30}) async {
    try {
      final oldOrderIds = await getOldOrderIds(daysOld: daysOld);
      int archivedCount = 0;
      
      for (final orderId in oldOrderIds) {
        final orderDoc = await _firestore.collection('bookings').doc(orderId).get();
        if (orderDoc.exists) {
          // Copy to archive
          await _firestore.collection('archivedBookings').doc(orderId).set({
            ...orderDoc.data() as Map<String, dynamic>,
            'archivedAt': FieldValue.serverTimestamp(),
          });
          
          // Delete from main collection
          await _firestore.collection('bookings').doc(orderId).delete();
          archivedCount++;
        }
      }
      
      return archivedCount;
    } catch (e) {
      print('Error archiving old orders: $e');
      return 0;
    }
  }

  // Get washer workload (for smart order distribution)
  Future<Map<String, dynamic>> getWasherWorkload(String washerId) async {
    try {
      final now = DateTime.now();
      
      // Count active orders
      final QuerySnapshot activeOrders = await _firestore
          .collection('bookings')
          .where('washerId', isEqualTo: washerId)
          .where('status', whereIn: ['confirmed', 'in_progress'])
          .get();
      
      // Count ASAP orders
      final QuerySnapshot asapOrders = await _firestore
          .collection('bookings')
          .where('washerId', isEqualTo: washerId)
          .where('isASAP', isEqualTo: true)
          .where('status', whereIn: ['confirmed', 'in_progress'])
          .get();
      
      // Count orders completed today
      final todayStart = DateTime(now.year, now.month, now.day);
      final QuerySnapshot todayCompleted = await _firestore
          .collection('bookings')
          .where('washerId', isEqualTo: washerId)
          .where('status', isEqualTo: 'completed')
          .where('completedAt', isGreaterThan: Timestamp.fromDate(todayStart))
          .get();
      
      return {
        'activeOrders': activeOrders.docs.length,
        'hasActiveASAP': asapOrders.docs.isNotEmpty,
        'todayCompleted': todayCompleted.docs.length,
        'canAcceptASAP': asapOrders.docs.isEmpty,
        'workloadScore': _calculateWorkloadScore(
          activeOrders.docs.length,
          asapOrders.docs.isNotEmpty,
          todayCompleted.docs.length,
        ),
      };
    } catch (e) {
      return {
        'activeOrders': 0,
        'hasActiveASAP': false,
        'todayCompleted': 0,
        'canAcceptASAP': true,
        'workloadScore': 0,
      };
    }
  }

  // Calculate workload score for smart distribution
  int _calculateWorkloadScore(int activeOrders, bool hasActiveASAP, int todayCompleted) {
    int score = 0;
    score += activeOrders * 10; // Each active order adds 10 points
    score += hasActiveASAP ? 20 : 0; // ASAP order adds 20 points
    score += todayCompleted * 2; // Each completed today adds 2 points
    return score;
  }

  // Get nearby washers for order (placeholder for location-based matching)
  Future<List<Map<String, dynamic>>> getNearbyAvailableWashers({
    required double latitude,
    required double longitude,
    double radiusKm = 10.0,
    bool asapOnly = false,
  }) async {
    try {
      // This is a basic implementation. For production, use GeoPoint queries
      final QuerySnapshot snapshot = await _firestore
          .collection('users')
          .where('userType', isEqualTo: 'washer')
          .where('isOnline', isEqualTo: true)
          .where('isVerified', isEqualTo: true)
          .get();

      List<Map<String, dynamic>> availableWashers = [];
      
      for (final doc in snapshot.docs) {
        final washerData = doc.data() as Map<String, dynamic>;
        final washerId = doc.id;
        
        // Check workload
        final workload = await getWasherWorkload(washerId);
        
        // Skip if can't accept ASAP and this is an ASAP order
        if (asapOnly && !workload['canAcceptASAP']) {
          continue;
        }
        
        availableWashers.add({
          'id': washerId,
          'name': washerData['fullName'] ?? 'Washer',
          'rating': washerData['rating'] ?? 0.0,
          'washerType': washerData['washerType'] ?? 'everyday',
          'workload': workload,
          ...washerData,
        });
      }
      
      // Sort by workload score (lower is better) and rating (higher is better)
      availableWashers.sort((a, b) {
        final aScore = a['workload']['workloadScore'] ?? 100;
        final bScore = b['workload']['workloadScore'] ?? 100;
        
        if (aScore != bScore) {
          return aScore.compareTo(bScore);
        }
        
        final aRating = a['rating'] ?? 0.0;
        final bRating = b['rating'] ?? 0.0;
        return bRating.compareTo(aRating);
      });
      
      return availableWashers;
    } catch (e) {
      return [];
    }
  }
}