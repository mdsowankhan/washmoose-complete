import 'package:flutter/material.dart';

mixin WasherAvailableJobsWidgets<T extends StatefulWidget> on State<T> {
  // Access to main widget properties and state
  bool get isExpertMoose;
  List<Map<String, dynamic>> get availableBookings;

  // Access to logic methods
  Future<void> retryLoading();
  Future<void> acceptBooking(String bookingId);
  bool canAcceptJob(String packageName);
  String generateOrderNumber(String bookingId);
  double calculateWasherEarnings(double totalPrice);
  
  // ✅ NEW: Add shared widget methods here
  Widget buildJobTypeChip(String packageName);
  Widget buildDetailRow(IconData icon, String label, String value);
  void showJobDetails(BuildContext context, Map<String, dynamic> job);

  Widget buildEmptyAvailableJobs() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.search_off, size: 64, color: Colors.grey),
          const SizedBox(height: 16),
          const Text(
            'No available jobs at the moment',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 8),
          Text(
            'Check back later for new job requests',
            style: TextStyle(fontSize: 16, color: Colors.grey[500]),
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: retryLoading,
            icon: const Icon(Icons.refresh),
            label: const Text('Refresh'),
            style: ElevatedButton.styleFrom(
              backgroundColor: isExpertMoose
                  ? Colors.amber
                  : const Color(0xFF00C2CB),
            ),
          ),
        ],
      ),
    );
  }

  // Available jobs list
  Widget buildAvailableJobsList() {
    return RefreshIndicator(
      onRefresh: () async {
        setState(() {
          // isLoadingAvailable = true; // This should be handled in the main class
        });
        // loadAvailableBookings(); // This should be called from the main class
        // await loadWasherWorkload(); // This should be called from the main class
      },
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: availableBookings.length,
        itemBuilder: (context, index) {
          final job = availableBookings[index];
          return buildEnhancedAvailableBookingCard(job);
        },
      ),
    );
  }

  // Enhanced booking card for AVAILABLE jobs
  Widget buildEnhancedAvailableBookingCard(Map<String, dynamic> booking) {
    final jobId = booking['id'] ?? 'unknown';
    final packageName = booking['packageName'] ?? 'Unknown Package';
    final customerName = booking['customerName'] ?? 'Customer';
    final vehicleType = booking['vehicleType'] ?? 'Unknown Vehicle';
    final location = booking['location'] ?? 'Unknown Location';
    final fullAddress = booking['fullAddress'] ?? location;
    final date = booking['date'] ?? 'Unknown Date';
    final time = booking['time'] ?? 'Unknown Time';
    final price = (booking['totalPrice'] ?? 0.0).toDouble();
    final duration = booking['duration'] ?? 0;
    final specialInstructions = booking['specialInstructions'] ?? '';

    final orderNumber = generateOrderNumber(jobId);
    final washerEarnings = calculateWasherEarnings(price);

    final isASAP = booking['isASAP'] ?? false;
    final statusText = isASAP ? 'URGENT' : 'AVAILABLE';
    final statusColor = isASAP ? Colors.red : Colors.green;

    final canAcceptJobLocal = canAcceptJob(packageName);

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: statusColor.withOpacity(0.5), width: 2),
      ),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Colors.grey[850]!, Colors.grey[900]!],
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header with order number and status
              Row(
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
                          fontSize: 13,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Flexible(child: buildJobTypeChip(packageName)),
                  const SizedBox(width: 8),
                  Flexible(
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: statusColor.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: statusColor),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (isASAP)
                            Icon(Icons.flash_on, size: 14, color: statusColor),
                          Flexible(
                            child: Text(
                              statusText,
                              style: TextStyle(
                                color: statusColor,
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Service details
              Text(
                packageName,
                style: const TextStyle(
                  fontSize: 22,
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

              // Customer and location info
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
                      isASAP ? 'ASAP Service Needed' : '$date at $time',
                    ),
                    if (specialInstructions.isNotEmpty) ...[
                      const SizedBox(height: 8),
                      buildDetailRow(
                        Icons.note,
                        'Instructions',
                        specialInstructions,
                      ),
                    ],
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // Pricing section
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Colors.green.withOpacity(0.2),
                      Colors.green.withOpacity(0.1),
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
                        Flexible(
                          child: Text(
                            'Total Price:',
                            style: TextStyle(
                              color: Colors.grey[400],
                              fontSize: 14,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        Text(
                          '\$${price.toStringAsFixed(0)}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            decoration: TextDecoration.lineThrough,
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
                            'You Earn:',
                            style: TextStyle(
                              color: Colors.green,
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        Text(
                          '\$${washerEarnings.toStringAsFixed(0)}',
                          style: const TextStyle(
                            color: Colors.green,
                            fontWeight: FontWeight.bold,
                            fontSize: 24,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${duration}min duration',
                      style: TextStyle(color: Colors.grey[500], fontSize: 12),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),

              // Warning for restrictions
              if (!canAcceptJobLocal && !isExpertMoose) ...[
                const SizedBox(height: 16),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.amber.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.amber),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.upgrade, color: Colors.amber, size: 20),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Upgrade to Expert Moose to accept Detail & Custom jobs!',
                          style: TextStyle(
                            color: Colors.amber[700],
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
              ],

              const SizedBox(height: 20),

              // Action buttons for AVAILABLE JOBS
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => showJobDetails(context, booking),
                      icon: const Icon(Icons.info_outline, size: 16),
                      label: const Text('View Details'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.grey[400],
                        side: BorderSide(color: Colors.grey[600]!),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    flex: 2,
                    child: ElevatedButton.icon(
                      onPressed: canAcceptJobLocal
                          ? () => acceptBooking(jobId)
                          : null,
                      icon: Icon(
                        canAcceptJobLocal ? Icons.check_circle : Icons.block,
                        size: 18,
                      ),
                      label: Text(
                        canAcceptJobLocal
                            ? 'Accept Order'
                            : !canAcceptJob(packageName)
                            ? 'Upgrade Required'
                            : 'Cannot Accept',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: canAcceptJobLocal
                            ? (isExpertMoose ? Colors.amber : Colors.green)
                            : Colors.grey[600],
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        elevation: canAcceptJobLocal ? 4 : 0,
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
  Widget _buildEmptyAvailableJobs() => buildEmptyAvailableJobs();
  Widget _buildAvailableJobsList() => buildAvailableJobsList();
  Widget _buildEnhancedAvailableBookingCard(Map<String, dynamic> booking) =>
      buildEnhancedAvailableBookingCard(booking);
}