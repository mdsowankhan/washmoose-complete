import 'package:flutter/material.dart';
import 'payment_deposit_page.dart';
import 'app_theme.dart';

class SummaryScreen extends StatelessWidget {
  final String vehicleType;
  final String packageName;
  final List<String> addOns;
  final String date;
  final String time;
  final double totalPrice;
  final int duration;
  final String serviceType;
  final String address;
  final String specialInstructions;
  final bool isASAP; // ✅ NEW: Add isASAP parameter

  const SummaryScreen({
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

  // ✅ ENHANCED: Pass isASAP to DepositPaymentPage
  void _navigateToPayment(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => DepositPaymentPage(
          vehicleType: vehicleType,
          packageName: packageName,
          addOns: addOns,
          date: date,
          time: time,
          totalPrice: totalPrice,
          duration: duration,
          serviceType: serviceType,
          address: address,
          specialInstructions: specialInstructions,
          isASAP: isASAP, // ✅ NEW: Pass isASAP to payment page
        ),
      ),
    );
  }

  Widget _buildSummaryRow(BuildContext context, String label, String value, {bool isPrice = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: TextStyle(
                color: const Color(0xFF4A5568), // ✅ MUCH DARKER - was barely visible
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Text(
            ': ',
            style: TextStyle(
              color: const Color(0xFF4A5568), // ✅ DARKER
              fontSize: 16,
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                color: isPrice 
                  ? const Color(0xFF00C2CB) 
                  : const Color(0xFF1A202C), // ✅ MUCH DARKER - readable black text
                fontWeight: isPrice ? FontWeight.bold : FontWeight.w500,
                fontSize: isPrice ? 18 : 16,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final Color serviceColor = serviceType == 'regular' 
        ? AppTheme.primaryColor 
        : Colors.green;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Booking Summary'),
        backgroundColor: serviceColor,
        foregroundColor: Colors.white,
      ),
      // ✅ FIXED: Remove hardcoded dark gradient, use theme background
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ✅ IMPROVED: Header with theme colors
                    Center(
                      child: Column(
                        children: [
                          Icon(
                            Icons.assignment_turned_in,
                            color: serviceColor,
                            size: 48,
                          ),
                          const SizedBox(height: 12),
                          Text(
                            'Booking Summary',
                            style: Theme.of(context).textTheme.displaySmall?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: const Color(0xFF1A202C), // ✅ DARK TEXT
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Please review your booking details',
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              color: const Color(0xFF2D3748), // ✅ DARKER - was too light
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                    
                    const SizedBox(height: 32),
                    
                    // ✅ IMPROVED: ASAP Status Banner with better readability
                    if (isASAP) ...[
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.amber.withOpacity(0.1),
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
                                    'ASAP Service Request',
                                    style: TextStyle(
                                      color: Colors.amber,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 18,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    'Your booking will be prioritized and assigned to an available washer as soon as possible.',
                                    style: TextStyle(
                                      color: const Color(0xFF2D3748), // ✅ DARKER TEXT
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
                    
                    // ✅ FIXED: Service Details Card with theme colors
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.surface,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: serviceColor.withOpacity(0.3)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Service Details',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: serviceColor,
                            ),
                          ),
                          const SizedBox(height: 16),
                          _buildSummaryRow(context, 'Vehicle', vehicleType),
                          _buildSummaryRow(context, 'Package', packageName),
                          if (addOns.isNotEmpty)
                            _buildSummaryRow(context, 'Add-ons', addOns.join(', ')),
                          _buildSummaryRow(context, 'Duration', '$duration minutes'),
                        ],
                      ),
                    ),
                    
                    const SizedBox(height: 16),
                    
                    // ✅ FIXED: Schedule Details Card
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.surface,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: serviceColor.withOpacity(0.3)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Schedule Details',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: serviceColor,
                            ),
                          ),
                          const SizedBox(height: 16),
                          _buildSummaryRow(context, 'Date', date),
                          if (time.isNotEmpty)
                            _buildSummaryRow(context, 'Time', time),
                          _buildSummaryRow(context, 'Service Type', isASAP ? 'ASAP Service' : 'Scheduled Service'),
                        ],
                      ),
                    ),
                    
                    const SizedBox(height: 16),
                    
                    // ✅ FIXED: Location Details Card
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.surface,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: serviceColor.withOpacity(0.3)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Location Details',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: serviceColor,
                            ),
                          ),
                          const SizedBox(height: 16),
                          _buildSummaryRow(context, 'Address', address),
                          if (specialInstructions.isNotEmpty)
                            _buildSummaryRow(context, 'Instructions', specialInstructions),
                        ],
                      ),
                    ),
                    
                    const SizedBox(height: 24),
                    
                    // ✅ IMPROVED: Total Price Card with better contrast
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: serviceColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: serviceColor, width: 2),
                      ),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Total Amount',
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: const Color(0xFF1A202C), // ✅ DARK TEXT
                                ),
                              ),
                              Text(
                                '\${totalPrice.toStringAsFixed(2)}',
                                style: TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                  color: serviceColor,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Service Duration:',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: const Color(0xFF4A5568), // ✅ DARKER
                                ),
                              ),
                              Text(
                                '$duration minutes',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: const Color(0xFF4A5568), // ✅ DARKER
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    
                    const SizedBox(height: 24),
                    
                    // ✅ IMPROVED: Important Notice with better readability
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.blue.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.blue.withOpacity(0.3)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Row(
                            children: [
                              Icon(Icons.info, color: Colors.blue, size: 20),
                              SizedBox(width: 8),
                              Text(
                                'Important Information',
                                style: TextStyle(
                                  color: Colors.blue,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Text(
                            '• Ensure water and power access are available\n• Payment can be made as deposit or full amount\n• Our professional washers bring all cleaning supplies\n• You\'ll receive updates on washer assignment and arrival',
                            style: TextStyle(
                              color: const Color(0xFF2D3748), // ✅ MUCH DARKER - was barely visible
                              fontSize: 14,
                              height: 1.5,
                            ),
                          ),
                          if (isASAP) ...[
                            const SizedBox(height: 8),
                            const Text(
                              '• ASAP requests are prioritized and typically assigned within 1 hour\n• You\'ll be notified immediately when a washer accepts your request',
                              style: TextStyle(
                                color: Colors.amber,
                                fontSize: 14,
                                height: 1.5,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            
            // ✅ BUTTON: Already using good colors
            Container(
              padding: const EdgeInsets.all(20),
              child: SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: () => _navigateToPayment(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: serviceColor,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    isASAP ? 'CONTINUE TO PAYMENT - ASAP' : 'CONTINUE TO PAYMENT',
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