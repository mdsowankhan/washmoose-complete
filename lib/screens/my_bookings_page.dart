import 'package:flutter/material.dart';
import '../services/booking_service.dart';

class MyBookingsPage extends StatefulWidget {
  const MyBookingsPage({super.key});

  @override
  State<MyBookingsPage> createState() => _MyBookingsPageState();
}

class _MyBookingsPageState extends State<MyBookingsPage> {
  final BookingService _bookingService = BookingService();
  bool _isLoading = true;
  List<Map<String, dynamic>> _bookings = [];
  String? _errorMessage;
  
  @override
  void initState() {
    super.initState();
    _loadBookings();
  }
  
  void _loadBookings() {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    
    try {
      _bookingService.getCustomerBookings().listen((bookings) {
        if (mounted) {
          setState(() {
            _bookings = bookings;
            _isLoading = false;
          });
        }
      }, onError: (error) {
        if (mounted) {
          // Check if it's a Firestore index error
          if (error.toString().contains('index')) {
            setState(() {
              _bookings = []; // Show empty state instead of error
              _isLoading = false;
            });
          } else {
            setState(() {
              _errorMessage = 'Unable to load bookings. Please try again later.';
              _isLoading = false;
            });
          }
        }
      });
    } catch (e) {
      if (mounted) {
        setState(() {
          _bookings = []; // Show empty state instead of error
          _isLoading = false;
        });
      }
    }
  }

  // Pull to refresh function
  Future<void> _refreshBookings() async {
    _loadBookings();
    await Future.delayed(const Duration(seconds: 1));
  }

