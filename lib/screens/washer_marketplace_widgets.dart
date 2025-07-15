import 'package:flutter/material.dart';

mixin WasherMarketplaceWidgets<T extends StatefulWidget> on State<T> {
  // Access to main widget properties and state
  List<Map<String, dynamic>> get marketplaceBookings;

  // Access to logic methods
  Future<void> acceptBooking(String bookingId);
  Future<void> completeBooking(String bookingId);
  Future<void> callCustomer(String phoneNumber);
  Color getStatusColor(String status);
  String generateOrderNumber(String bookingId);
  double calculateWasherEarnings(double totalPrice);
  
  // ✅ NEW: Add shared widget methods here
  Widget buildDetailRow(IconData icon, String label, String value);
  void showJobDetails(BuildContext context, Map<String, dynamic> job);

  // Enhanced Marketplace Jobs List (for Expert Moose)
  Widget buildMarketplaceJobsList() {
    if (marketplaceBookings.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.store_outlined, size: 64, color: Colors.amber),
            const SizedBox(height: 16),
            const Text(
              'No marketplace jobs yet',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 8),
            Text(
              'Custom jobs from the marketplace will appear here',
              style: TextStyle(fontSize: 16, color: Colors.grey[500]),
              textAlign: TextAlign.center,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () async {
        setState(() {
          // isLoadingMarketplace = true; // This should be handled in the main class
        });
        // loadMarketplaceBookings(); // This should be called from the main class
      },
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: marketplaceBookings.length,
        itemBuilder: (context, index) {
          final job = marketplaceBookings[index];
          return buildMarketplaceJobCard(job);
        },
      ),
    );
  }

  Widget buildMarketplaceJobCard(Map<String, dynamic> job) {
    final jobId = job['id'] ?? 'unknown';
    final orderNumber = generateOrderNumber(jobId);
    final vehicleType = job['vehicleType'] ?? 'Unknown Vehicle';
    final packageName = job['packageName'] ?? 'Unknown Package';
    final customerName = job['customerName'] ?? 'Customer';
    final location = job['location'] ?? 'Unknown Location';
    final fullAddress = job['fullAddress'] ?? location;
    final date = job['date'] ?? 'Unknown Date';
    final time = job['time'] ?? 'Unknown Time';
    final price = (job['totalPrice'] ?? 0.0).toDouble();
    final duration = job['duration'] ?? 0;
    final status = job['status'] ?? 'pending';
    final customerPhone = job['customerPhone'] ?? '';
    final customRequests = job['customRequests'] ?? '';

    final washerEarnings = calculateWasherEarnings(price);
    final isPending = status == 'pending';
    final isCompleted = status == 'completed';

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: Colors.amber.withOpacity(0.5), width: 2),
      ),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Colors.amber[900]!.withOpacity(0.2), Colors.grey[900]!],
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header with marketplace indicator
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Flexible(
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.amber.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: Colors.amber),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.store,
                            size: 14,
                            color: Colors.amber,
                          ),
                          const SizedBox(width: 4),
                          Flexible(
                            child: Text(
                              orderNumber,
                              style: const TextStyle(
                                color: Colors.amber,
                                fontWeight: FontWeight.bold,
                                fontSize: 13,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Flexible(
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: getStatusColor(status).withOpacity(0.2),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: getStatusColor(status)),
                      ),
                      child: Text(
                        status.substring(0, 1).toUpperCase() +
                            status.substring(1),
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: getStatusColor(status),
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Job details
              Text(
                packageName,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 4),
              Text(
                vehicleType,
                style: TextStyle(fontSize: 16, color: Colors.grey[400]),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 16),

              // Customer and service info
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  children: [
                    buildDetailRow(Icons.person, 'Customer', customerName),
                    const SizedBox(height: 8),
                    buildDetailRow(Icons.location_on, 'Location', location),
                    const SizedBox(height: 8),
                    buildDetailRow(Icons.home, 'Address', fullAddress),
                    const SizedBox(height: 8),
                    buildDetailRow(
                      Icons.access_time,
                      'Schedule',
                      '$date at $time',
                    ),
                    if (customRequests.isNotEmpty) ...[
                      const SizedBox(height: 8),
                      buildDetailRow(
                        Icons.build,
                        'Custom Requests',
                        customRequests,
                      ),
                    ],
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // Premium earnings display
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Colors.amber.withOpacity(0.2),
                      Colors.amber.withOpacity(0.1),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.amber.withOpacity(0.3)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Flexible(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Premium Earnings',
                            style: TextStyle(
                              color: Colors.amber[300],
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                          Text(
                            '\$${washerEarnings.toStringAsFixed(0)}',
                            style: const TextStyle(
                              color: Colors.amber,
                              fontWeight: FontWeight.bold,
                              fontSize: 26,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Flexible(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            'Estimated Time',
                            style: TextStyle(
                              color: Colors.grey[400],
                              fontSize: 14,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                          Text(
                            '${duration}min',
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // Marketplace action buttons
              Row(
                children: [
                  if (customerPhone.isNotEmpty &&
                      !isPending &&
                      !isCompleted) ...[
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () => callCustomer(customerPhone),
                        icon: const Icon(Icons.phone, size: 18),
                        label: const Text('Call Customer'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                  ],
                  if (isPending) ...[
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () => acceptBooking(jobId),
                        icon: const Icon(Icons.handshake, size: 18),
                        label: const Text('Accept Custom Job'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.amber,
                          foregroundColor: Colors.black,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                  ],
                  if (!isPending && !isCompleted) ...[
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () => completeBooking(jobId),
                        icon: const Icon(Icons.check_circle, size: 18),
                        label: const Text('Mark Complete'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                  ],
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => showJobDetails(context, job),
                      icon: const Icon(Icons.info_outline, size: 16),
                      label: const Text('Details'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.amber,
                        side: const BorderSide(color: Colors.amber),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Method name getters to ensure compatibility
  Widget _buildMarketplaceJobsList() => buildMarketplaceJobsList();
  Widget _buildMarketplaceJobCard(Map<String, dynamic> job) =>
      buildMarketplaceJobCard(job);
}