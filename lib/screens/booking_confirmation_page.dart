import 'package:flutter/material.dart';
import '../services/booking_service.dart';
import 'summary_screen.dart';  // Add this import

class BookingConfirmationPage extends StatefulWidget {
  final String vehicleType;
  final String package;
  final List<String> addOns;
  final String date;
  final String time;
  final int totalPrice;
  final int totalDuration;

  const BookingConfirmationPage({
    super.key,
    required this.vehicleType,
    required this.package,
    required this.addOns,
    required this.date,
    required this.time,
    required this.totalPrice,
    required this.totalDuration,
  });

  @override
  State<BookingConfirmationPage> createState() => _BookingConfirmationPageState();
}

class _BookingConfirmationPageState extends State<BookingConfirmationPage> {
  final BookingService _bookingService = BookingService();
  bool _isLoading = false;
  String? _errorMessage;
  
  Future<void> _confirmBooking() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    
    try {
      // Create the booking
      final bookingId = await _bookingService.createBooking(
        vehicleType: widget.vehicleType,
        packageName: widget.package,
        addOns: widget.addOns,
        date: widget.date,
        time: widget.time,
        totalPrice: widget.totalPrice.toDouble(),
        duration: widget.totalDuration,
        location: "User's Location", // Default for now
      );
      
      if (mounted) {
        // Navigate to summary screen with booking ID
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => SummaryScreen(
              vehicleType: widget.vehicleType,
              packageName: widget.package,
              addOns: widget.addOns,
              date: widget.date,
              time: widget.time,
              totalPrice: widget.totalPrice.toDouble(),
              duration: widget.totalDuration,
              bookingId: bookingId,
            ),
          ),
        );
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to create booking: ${e.toString()}';
      });
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Confirm Booking'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Vehicle Type:', 
              style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            Text(
              widget.vehicleType, 
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            const SizedBox(height: 12),

            Text(
              'Package:', 
              style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            Text(
              widget.package, 
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            const SizedBox(height: 12),

            Text(
              'Add-ons:', 
              style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            Text(
              widget.addOns.isNotEmpty ? widget.addOns.join(', ') : 'None', 
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            const SizedBox(height: 12),

            Text(
              'Date & Time:', 
              style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            Text(
              '${widget.date} at ${widget.time}', 
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            const SizedBox(height: 12),

            Text(
              'Total:', 
              style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            Text(
              '\$${widget.totalPrice} • ${widget.totalDuration} min', 
              style: TextStyle(
                fontSize: 18, 
                fontWeight: FontWeight.bold,
                color: Theme.of(context).primaryColor,
              ),
            ),
            
            if (_errorMessage != null)
              Padding(
                padding: const EdgeInsets.only(top: 16),
                child: Text(
                  _errorMessage!,
                  style: const TextStyle(color: Colors.red),
                ),
              ),
              
            const Spacer(),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _confirmBooking,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.tertiary,
                  foregroundColor: Colors.white,
                  minimumSize: const Size.fromHeight(50),
                ),
                child: _isLoading
                    ? const SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(color: Colors.white),
                      )
                    : const Text(
                        'Confirm Booking',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}