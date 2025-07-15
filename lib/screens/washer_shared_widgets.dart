import 'package:flutter/material.dart';

mixin WasherSharedWidgets<T extends StatefulWidget> on State<T> {
  // Access to main widget properties and state
  bool get isExpertMoose;

  // Access to logic methods
  Future<void> callCustomer(String phoneNumber);
  double calculateWasherEarnings(double totalPrice);

  Widget buildJobTypeChip(String packageName) {
    final packageLower = packageName.toLowerCase();
    Color chipColor;
    String chipText;

    if (packageLower.contains('detail') || packageLower.contains('premium')) {
      chipColor = Colors.amber;
      chipText = 'DETAIL';
    } else if (packageLower.contains('custom')) {
      chipColor = Colors.purple;
      chipText = 'CUSTOM';
    } else {
      chipColor = const Color(0xFF00C2CB);
      chipText = 'REGULAR';
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: chipColor.withOpacity(0.2),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: chipColor),
      ),
      child: Text(
        chipText,
        style: TextStyle(
          color: chipColor,
          fontSize: 10,
          fontWeight: FontWeight.bold,
        ),
        overflow: TextOverflow.ellipsis,
      ),
    );
  }

  Widget buildDetailRow(IconData icon, String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 16, color: const Color(0xFF4A5568)), // ✅ FIXED: Darker icon color
        const SizedBox(width: 8),
        Text(
          '$label:',
          style: const TextStyle(
            color: Color(0xFF4A5568), // ✅ FIXED: Darker label text
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(color: Color(0xFF1A202C), fontSize: 14), // ✅ FIXED: Dark text
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  // Enhanced Job Details Dialog
  void showJobDetails(BuildContext context, Map<String, dynamic> job) {
    final orderNumber = generateOrderNumber(job['id'] ?? 'unknown');
    final packageName = job['packageName'] ?? 'Unknown Package';
    final customerName = job['customerName'] ?? 'Customer';
    final vehicleType = job['vehicleType'] ?? 'Unknown Vehicle';
    final location = job['location'] ?? 'Unknown Location';
    final fullAddress = job['fullAddress'] ?? location;
    final date = job['date'] ?? 'Unknown Date';
    final time = job['time'] ?? 'Unknown Time';
    final price = (job['totalPrice'] ?? 0.0).toDouble();
    final duration = job['duration'] ?? 0;
    final addOns = job['addOns'] as List<dynamic>? ?? [];
    final specialInstructions = job['specialInstructions'] ?? '';
    final customRequests = job['customRequests'] ?? '';
    final customerPhone = job['customerPhone'] ?? '';

    final washerEarnings = calculateWasherEarnings(price);

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: const Color(0xFFFFFFFF), // ✅ FIXED: White dialog background
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Row(
            children: [
              Flexible(
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFF00C2CB).withOpacity(0.2),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: const Color(0xFF00C2CB)),
                  ),
                  child: Text(
                    orderNumber,
                    style: const TextStyle(
                      color: Color(0xFF00C2CB),
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Text(
                  'Order Details',
                  style: TextStyle(
                    color: Color(0xFF1A202C), // ✅ FIXED: Dark title text
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                buildDetailRowDialog('Service', packageName),
                buildDetailRowDialog('Vehicle', vehicleType),
                buildDetailRowDialog('Customer', customerName),
                buildDetailRowDialog('Location', location),
                buildDetailRowDialog('Full Address', fullAddress),
                buildDetailRowDialog('Date & Time', '$date at $time'),
                buildDetailRowDialog('Duration', '$duration minutes'),
                if (customerPhone.isNotEmpty)
                  buildDetailRowDialog('Phone', customerPhone),
                if (addOns.isNotEmpty)
                  buildDetailRowDialog('Add-ons', addOns.join(', ')),
                if (specialInstructions.isNotEmpty)
                  buildDetailRowDialog(
                    'Special Instructions',
                    specialInstructions,
                  ),
                if (customRequests.isNotEmpty)
                  buildDetailRowDialog('Custom Requests', customRequests),

                const SizedBox(height: 16),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Colors.green.withOpacity(0.1), // ✅ FIXED: Lighter gradient for light theme
                        Colors.green.withOpacity(0.05),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.green.withOpacity(0.3)),
                  ),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Flexible(
                            child: Text(
                              'Total Price:',
                              style: TextStyle(
                                color: Color(0xFF4A5568), // ✅ FIXED: Darker text
                                fontSize: 14,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          Text(
                            '\$${price.toStringAsFixed(2)}',
                            style: const TextStyle(
                              color: Color(0xFF1A202C), // ✅ FIXED: Dark text
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Flexible(
                            child: Text(
                              'Your Earnings:',
                              style: TextStyle(
                                color: Colors.green,
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          Text(
                            '\$${washerEarnings.toStringAsFixed(2)}',
                            style: const TextStyle(
                              color: Colors.green,
                              fontWeight: FontWeight.bold,
                              fontSize: 20,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        isExpertMoose
                            ? 'You keep 90% (Expert Moose rate)'
                            : 'You keep 85% (Everyday Moose rate)',
                        style: const TextStyle(color: Color(0xFF718096), fontSize: 12), // ✅ FIXED: Readable grey
                        textAlign: TextAlign.center,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Close', style: TextStyle(color: Color(0xFF4A5568))), // ✅ FIXED: Darker text
            ),
            if (customerPhone.isNotEmpty)
              ElevatedButton.icon(
                onPressed: () {
                  Navigator.of(context).pop();
                  callCustomer(customerPhone);
                },
                icon: const Icon(Icons.phone),
                label: const Text('Call Customer'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                ),
              ),
          ],
        );
      },
    );
  }

  Widget buildDetailRowDialog(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              '$label:',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: Color(0xFF4A5568), // ✅ FIXED: Darker label text
                fontSize: 14,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(color: Color(0xFF1A202C), fontSize: 14), // ✅ FIXED: Dark value text
              maxLines: 5,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  // Access to logic methods that need to be implemented in main class
  String generateOrderNumber(String bookingId);

  // Method name getters to ensure compatibility
  Widget _buildJobTypeChip(String packageName) => buildJobTypeChip(packageName);
  Widget _buildDetailRow(IconData icon, String label, String value) =>
      buildDetailRow(icon, label, value);
  void _showJobDetails(BuildContext context, Map<String, dynamic> job) =>
      showJobDetails(context, job);
  Widget _buildDetailRowDialog(String label, String value) =>
      buildDetailRowDialog(label, value);
}