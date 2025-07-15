import 'package:flutter/material.dart';

mixin WasherMyJobsWidgets<T extends StatefulWidget> on State<T> {
  // Access to main widget properties and state
  List<Map<String, dynamic>> get myBookings;

  // Access to logic methods
  Future<void> completeBooking(String bookingId);
  Future<void> callCustomer(String phoneNumber);
  Future<void> cancelBookingWithReason(String bookingId, String reason); // ✅ NEW
  String generateOrderNumber(String bookingId);
  double calculateWasherEarnings(double totalPrice);
  
  // ✅ NEW: Add shared widget methods here
  Widget buildDetailRow(IconData icon, String label, String value);
  void showJobDetails(BuildContext context, Map<String, dynamic> job);

  // ✅ FIXED: Access filter from main class instead of declaring here
  String get selectedJobFilter; // Get from main class
  set selectedJobFilter(String value); // Set in main class
  
  static const List<String> _jobFilterOptions = [
    'All Jobs',
    'Active Jobs', 
    'Scheduled Jobs',
    'Completed Jobs'
  ];

  // ✅ NEW: Cancellation reasons dropdown options
  static const List<String> _cancelReasons = [
    'Emergency - Personal',
    'Emergency - Family',
    'Sick/Unwell',
    'Vehicle Breakdown',
    'Weather Conditions',
    'Double Booked',
    'Customer Location Issues',
    'Equipment Problems',
    'Other'
  ];

  // ✅ NEW: Show cancel confirmation dialog with reason dropdown
  void showCancelDialog(BuildContext context, Map<String, dynamic> job) {
    String selectedReason = _cancelReasons[0];
    final TextEditingController customReasonController = TextEditingController();
    
    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          backgroundColor: const Color(0xFFFFFFFF), // ✅ FIXED: White dialog background
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Row(
            children: [
              Icon(Icons.cancel_outlined, color: Colors.red, size: 24),
              SizedBox(width: 8),
              Text(
                'Cancel Order',
                style: TextStyle(color: Color(0xFF1A202C), fontSize: 18), // ✅ FIXED: Dark text
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Please select a reason for cancelling this order:',
                style: TextStyle(color: Color(0xFF4A5568), fontSize: 14), // ✅ FIXED: Darker text
              ),
              const SizedBox(height: 16),
              
              // Reason dropdown
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 12),
                decoration: BoxDecoration(
                  color: const Color(0xFFF7F8FA), // ✅ FIXED: Light background
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: const Color(0xFFE2E8F0)), // ✅ FIXED: Light border
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: selectedReason,
                    isExpanded: true,
                    dropdownColor: const Color(0xFFFFFFFF), // ✅ FIXED: White dropdown
                    style: const TextStyle(color: Color(0xFF1A202C), fontSize: 14), // ✅ FIXED: Dark text
                    onChanged: (String? newValue) {
                      if (newValue != null) {
                        setDialogState(() {
                          selectedReason = newValue;
                        });
                      }
                    },
                    items: _cancelReasons.map<DropdownMenuItem<String>>((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value),
                      );
                    }).toList(),
                  ),
                ),
              ),
              
              // Custom reason text field (if "Other" selected)
              if (selectedReason == 'Other') ...[
                const SizedBox(height: 12),
                TextField(
                  controller: customReasonController,
                  style: const TextStyle(color: Color(0xFF1A202C)), // ✅ FIXED: Dark text
                  decoration: InputDecoration(
                    hintText: 'Please specify the reason...',
                    hintStyle: const TextStyle(color: Color(0xFF9CA3AF)), // ✅ FIXED: Light hint
                    filled: true,
                    fillColor: const Color(0xFFF7F8FA), // ✅ FIXED: Light fill
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: const BorderSide(color: Color(0xFFE2E8F0)), // ✅ FIXED: Light border
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: const BorderSide(color: Color(0xFFE2E8F0)), // ✅ FIXED: Light border
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: const BorderSide(color: Colors.red),
                    ),
                  ),
                  maxLines: 2,
                  maxLength: 100,
                ),
              ],
              
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.red.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.red.withOpacity(0.3)),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.warning_amber_outlined, color: Colors.red, size: 20),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Customer will be notified immediately',
                        style: TextStyle(
                          color: Colors.red,
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text(
                'Keep Order',
                style: TextStyle(color: Color(0xFF4A5568)), // ✅ FIXED: Darker text
              ),
            ),
            ElevatedButton(
              onPressed: () {
                final finalReason = selectedReason == 'Other' 
                    ? customReasonController.text.trim().isNotEmpty
                        ? customReasonController.text.trim()
                        : 'Other reason'
                    : selectedReason;
                
                Navigator.pop(context);
                cancelBookingWithReason(job['id'], finalReason);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
              child: const Text('Cancel Order'),
            ),
          ],
        ),
      ),
    );
  }

  // ✅ NEW: Filter jobs based on selected filter
  List<Map<String, dynamic>> getFilteredJobs(List<Map<String, dynamic>> allJobs) {
    switch (selectedJobFilter) {
      case 'Active Jobs':
        return allJobs.where((job) {
          final status = job['status']?.toString().toLowerCase() ?? '';
          return status == 'confirmed' || status == 'in_progress';
        }).toList();
        
      case 'Scheduled Jobs':
        return allJobs.where((job) {
          final status = job['status']?.toString().toLowerCase() ?? '';
          if (status != 'confirmed') return false;
          
          // Check if job is scheduled for future (not ASAP)
          final isASAP = job['isASAP'] ?? false;
          return !isASAP;
        }).toList();
        
      case 'Completed Jobs':
        return allJobs.where((job) {
          final status = job['status']?.toString().toLowerCase() ?? '';
          return status == 'completed';
        }).toList();
        
      case 'All Jobs':
      default:
        return allJobs;
    }
  }

  // ✅ FIXED: Build filter dropdown widget using main class variable
  Widget buildJobFilterDropdown() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: const Color(0xFFF7F8FA), // ✅ FIXED: Light background
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE2E8F0)), // ✅ FIXED: Light border
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: selectedJobFilter,
          onChanged: (String? newValue) {
            if (newValue != null) {
              setState(() {
                selectedJobFilter = newValue;
              });
            }
          },
          items: _jobFilterOptions.map<DropdownMenuItem<String>>((String value) {
            IconData icon;
            Color iconColor;
            
            switch (value) {
              case 'Active Jobs':
                icon = Icons.play_circle_fill;
                iconColor = Colors.green;
                break;
              case 'Scheduled Jobs':
                icon = Icons.schedule;
                iconColor = Colors.blue;
                break;
              case 'Completed Jobs':
                icon = Icons.check_circle;
                iconColor = Colors.grey;
                break;
              default:
                icon = Icons.list;
                iconColor = const Color(0xFF4A5568); // ✅ FIXED: Dark icon color
            }
            
            return DropdownMenuItem<String>(
              value: value,
              child: Row(
                children: [
                  Icon(icon, color: iconColor, size: 20),
                  const SizedBox(width: 8),
                  Text(
                    value,
                    style: const TextStyle(
                      color: Color(0xFF1A202C), // ✅ FIXED: Dark text
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
          dropdownColor: const Color(0xFFFFFFFF), // ✅ FIXED: White dropdown
          icon: const Icon(Icons.keyboard_arrow_down, color: Color(0xFF4A5568)), // ✅ FIXED: Dark icon
        ),
      ),
    );
  }

  // ✅ NEW: Empty jobs view with filter-specific messaging
  Widget buildEmptyJobsView() {
    String message;
    IconData icon;
    Color iconColor;
    
    switch (selectedJobFilter) {
      case 'Active Jobs':
        message = 'No active jobs right now\nAccept jobs from Available tab to see them here';
        icon = Icons.work_off;
        iconColor = Colors.orange;
        break;
      case 'Scheduled Jobs':
        message = 'No scheduled jobs\nFuture bookings will appear here';
        icon = Icons.schedule_outlined;
        iconColor = Colors.blue;
        break;
      case 'Completed Jobs':
        message = 'No completed jobs yet\nFinished jobs will appear here';
        icon = Icons.check_circle_outline;
        iconColor = Colors.green;
        break;
      default:
        message = 'No jobs yet\nAccept jobs from Available tab to see them here';
        icon = Icons.work_off;
        iconColor = Colors.grey;
    }
    
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 64, color: iconColor),
          const SizedBox(height: 16),
          Text(
            message.split('\n')[0],
            style: const TextStyle(
              fontSize: 18, 
              fontWeight: FontWeight.bold,
              color: Color(0xFF1A202C), // ✅ FIXED: Dark text
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            message.split('\n')[1],
            style: const TextStyle(fontSize: 16, color: Color(0xFF4A5568)), // ✅ FIXED: Readable grey
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  // ✅ ENHANCED: Updated My Jobs List with filter
  Widget buildMyJobsList() {
    // Get filtered jobs
    final filteredJobs = getFilteredJobs(myBookings);
    
    return Column(
      children: [
        // ✅ NEW: Filter dropdown
        buildJobFilterDropdown(),
        
        // Jobs list or empty state
        Expanded(
          child: filteredJobs.isEmpty
              ? buildEmptyJobsView()
              : RefreshIndicator(
                  onRefresh: () async {
                    setState(() {
                      // Refresh will be handled by the main class
                    });
                    // This will trigger a rebuild and reload data
                  },
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: filteredJobs.length,
                    itemBuilder: (context, index) {
                      final job = filteredJobs[index];
                      return buildMyJobCard(job);
                    },
                  ),
                ),
        ),
      ],
    );
  }

  // ✅ ENHANCED: My Jobs card with cancel button
  Widget buildMyJobCard(Map<String, dynamic> job) {
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
    final status = job['status'] ?? 'confirmed';
    final customerPhone = job['customerPhone'] ?? '';
    final specialInstructions = job['specialInstructions'] ?? '';

    final washerEarnings = calculateWasherEarnings(price);
    final isASAP = job['isASAP'] ?? false;
    final isCompleted = status.toLowerCase() == 'completed';
    final isCancelled = status.toLowerCase() == 'cancelled';

    // Status color logic
    Color getStatusColor() {
      switch (status.toLowerCase()) {
        case 'confirmed':
          return isASAP ? Colors.red : Colors.blue;
        case 'in_progress':
          return Colors.orange;
        case 'completed':
          return Colors.green;
        case 'cancelled':
          return Colors.grey;
        default:
          return Colors.grey;
      }
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: getStatusColor().withOpacity(0.5), width: 2),
      ),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          // ✅ FIXED: Light theme gradient
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              const Color(0xFFFFFFFF), // White
              const Color(0xFFF7F8FA), // Very light grey
            ],
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
                  Flexible(
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: getStatusColor().withOpacity(0.2),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: getStatusColor()),
                      ),
                      child: Text(
                        isASAP ? 'ASAP' : status.toUpperCase(),
                        style: TextStyle(
                          color: getStatusColor(),
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // Customer and Service Info
              buildDetailRow(Icons.person, 'Customer', customerName),
              buildDetailRow(Icons.car_rental, 'Vehicle', vehicleType),
              buildDetailRow(Icons.wash, 'Service', packageName),
              buildDetailRow(Icons.location_on, 'Location', location),
              buildDetailRow(Icons.access_time, 'Date & Time', '$date at $time'),
              buildDetailRow(Icons.timer, 'Duration', '${duration} minutes'),

              if (specialInstructions.isNotEmpty) ...[
                const SizedBox(height: 12),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.blue.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.blue.withOpacity(0.3)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Row(
                        children: [
                          Icon(Icons.note, color: Colors.blue, size: 16),
                          SizedBox(width: 6),
                          Text(
                            'Special Instructions:',
                            style: TextStyle(
                              color: Colors.blue,
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        specialInstructions,
                        style: const TextStyle(
                          color: Color(0xFF1A202C), // ✅ FIXED: Dark text
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
              ],

              const SizedBox(height: 16),

              // Price and Earnings
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFFF7F8FA), // ✅ FIXED: Light background
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: const Color(0xFFE2E8F0)), // ✅ FIXED: Light border
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Total Price',
                          style: TextStyle(
                            color: Color(0xFF4A5568), // ✅ FIXED: Darker text
                            fontSize: 12,
                          ),
                        ),
                        Text(
                          '\$${price.toStringAsFixed(2)}',
                          style: const TextStyle(
                            color: Color(0xFF1A202C), // ✅ FIXED: Dark text
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        const Text(
                          'Your Earnings',
                          style: TextStyle(
                            color: Color(0xFF4A5568), // ✅ FIXED: Darker text
                            fontSize: 12,
                          ),
                        ),
                        Text(
                          '\$${washerEarnings.toStringAsFixed(2)}',
                          style: const TextStyle(
                            color: Color(0xFF00C2CB),
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // ✅ ENHANCED: Action buttons with CANCEL BUTTON
              if (!isCompleted && !isCancelled) ...[
                // Top row: Call and Cancel buttons
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: customerPhone.isNotEmpty
                            ? () => callCustomer(customerPhone)
                            : null,
                        icon: const Icon(Icons.phone, size: 16),
                        label: const Text('Call Customer'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () => showCancelDialog(context, job),
                        icon: const Icon(Icons.cancel_outlined, size: 16),
                        label: const Text('Cancel'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.red,
                          side: const BorderSide(color: Colors.red),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                // Bottom row: Complete button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () => completeBooking(jobId),
                    icon: const Icon(Icons.check_circle, size: 16),
                    label: const Text('Mark Complete'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
              ] else if (isCompleted) ...[
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  decoration: BoxDecoration(
                    color: Colors.green.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.green),
                  ),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.check_circle, color: Colors.green, size: 20),
                      SizedBox(width: 8),
                      Text(
                        'Job Completed',
                        style: TextStyle(
                          color: Colors.green,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                ),
              ] else if (isCancelled) ...[
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  decoration: BoxDecoration(
                    color: Colors.grey.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.grey),
                  ),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.cancel, color: Colors.grey, size: 20),
                      SizedBox(width: 8),
                      Text(
                        'Job Cancelled',
                        style: TextStyle(
                          color: Colors.grey,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                ),
              ],

              const SizedBox(height: 12),

              // View Details button
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () => showJobDetails(context, job),
                  icon: const Icon(Icons.info_outline, size: 16),
                  label: const Text('View Full Details'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: const Color(0xFF4A5568), // ✅ FIXED: Darker text
                    side: const BorderSide(color: Color(0xFF4A5568)), // ✅ FIXED: Darker border
                    padding: const EdgeInsets.symmetric(vertical: 10),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}