  void _navigateToServiceSelection() {
    // Navigate to the main page and switch to home tab
    Navigator.pushNamedAndRemoveUntil(
      context,
      '/main',
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    const washMooseColor = Color(0xFF00C2CB);

    return Stack(
      children: [
        RefreshIndicator(
          onRefresh: _refreshBookings,
          child: _isLoading 
              ? _buildLoadingState()
              : _errorMessage != null
                  ? _buildErrorState()
                  : _bookings.isEmpty
                      ? _buildEmptyState()
                      : _buildBookingsList(),
        ),
        Positioned(
          bottom: 16,
          right: 16,
          child: FloatingActionButton(
            onPressed: _navigateToServiceSelection,
            backgroundColor: washMooseColor,
            tooltip: 'New Booking',
            child: const Icon(Icons.add),
          ),
        ),
      ],
    );
  }

  Widget _buildLoadingState() {
    return const Center(
      child: CircularProgressIndicator(),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.error_outline,
            size: 60,
            color: Colors.red,
          ),
          const SizedBox(height: 16),
          const Text(
            'Error Loading Bookings',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Text(
              _errorMessage ?? 'Unknown error',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey[600]),
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: _refreshBookings,
            child: const Text('Try Again'),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return ListView(
      // ListView needed for RefreshIndicator to work
      children: [
        SizedBox(
          height: MediaQuery.of(context).size.height * 0.7,
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.directions_car,
                  size: 100,
                  color: Colors.grey,
                ),
                const SizedBox(height: 20),
                const Text(
                  'No Bookings Yet',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 10),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 40),
                  child: Text(
                    'Get your car washed by tapping the + button below',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.grey[500],
                      fontSize: 16,
                    ),
                  ),
                ),
                const SizedBox(height: 30),
                ElevatedButton.icon(
                  onPressed: _navigateToServiceSelection,
                  icon: const Icon(Icons.add),
                  label: const Text('Book a Wash'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF00C2CB),
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildBookingsList() {
    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: _bookings.length,
      separatorBuilder: (_, __) => const SizedBox(height: 16),
      itemBuilder: (context, index) {
        final booking = _bookings[index];
        final isUpcoming = booking['status'] == 'pending' || booking['status'] == 'confirmed';
        
        return _buildBookingCard(context, booking, isUpcoming);
      },
    );
  }

  Widget _buildBookingCard(BuildContext context, Map<String, dynamic> booking, bool isUpcoming) {
    final washMooseColor = const Color(0xFF00C2CB);
    final statusColor = isUpcoming ? washMooseColor : Colors.grey;
    
    // Handle possible null values with defaults
    final bookingId = booking['id'] ?? 'Unknown';
    final vehicleType = booking['vehicleType'] ?? 'Unknown Vehicle';
    final packageName = booking['packageName'] ?? 'Unknown Package';
    final addOns = (booking['addOns'] as List<dynamic>?)?.cast<String>() ?? [];
    final date = booking['date'] ?? 'Unknown Date';
    final time = booking['time'] ?? 'Unknown Time';
    final price = booking['totalPrice'] ?? 0.0;
    final duration = booking['duration'] ?? 0;
    final status = booking['status'] ?? 'pending';
    final address = booking['location'] ?? 'Unknown Location';
    final washerName = booking['washerName'] ?? 'Not Assigned';
    
    return Card(
      elevation: 4,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: isUpcoming ? washMooseColor.withOpacity(0.3) : Colors.transparent,
          width: isUpcoming ? 1 : 0,
        ),
      ),
      child: Column(
        children: [
          // Status bar at the top
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
            decoration: BoxDecoration(
              color: statusColor.withOpacity(0.1),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(12),
                topRight: Radius.circular(12),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  bookingId.length > 6 ? 'Booking #${bookingId.substring(0, 6)}' : 'Booking',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: statusColor,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    color: isUpcoming ? statusColor.withOpacity(0.2) : Colors.grey.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    status.substring(0, 1).toUpperCase() + status.substring(1),
                    style: TextStyle(
                      color: isUpcoming ? statusColor : Colors.grey[400],
                      fontWeight: FontWeight.w600,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
          ),
          
          // Main content
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Service info
                Row(
                  children: [
                    const Icon(Icons.directions_car, size: 28),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '$packageName - $vehicleType',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          if (addOns.isNotEmpty)
                            Padding(
                              padding: const EdgeInsets.only(top: 4),
                              child: Text(
                                'Add-ons: ${addOns.join(', ')}',
                                style: const TextStyle(
                                  fontSize: 14,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
                
                const SizedBox(height: 16),
                
                // Date and time
                _buildInfoRow(
                  Icons.calendar_today,
                  '$date at $time',
                ),
                
                const SizedBox(height: 8),
                
                // Location
                _buildInfoRow(
                  Icons.location_on_outlined,
                  address,
                ),
                
                const SizedBox(height: 8),
                
                // Washer info
                _buildInfoRow(
                  Icons.person_outline,
                  washerName,
                ),
                
                const Divider(height: 24),
                
                // Price and actions
                Row(
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Total:',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey,
                          ),
                        ),
                        Text(
                          '\$${price.toStringAsFixed(2)}',
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          '$duration min',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                    const Spacer(),
                    
                    // Action buttons based on status
                    if (isUpcoming) ...[
                      OutlinedButton(
                        onPressed: () {
                          _showCancelDialog(context, booking);
                        },
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.red,
                          side: const BorderSide(color: Colors.red),
                        ),
                        child: const Text('Cancel'),
                      ),
                      const SizedBox(width: 12),
                      ElevatedButton(
                        onPressed: () {
                          _showBookingDetails(context, booking);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: washMooseColor,
                        ),
                        child: const Text('View'),
                      ),
                    ] else ...[
                      OutlinedButton(
                        onPressed: () {
                          _showRebookDialog(context, booking);
                        },
                        child: const Text('Rebook'),
                      ),
                      const SizedBox(width: 12),
                      ElevatedButton(
                        onPressed: () {
                          _showBookingDetails(context, booking);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.grey[700],
                        ),
                        child: const Text('View'),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 16, color: Colors.grey[600]),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[800],
            ),
          ),
        ),
      ],
    );
  }

  void _showBookingDetails(BuildContext context, Map<String, dynamic> booking) {
    // Handle possible null values with defaults for display
    final bookingId = booking['id'] ?? 'Unknown';
    final vehicleType = booking['vehicleType'] ?? 'Unknown Vehicle';
    final packageName = booking['packageName'] ?? 'Unknown Package';
    final addOns = (booking['addOns'] as List<dynamic>?)?.cast<String>() ?? [];
    final date = booking['date'] ?? 'Unknown Date';
    final time = booking['time'] ?? 'Unknown Time';
    final price = booking['totalPrice'] ?? 0.0;
    final duration = booking['duration'] ?? 0;
    final status = booking['status'] ?? 'pending';
    final address = booking['location'] ?? 'Unknown Location';
    final washerName = booking['washerName'] ?? 'Not Assigned';
    
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.65,
        minChildSize: 0.3,
        maxChildSize: 0.95,
        expand: false,
        builder: (context, scrollController) => SingleChildScrollView(
          controller: scrollController,
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 5,
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                
                const Text(
                  'Booking Details',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                
                _buildDetailRow('Status', status.substring(0, 1).toUpperCase() + status.substring(1)),
                _buildDetailRow('Service', packageName),
                _buildDetailRow('Vehicle', vehicleType),
                if (addOns.isNotEmpty)
                  _buildDetailRow('Add-ons', addOns.join(', ')),
                _buildDetailRow('Date & Time', '$date at $time'),
                _buildDetailRow('Location', address),
                _buildDetailRow('Washer', washerName),
                _buildDetailRow('Price', '\$${price.toStringAsFixed(2)}'),
                _buildDetailRow('Duration', '$duration minutes'),
                _buildDetailRow('Booking ID', bookingId),
                
                const SizedBox(height: 24),
                
                if (status == 'pending' || status == 'confirmed') ...[
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        // Navigate to chat or contact washer
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Chat feature coming soon')),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF00C2CB),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      child: const Text('Contact Washer'),
                    ),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton(
                      onPressed: () {
                        Navigator.pop(context);
                        _showCancelDialog(context, booking);
                      },
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.red,
                        side: const BorderSide(color: Colors.red),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      child: const Text('Cancel Booking'),
                    ),
                  ),
                ] else if (status == 'completed') ...[
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context);
                        _showRebookDialog(context, booking);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF00C2CB),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      child: const Text('Book Again'),
                    ),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton(
                      onPressed: () {
                        // Leave review for washer
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Review feature coming soon')),
                        );
                      },
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      child: const Text('Leave a Review'),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              '$label:',
              style: TextStyle(
                fontWeight: FontWeight.w500,
                color: Colors.grey[700],
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontWeight: FontWeight.w400,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showCancelDialog(BuildContext context, Map<String, dynamic> booking) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cancel Booking'),
        content: const Text(
          'Are you sure you want to cancel this booking? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('No, Keep Booking'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _cancelBooking(booking['id']);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            child: const Text('Yes, Cancel'),
          ),
        ],
      ),
    );
  }

  Future<void> _cancelBooking(String bookingId) async {
    try {
      await _bookingService.cancelBooking(bookingId);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Booking cancelled successfully')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to cancel booking: $e')),
        );
      }
    }
  }

  void _showRebookDialog(BuildContext context, Map<String, dynamic> booking) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Book Again'),
        content: const Text(
          'Would you like to book the same service again?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Not Now'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              // Navigate to booking flow with pre-filled info
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Creating a new booking with the same details')),
              );
              
              // Navigate to service selection
              _navigateToServiceSelection();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF00C2CB),
            ),
            child: const Text('Book Same Service'),
          ),
        ],
      ),
    );
  }
}