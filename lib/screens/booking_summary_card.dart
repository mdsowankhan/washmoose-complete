import 'package:flutter/material.dart';

class BookingSummaryCard extends StatelessWidget {
  final String vehicleType;
  final String package;
  final List<String> addOns;
  final int totalPrice;
  final int totalDuration;
  final String? date;
  final String? time;
  final VoidCallback onBookPressed;

  const BookingSummaryCard({
    super.key,
    required this.vehicleType,
    required this.package,
    required this.addOns,
    required this.totalPrice,
    required this.totalDuration,
    this.date,
    this.time,
    required this.onBookPressed,
  });

  @override
  Widget build(BuildContext context) {
    final primaryColor = Theme.of(context).primaryColor;
    
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Theme.of(context).dividerColor),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Booking Summary',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            Divider(color: Theme.of(context).dividerColor, height: 24),
            _buildSummaryRow(context, 'Vehicle', vehicleType),
            _buildSummaryRow(context, 'Package', package),
            _buildSummaryRow(
              context, 
              'Add-ons', 
              addOns.isEmpty ? 'None' : addOns.join(', ')
            ),
            if (date != null && time != null)
              _buildSummaryRow(context, 'Booking', '$date at $time'),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Total', style: Theme.of(context).textTheme.titleLarge),
                RichText(
                  text: TextSpan(
                    style: Theme.of(context).textTheme.titleLarge,
                    children: [
                      TextSpan(
                        text: '\$$totalPrice',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).colorScheme.secondary,
                          fontSize: 22,
                        ),
                      ),
                      TextSpan(
                        text: ' • $totalDuration min',
                        style: TextStyle(
                          fontSize: 16,
                          color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: date != null && time != null
                    ? onBookPressed
                    : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.tertiary,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                child: const Text(
                  'Book Now',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryRow(BuildContext context, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '$label:',
            style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                  fontWeight: FontWeight.w500,
                ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: Theme.of(context).textTheme.bodyLarge,
            ),
          ),
        ],
      ),
    );
  }
}