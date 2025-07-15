import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import '../services/booking_service.dart';
import '../services/database_service.dart';
import 'payment_success_page.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class DepositPaymentPage extends StatefulWidget {
  final String vehicleType;
  final String packageName;
  final List<String> addOns;
  final String date;
  final String time;
  final double totalPrice;
  final int duration;
  final String serviceType; // 'regular' or 'detail'
  final String address;
  final String specialInstructions;
  final bool isASAP; // ✅ NEW: Add isASAP parameter

  const DepositPaymentPage({
    super.key,
    required this.vehicleType,
    required this.packageName,
    required this.addOns,
    required this.date,
    required this.time,
    required this.totalPrice,
    required this.duration,
    required this.serviceType,
    required this.address,
    required this.specialInstructions,
    required this.isASAP, // ✅ NEW: Required isASAP parameter
  });

  @override
  State<DepositPaymentPage> createState() => _DepositPaymentPageState();
}

class _DepositPaymentPageState extends State<DepositPaymentPage> {
  final BookingService _bookingService = BookingService();
  final DatabaseService _databaseService = DatabaseService();
  
  bool _isProcessing = false;
  String _paymentOption = 'deposit'; // 'deposit' or 'full'
  String _paymentMethod = 'card'; // 'card', 'paypal'

  @override
  void initState() {
    super.initState();
    // Set Stripe publishable key here!
    Stripe.publishableKey = 'pk_test_51R1MSdFz5Fa2qAgkvOcPxbxjVtbWtaoGazib8CwOxfyiTHmE302AZLWPhlrk7aDDtXf5JHKhSd1l0edUAxeeR38300bg7lQLNr';
    Stripe.merchantIdentifier = 'merchant.com.example.washmoose_v2test';
  }
  
  // Calculate deposit amounts - $10 regular, $20 detail
  double get depositAmount {
    return widget.serviceType == 'detail' ? 20.0 : 10.0;
  }
  
  double get paymentAmount {
    return _paymentOption == 'deposit' ? depositAmount : widget.totalPrice;
  }
  
  double get remainingAmount {
    return _paymentOption == 'deposit' ? (widget.totalPrice - depositAmount) : 0.0;
  }

  // ✅ UPDATED: Secure PaymentIntent creation using backend
  Future<Map<String, dynamic>> _createPaymentIntent(double amount) async {
    try {
      final url = Uri.parse('http://10.0.2.2:3000/create-payment-intent');
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'amount': (amount * 100).toInt(),

          'currency': 'aud',
          'metadata': {
            'vehicleType': widget.vehicleType,
            'packageName': widget.packageName,
            'serviceType': widget.serviceType,
            'isASAP': widget.isASAP,
            'app': 'washmoose_flutter',
          }
        }),
      );

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        return {
          'client_secret': responseData['clientSecret'],
          'id': responseData['paymentIntentId'],
        };
      } else {
        final errorData = jsonDecode(response.body);
        throw Exception(errorData['error'] ?? 'Failed to create payment intent');
      }
    } catch (e) {
      print('Payment Intent Error: $e');
      throw Exception('Failed to connect to payment server. Please check your connection.');
    }
  }

  // Handle payment processing - UPDATED FOR STRIPE
  Future<void> _processPayment() async {
    if (_isProcessing) return;
    
    setState(() {
      _isProcessing = true;
    });

    try {
      switch (_paymentMethod) {
        case 'card':
          await _processStripePayment();
          break;
        case 'paypal':
          _showPayPalNotAvailableMessage();
          break;
      }
    } catch (e) {
      _showErrorDialog('Payment failed: ${e.toString()}');
    } finally {
      setState(() {
        _isProcessing = false;
      });
    }
  }

  // NEW: Process Stripe Payment
  Future<void> _processStripePayment() async {
    try {
      // Step 1: Create PaymentIntent
      final paymentIntent = await _createPaymentIntent(paymentAmount);

      // Step 2: Initialize payment sheet
      await Stripe.instance.initPaymentSheet(
        paymentSheetParameters: SetupPaymentSheetParameters(
          paymentIntentClientSecret: paymentIntent['client_secret'],
          style: ThemeMode.light, // ✅ CHANGED: Light theme for Stripe payment sheet
          merchantDisplayName: 'WashMoose',
        ),
      );

      // Step 3: Present payment sheet to user
      await Stripe.instance.presentPaymentSheet();

      // Step 4: Success! Create booking
      await _createBooking('stripe');

    } on StripeException catch (e) {
      _showErrorDialog(e.error.message ?? 'Payment cancelled.');
    }
  }

  void _showPayPalNotAvailableMessage() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFFFFFFFF), // ✅ CHANGED: White background
        title: const Text('PayPal Payment', style: TextStyle(color: Color(0xFF1A202C))), // ✅ CHANGED: Dark text
        content: const Text(
          'PayPal integration is temporarily disabled. Please use card payment.',
          style: TextStyle(color: Color(0xFF4A5568)), // ✅ CHANGED: Dark text
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              setState(() {
                _paymentMethod = 'card';
              });
            },
            child: const Text('Use Card'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }

  // ✅ ENHANCED: Create booking with isASAP parameter
  Future<void> _createBooking(String paymentMethod) async {
    try {
      final bookingId = await _bookingService.createBooking(
        vehicleType: widget.vehicleType,
        packageName: widget.packageName,
        addOns: widget.addOns,
        date: widget.date,
        time: widget.time,
        totalPrice: widget.totalPrice,
        duration: widget.duration,
        location: widget.address,
        isASAP: widget.isASAP, // ✅ NEW: Pass isASAP to booking service
      );

      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => PaymentSuccessPage(
              bookingId: bookingId,
              depositAmount: _paymentOption == 'deposit' ? depositAmount : widget.totalPrice,
              remainingAmount: remainingAmount,
              scheduledDate: widget.date,
              scheduledTime: widget.time,
              isFullPayment: _paymentOption == 'full',
              isASAP: widget.isASAP,
            ),
          ),
        );
      }
    } catch (e) {
      _showErrorDialog('Failed to create booking: ${e.toString()}');
    }
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFFFFFFFF), // ✅ CHANGED: White background
        title: const Text('Payment Error', style: TextStyle(color: Color(0xFF1A202C))), // ✅ CHANGED: Dark text
        content: Text(message, style: const TextStyle(color: Color(0xFF4A5568))), // ✅ CHANGED: Dark text
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentOptionCard(String value, String title, String subtitle, double amount) {
    final bool isSelected = _paymentOption == value;
    const serviceColor = Color(0xFF00C2CB);
    
    return GestureDetector(
      onTap: () {
        setState(() {
          _paymentOption = value;
        });
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected ? serviceColor.withOpacity(0.1) : const Color(0xFFFFFFFF), // ✅ CHANGED: White background
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? serviceColor : const Color(0xFFE2E8F0), // ✅ CHANGED: Light border
            width: isSelected ? 2 : 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04), // ✅ CHANGED: Subtle shadow
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Radio<String>(
              value: value,
              groupValue: _paymentOption,
              onChanged: (String? newValue) {
                setState(() {
                  _paymentOption = newValue!;
                });
              },
              activeColor: serviceColor,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      color: isSelected ? serviceColor : const Color(0xFF1A202C), // ✅ CHANGED: Dark text
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      color: Color(0xFF4A5568), // ✅ CHANGED: Dark text
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '\$${amount.toStringAsFixed(2)}',
                  style: TextStyle(
                    color: isSelected ? serviceColor : const Color(0xFF1A202C), // ✅ CHANGED: Dark text
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
                if (value == 'deposit' && remainingAmount > 0)
                  Text(
                    'Remaining: \$${remainingAmount.toStringAsFixed(2)}',
                    style: const TextStyle(
                      color: Color(0xFF4A5568), // ✅ CHANGED: Dark text
                      fontSize: 12,
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPaymentMethodCard(String value, String title, IconData icon, {bool enabled = true}) {
    final bool isSelected = _paymentMethod == value;
    const serviceColor = Color(0xFF00C2CB);
    
    return GestureDetector(
      onTap: enabled ? () {
        setState(() {
          _paymentMethod = value;
        });
      } : null,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected ? serviceColor.withOpacity(0.1) : const Color(0xFFFFFFFF), // ✅ CHANGED: White background
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? serviceColor : const Color(0xFFE2E8F0), // ✅ CHANGED: Light border
            width: isSelected ? 2 : 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04), // ✅ CHANGED: Subtle shadow
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Radio<String>(
              value: value,
              groupValue: _paymentMethod,
              onChanged: enabled ? (String? newValue) {
                setState(() {
                  _paymentMethod = newValue!;
                });
              } : null,
              activeColor: serviceColor,
            ),
            const SizedBox(width: 12),
            Icon(icon, color: isSelected ? serviceColor : const Color(0xFF4A5568)), // ✅ CHANGED: Dark icon
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  color: enabled ? (isSelected ? serviceColor : const Color(0xFF1A202C)) : const Color(0xFF9CA3AF), // ✅ CHANGED: Dark text
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ),
            if (!enabled)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFF9CA3AF).withOpacity(0.2), // ✅ CHANGED: Light grey
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Text(
                  'Coming Soon',
                  style: TextStyle(
                    color: Color(0xFF9CA3AF), // ✅ CHANGED: Light grey text
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    const serviceColor = Color(0xFF00C2CB);
    
    return Scaffold(
      backgroundColor: const Color(0xFFFAFBFC), // ✅ CHANGED: Light background
      appBar: AppBar(
        title: const Text('Payment'),
        backgroundColor: serviceColor,
        foregroundColor: Colors.white,
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header
                    Center(
                      child: Column(
                        children: [
                          Icon(
                            Icons.payment,
                            color: serviceColor,
                            size: 48,
                          ),
                          const SizedBox(height: 12),
                          Text(
                            widget.isASAP ? 'Complete ASAP Payment' : 'Complete Payment',
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF1A202C), // ✅ CHANGED: Dark text
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            'Choose your payment method and complete booking',
                            style: TextStyle(
                              fontSize: 16,
                              color: Color(0xFF4A5568), // ✅ CHANGED: Dark text
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                    
                    const SizedBox(height: 32),
                    
                    // ✅ NEW: ASAP Priority Banner
                    if (widget.isASAP) ...[
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.amber.withOpacity(0.1), // ✅ CHANGED: Lighter amber background
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.amber, width: 2),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.flash_on, color: Colors.amber, size: 24),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'ASAP Priority Service',
                                    style: TextStyle(
                                      color: Colors.amber,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  const Text(
                                    'Your booking will be assigned to an available washer immediately after payment.',
                                    style: TextStyle(
                                      color: Color(0xFF4A5568), // ✅ CHANGED: Dark text for readability
                                      fontSize: 14,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),
                    ],
                    
                    // Payment Options Section
                    const Text(
                      'Payment Options',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1A202C), // ✅ CHANGED: Dark text
                      ),
                    ),
                    const SizedBox(height: 16),
                    
                    // Deposit Option
                    _buildPaymentOptionCard(
                      'deposit',
                      'Pay Deposit Now',
                      'Pay remaining balance after service completion',
                      depositAmount,
                    ),
                    
                    // Full Payment Option
                    _buildPaymentOptionCard(
                      'full',
                      'Pay Full Amount',
                      'Pay the complete amount upfront',
                      widget.totalPrice,
                    ),
                    
                    const SizedBox(height: 24),
                    
                    // Payment Methods Section
                    const Text(
                      'Payment Method',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1A202C), // ✅ CHANGED: Dark text
                      ),
                    ),
                    const SizedBox(height: 16),
                    
                    // Card Payment
                    _buildPaymentMethodCard(
                      'card',
                      'Credit/Debit Card',
                      Icons.credit_card,
                    ),
                    
                    // PayPal Payment (disabled)
                    _buildPaymentMethodCard(
                      'paypal',
                      'PayPal',
                      Icons.account_balance_wallet,
                      enabled: false,
                    ),
                    
                    const SizedBox(height: 24),
                    
                    // ✅ NEW: Stripe Security Notice (replaces custom card form)
                    if (_paymentMethod == 'card') ...[
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: serviceColor.withOpacity(0.05), // ✅ CHANGED: Much lighter background
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: serviceColor.withOpacity(0.3)),
                        ),
                        child: Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.security, color: serviceColor, size: 24),
                                const SizedBox(width: 8),
                                Text(
                                  'Secure Payment with Stripe',
                                  style: TextStyle(
                                    color: serviceColor,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 18,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            const Text(
                              'When you click "Complete Payment", you\'ll be redirected to Stripe\'s secure payment page to enter your card details safely.',
                              style: TextStyle(
                                color: Color(0xFF1A202C), // ✅ CHANGED: Dark text
                                fontSize: 15,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 16),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                  decoration: BoxDecoration(
                                    color: Colors.green.withOpacity(0.1), // ✅ CHANGED: Lighter green
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(color: Colors.green),
                                  ),
                                  child: const Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(Icons.verified_user, color: Colors.green, size: 16),
                                      SizedBox(width: 6),
                                      Text(
                                        'PCI DSS Compliant',
                                        style: TextStyle(
                                          color: Colors.green,
                                          fontSize: 12,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                  decoration: BoxDecoration(
                                    color: Colors.blue.withOpacity(0.1), // ✅ CHANGED: Lighter blue
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(color: Colors.blue),
                                  ),
                                  child: const Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(Icons.lock, color: Colors.blue, size: 16),
                                      SizedBox(width: 6),
                                      Text(
                                        'SSL Encrypted',
                                        style: TextStyle(
                                          color: Colors.blue,
                                          fontSize: 12,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),
                    ],
                    
                    // ✅ FIXED: Payment Summary with corrected string interpolation
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: serviceColor.withOpacity(0.05), // ✅ CHANGED: Much lighter background
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: serviceColor, width: 2),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Payment Summary',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: serviceColor,
                            ),
                          ),
                          const SizedBox(height: 16),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                'Service Total:',
                                style: TextStyle(color: Color(0xFF4A5568), fontSize: 16), // ✅ CHANGED: Dark text
                              ),
                              Text(
                                '\$${widget.totalPrice.toStringAsFixed(2)}',
                                style: const TextStyle(color: Color(0xFF1A202C), fontSize: 16), // ✅ CHANGED: Dark text
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                _paymentOption == 'deposit' ? 'Paying Now (Deposit):' : 'Paying Now (Full):',
                                style: const TextStyle(color: Color(0xFF1A202C), fontSize: 16, fontWeight: FontWeight.bold), // ✅ CHANGED: Dark text
                              ),
                              Text(
                                '\$${paymentAmount.toStringAsFixed(2)}',
                                style: TextStyle(
                                  color: serviceColor,
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          if (_paymentOption == 'deposit' && remainingAmount > 0) ...[
                            const SizedBox(height: 8),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text(
                                  'Remaining (After Service):',
                                  style: TextStyle(color: Color(0xFF4A5568), fontSize: 14), // ✅ CHANGED: Dark text
                                ),
                                Text(
                                  '\$${remainingAmount.toStringAsFixed(2)}',
                                  style: const TextStyle(color: Color(0xFF4A5568), fontSize: 14), // ✅ CHANGED: Dark text
                                ),
                              ],
                            ),
                          ],
                        ],
                      ),
                    ),
                    
                    const SizedBox(height: 24),
                    
                    // Additional Security Notice
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.green.withOpacity(0.05), // ✅ CHANGED: Much lighter green
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.green.withOpacity(0.3)),
                      ),
                      child: const Row(
                        children: [
                          Icon(Icons.shield, color: Colors.green, size: 20),
                          SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              'WashMoose uses Stripe for secure payments. Your card details are never stored on our servers.',
                              style: TextStyle(
                                color: Color(0xFF4A5568), // ✅ CHANGED: Dark text for readability
                                fontSize: 14,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            
            // ✅ FIXED: Complete Payment Button with corrected string interpolation
            Container(
              padding: const EdgeInsets.all(20),
              decoration: const BoxDecoration(
                color: Color(0xFFFFFFFF), // ✅ CHANGED: White background for button area
                border: Border(
                  top: BorderSide(color: Color(0xFFE2E8F0), width: 1), // ✅ CHANGED: Light border
                ),
              ),
              child: SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _isProcessing ? null : _processPayment,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _isProcessing ? const Color(0xFF9CA3AF) : serviceColor, // ✅ CHANGED: Light grey when disabled
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: _isProcessing ? 0 : 2, // ✅ CHANGED: Add elevation when active
                  ),
                  child: _isProcessing
                      ? const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                              ),
                            ),
                            SizedBox(width: 12),
                            Text('Processing...'),
                          ],
                        )
                      : Text(
                          widget.isASAP 
                              ? 'COMPLETE ASAP PAYMENT - \$${paymentAmount.toStringAsFixed(2)}'
                              : 'COMPLETE PAYMENT - \$${paymentAmount.toStringAsFixed(2)}',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}