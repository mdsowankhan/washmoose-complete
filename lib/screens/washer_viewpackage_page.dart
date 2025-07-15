import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class WasherViewPackagePage extends StatefulWidget {
  final Map<String, dynamic> washerData;
  
  const WasherViewPackagePage({
    super.key,
    required this.washerData,
  });

  @override
  State<WasherViewPackagePage> createState() => _WasherViewPackagePageState();
}

class _WasherViewPackagePageState extends State<WasherViewPackagePage> {
  int _selectedVehicleIndex = 0; // Default to Sedan

  final List<String> _vehicleTypes = [
    'Sedan / Hatchback / Coupe',
    'SUV (5-Seater)',
    'Large SUV (6–8 Seater) / Ute / 1T Van',
    'People Mover (9–12 Seater) / 2T Van',
  ];

  List<DateTime> _getAvailableDates() {
    final now = DateTime.now();
    List<DateTime> dates = [];
    for (int i = 0; i < 3; i++) {
      dates.add(DateTime(now.year, now.month, now.day + i));
    }
    return dates;
  }

  List<String> _getAvailableTimeSlots() {
    List<String> slots = [];
    for (int hour = 6; hour <= 20; hour++) {
      if (hour == 20) {
        slots.add(DateFormat.jm().format(DateTime(0, 0, 0, hour, 0)));
      } else {
        slots.add(DateFormat.jm().format(DateTime(0, 0, 0, hour, 0)));
        slots.add(DateFormat.jm().format(DateTime(0, 0, 0, hour, 30)));
      }
    }
    return slots;
  }

  Map<String, String> _getASAPSlot() {
    final now = DateTime.now();
    final currentHour = now.hour;
    if (currentHour < 6) {
      return {
        'date': DateFormat('MMM d, y').format(now),
        'time': '6:00 AM',
      };
    } else if (currentHour < 20) {
      final nextHour = currentHour + 1;
      if (nextHour <= 20) {
        return {
          'date': DateFormat('MMM d, y').format(now),
          'time': DateFormat.jm().format(DateTime(0, 0, 0, nextHour, 0)),
        };
      }
    }
    final tomorrow = DateTime(now.year, now.month, now.day + 1);
    return {
      'date': DateFormat('MMM d, y').format(tomorrow),
      'time': '6:00 AM',
    };
  }

  @override
  Widget build(BuildContext context) {
    const themeColor = Colors.amber;
    final vehiclePackages = widget.washerData['vehiclePackages'] as Map<int, List<Map<String, dynamic>>>;
    final currentPackages = vehiclePackages[_selectedVehicleIndex] ?? [];
    
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Text('${widget.washerData['name']} - Packages'),
        backgroundColor: themeColor,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView( // FIXED: Wrap entire body in SingleChildScrollView
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildWasherProfileHeader(themeColor),
            const SizedBox(height: 16),
            _buildVehicleSelector(themeColor),
            const SizedBox(height: 16),
            _buildPackageList(currentPackages, themeColor),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildWasherProfileHeader(Color themeColor) {
    final portfolioImages = widget.washerData['portfolioImages'] as List<dynamic>;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            themeColor.withOpacity(0.8),
            themeColor.withOpacity(0.6),
          ],
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min, // FIXED: Prevent overflow
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 40,
                backgroundColor: Colors.white.withOpacity(0.2),
                child: Text(
                  widget.washerData['name'].substring(0, 1),
                  style: const TextStyle(
                    fontSize: 36,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
              const SizedBox(width: 20),
              Expanded( // FIXED: Use Expanded to prevent overflow
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min, // FIXED: Prevent overflow
                  children: [
                    Text(
                      widget.washerData['name'],
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                      overflow: TextOverflow.ellipsis, // FIXED: Add overflow handling
                    ),
                    const SizedBox(height: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Text(
                        'Expert Moose',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const Icon(Icons.star, color: Colors.white, size: 18),
                        const SizedBox(width: 4),
                        Text(
                          '${widget.washerData['rating']}',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Flexible( // FIXED: Wrap in Flexible
                          child: Text(
                            '(${widget.washerData['completedJobs']} jobs)',
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.8),
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            widget.washerData['bio'],
            style: TextStyle(
              color: Colors.white.withOpacity(0.9),
              fontSize: 16,
              height: 1.4,
            ),
            textAlign: TextAlign.center,
            maxLines: 3, // FIXED: Limit lines to prevent overflow
            overflow: TextOverflow.ellipsis,
          ),
          if (portfolioImages.isNotEmpty) ...[
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.photo_library, color: Colors.white, size: 20),
                const SizedBox(width: 8),
                Flexible( // FIXED: Wrap in Flexible
                  child: Text(
                    '${portfolioImages.length} Portfolio Photos Available',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ],
          const SizedBox(height: 16),
          IntrinsicHeight( // FIXED: Use IntrinsicHeight for equal height columns
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Expanded( // FIXED: Use Expanded
                  child: Column(
                    children: [
                      const Icon(Icons.location_on, color: Colors.white, size: 20),
                      const SizedBox(height: 4),
                      Text(
                        widget.washerData['location'],
                        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                        overflow: TextOverflow.ellipsis, // FIXED: Add overflow handling
                        textAlign: TextAlign.center,
                      ),
                      Text(
                        '${widget.washerData['distance']} km away',
                        style: TextStyle(color: Colors.white.withOpacity(0.8), fontSize: 12),
                        overflow: TextOverflow.ellipsis,
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                Expanded( // FIXED: Use Expanded
                  child: Column(
                    children: [
                      const Icon(Icons.access_time, color: Colors.white, size: 20),
                      const SizedBox(height: 4),
                      const Text(
                        'Available',
                        style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                        overflow: TextOverflow.ellipsis,
                        textAlign: TextAlign.center,
                      ),
                      Text(
                        widget.washerData['availability'],
                        style: TextStyle(color: Colors.white.withOpacity(0.8), fontSize: 12),
                        overflow: TextOverflow.ellipsis,
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVehicleSelector(Color themeColor) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[850],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: themeColor.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min, // FIXED: Prevent overflow
        children: [
          Text(
            'Select Vehicle Type',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: themeColor,
            ),
          ),
          const SizedBox(height: 12),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              color: Colors.grey[800],
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: themeColor.withOpacity(0.5)),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<int>(
                value: _selectedVehicleIndex,
                isExpanded: true,
                dropdownColor: Colors.grey[800],
                style: const TextStyle(color: Colors.white, fontSize: 16),
                icon: Icon(Icons.keyboard_arrow_down, color: themeColor),
                items: _vehicleTypes.asMap().entries.map((entry) {
                  return DropdownMenuItem<int>(
                    value: entry.key,
                    child: Row(
                      children: [
                        Icon(
                          _getVehicleIcon(entry.key),
                          color: themeColor,
                          size: 20,
                        ),
                        const SizedBox(width: 12),
                        Expanded( // FIXED: Use Expanded to prevent overflow
                          child: Text(
                            entry.value,
                            style: const TextStyle(color: Colors.white),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
                onChanged: (int? newValue) {
                  if (newValue != null) {
                    setState(() {
                      _selectedVehicleIndex = newValue;
                    });
                  }
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  IconData _getVehicleIcon(int index) {
    switch (index) {
      case 0:
        return Icons.directions_car;
      case 1:
        return Icons.directions_car_filled;
      case 2:
        return Icons.directions_car_filled_outlined;
      case 3:
        return Icons.airport_shuttle;
      default:
        return Icons.directions_car;
    }
  }

  Widget _buildPackageList(List<Map<String, dynamic>> packages, Color themeColor) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min, // FIXED: Prevent overflow
        children: [
          Text(
            'Available Packages for ${_vehicleTypes[_selectedVehicleIndex]}',
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
            maxLines: 2, // FIXED: Limit lines
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 16),
          ...packages.map((package) {
            return _buildPackageCard(package, themeColor);
          }),
        ],
      ),
    );
  }

  Widget _buildPackageCard(Map<String, dynamic> package, Color themeColor) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.grey[850],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: themeColor.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min, // FIXED: Prevent overflow
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded( // FIXED: Use Expanded for package name
                  child: Text(
                    package['name'],
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.amber,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: 8), // FIXED: Add spacing
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  mainAxisSize: MainAxisSize.min, // FIXED: Prevent overflow
                  children: [
                    Text(
                      '\$${package['price']}',
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    Text(
                      '${package['duration']} min',
                      style: TextStyle(
                        color: Colors.grey[400],
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              package['description'],
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 16,
                height: 1.4,
              ),
              maxLines: 3, // FIXED: Limit lines to prevent overflow
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    icon: const Icon(Icons.message, size: 16),
                    label: const Text('Message'),
                    onPressed: () {
                      _showMessageDialog(package);
                    },
                    style: OutlinedButton.styleFrom(
                      foregroundColor: themeColor,
                      side: BorderSide(color: themeColor),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  flex: 2,
                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.schedule, size: 16),
                    label: const Text('Book Now'),
                    onPressed: () {
                      _showBookingDialog(package);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: themeColor,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showMessageDialog(Map<String, dynamic> package) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.grey[850],
        title: const Text(
          'Message Washer',
          style: TextStyle(color: Colors.white),
        ),
        content: SingleChildScrollView( // FIXED: Wrap content in scroll view
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Send a message to ${widget.washerData['name']} about:',
                style: const TextStyle(color: Colors.white70),
              ),
              const SizedBox(height: 8),
              Text(
                '${package['name']} for ${_vehicleTypes[_selectedVehicleIndex]}',
                style: const TextStyle(
                  color: Colors.amber,
                  fontWeight: FontWeight.bold,
                ),
                maxLines: 2, // FIXED: Limit lines
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 16),
              TextField(
                maxLines: 4,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  hintText: 'Ask about availability, custom requirements, etc...',
                  hintStyle: TextStyle(color: Colors.grey[400]),
                  filled: true,
                  fillColor: Colors.grey[800],
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Message sent! (Feature coming soon)')),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.amber),
            child: const Text('Send Message'),
          ),
        ],
      ),
    );
  }

  void _showBookingDialog(Map<String, dynamic> package) {
    showDialog(
      context: context,
      builder: (context) => _BookingDialog(
        washerData: widget.washerData,
        package: package,
        vehicleType: _vehicleTypes[_selectedVehicleIndex],
        availableDates: _getAvailableDates(),
        availableTimeSlots: _getAvailableTimeSlots(),
        asapSlot: _getASAPSlot(),
        onBookingConfirmed: (selectedDate, selectedTime, isASAP) {
          _handleBookingConfirmation(package, selectedDate, selectedTime, isASAP);
        },
      ),
    );
  }

  Future<void> _handleBookingConfirmation(
    Map<String, dynamic> package,
    String selectedDate,
    String selectedTime,
    bool isASAP,
  ) async {
    try {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => AlertDialog(
          backgroundColor: Colors.grey[850],
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const CircularProgressIndicator(color: Colors.amber),
              const SizedBox(height: 16),
              const Text(
                'Creating your booking...',
                style: TextStyle(color: Colors.white),
              ),
            ],
          ),
        ),
      );

      final bookingData = {
        'id': 'booking_${DateTime.now().millisecondsSinceEpoch}',
        'washerId': widget.washerData['id'],
        'washerName': widget.washerData['name'],
        'washerType': 'expert_moose',
        'vehicleType': _vehicleTypes[_selectedVehicleIndex],
        'packageName': package['name'],
        'price': package['price'],
        'duration': package['duration'],
        'scheduledDate': selectedDate,
        'scheduledTime': selectedTime,
        'isASAP': isASAP,
        'status': 'pending',
      };

      await Future.delayed(const Duration(seconds: 1));
      final bookingId = bookingData['id'] as String;

      if (mounted) Navigator.pop(context);

      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => BookingConfirmationPage(
              bookingId: bookingId,
              washerData: widget.washerData,
              vehicleType: _vehicleTypes[_selectedVehicleIndex],
              package: package,
              scheduledDate: selectedDate,
              scheduledTime: selectedTime,
              isASAP: isASAP,
              isExpertMoose: true,
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) Navigator.pop(context);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Booking failed: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }
}

// Booking Dialog Widget
class _BookingDialog extends StatefulWidget {
  final Map<String, dynamic> washerData;
  final Map<String, dynamic> package;
  final String vehicleType;
  final List<DateTime> availableDates;
  final List<String> availableTimeSlots;
  final Map<String, String> asapSlot;
  final Function(String date, String time, bool isASAP) onBookingConfirmed;

  const _BookingDialog({
    super.key,
    required this.washerData,
    required this.package,
    required this.vehicleType,
    required this.availableDates,
    required this.availableTimeSlots,
    required this.asapSlot,
    required this.onBookingConfirmed,
  });

  @override
  State<_BookingDialog> createState() => _BookingDialogState();
}

class _BookingDialogState extends State<_BookingDialog> {
  DateTime? _selectedDate;
  String? _selectedTime;
  bool _isASAP = false;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: Colors.grey[850],
      title: const Text(
        'Book Service',
        style: TextStyle(color: Colors.white),
      ),
      content: SizedBox( // FIXED: Constrain dialog size
        width: MediaQuery.of(context).size.width * 0.9,
        height: MediaQuery.of(context).size.height * 0.7,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey[800],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min, // FIXED: Prevent overflow
                  children: [
                    Text(
                      widget.package['name'],
                      style: const TextStyle(
                        color: Colors.amber,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                      overflow: TextOverflow.ellipsis, // FIXED: Add overflow handling
                    ),
                    const SizedBox(height: 4),
                    Text(
                      widget.vehicleType,
                      style: const TextStyle(color: Colors.white),
                      maxLines: 2, // FIXED: Limit lines
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Price: \$${widget.package['price']}',
                          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                        ),
                        Text(
                          'Duration: ${widget.package['duration']} min',
                          style: TextStyle(color: Colors.grey[400]),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.amber.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.amber.withOpacity(0.3)),
                ),
                child: InkWell(
                  onTap: () {
                    setState(() {
                      _isASAP = true;
                      _selectedDate = null;
                      _selectedTime = null;
                    });
                  },
                  child: Row(
                    children: [
                      Radio<bool>(
                        value: true,
                        groupValue: _isASAP,
                        onChanged: (value) {
                          setState(() {
                            _isASAP = true;
                            _selectedDate = null;
                            _selectedTime = null;
                          });
                        },
                        activeColor: Colors.amber,
                      ),
                      const SizedBox(width: 8),
                      Expanded( // FIXED: Use Expanded
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min, // FIXED: Prevent overflow
                          children: [
                            const Text(
                              '⚡ ASAP (Recommended)',
                              style: TextStyle(
                                color: Colors.amber,
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                            Text(
                              'Earliest available: ${widget.asapSlot['date']} at ${widget.asapSlot['time']}',
                              style: const TextStyle(color: Colors.white70, fontSize: 14),
                              maxLines: 2, // FIXED: Limit lines
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey[800],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey[600]!),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min, // FIXED: Prevent overflow
                  children: [
                    InkWell(
                      onTap: () {
                        setState(() {
                          _isASAP = false;
                        });
                      },
                      child: Row(
                        children: [
                          Radio<bool>(
                            value: false,
                            groupValue: _isASAP,
                            onChanged: (value) {
                              setState(() {
                                _isASAP = false;
                              });
                            },
                            activeColor: Colors.amber,
                          ),
                          const Expanded( // FIXED: Use Expanded
                            child: Text(
                              'Choose Custom Date & Time',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (!_isASAP) ...[
                      const SizedBox(height: 16),
                      const Text(
                        'Select Date (Next 3 days)',
                        style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        children: widget.availableDates.map((date) {
                          final isSelected = _selectedDate == date;
                          final isToday = DateTime.now().day == date.day;
                          return ChoiceChip(
                            label: Text(
                              isToday ? 'Today' : DateFormat('MMM d').format(date),
                            ),
                            selected: isSelected,
                            onSelected: (selected) {
                              if (selected) {
                                setState(() {
                                  _selectedDate = date;
                                  _selectedTime = null;
                                });
                              }
                            },
                            backgroundColor: Colors.grey[700],
                            selectedColor: Colors.amber,
                            labelStyle: TextStyle(
                              color: isSelected ? Colors.white : Colors.grey[300],
                            ),
                          );
                        }).toList(),
                      ),
                      if (_selectedDate != null) ...[
                        const SizedBox(height: 16),
                        const Text(
                          'Select Time (6 AM - 8 PM)',
                          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 8),
                        SizedBox( // FIXED: Constrain height
                          height: 120,
                          child: GridView.builder(
                            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 3,
                              childAspectRatio: 2.5,
                              crossAxisSpacing: 8,
                              mainAxisSpacing: 8,
                            ),
                            itemCount: widget.availableTimeSlots.length,
                            itemBuilder: (context, index) {
                              final timeSlot = widget.availableTimeSlots[index];
                              final isSelected = _selectedTime == timeSlot;
                              return ChoiceChip(
                                label: Text(
                                  timeSlot,
                                  style: const TextStyle(fontSize: 12),
                                ),
                                selected: isSelected,
                                onSelected: (selected) {
                                  if (selected) {
                                    setState(() {
                                      _selectedTime = timeSlot;
                                    });
                                  }
                                },
                                backgroundColor: Colors.grey[700],
                                selectedColor: Colors.amber,
                                labelStyle: TextStyle(
                                  color: isSelected ? Colors.white : Colors.grey[300],
                                ),
                              );
                            },
                          ),
                        ),
                      ],
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _canConfirmBooking() ? _confirmBooking : null,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.amber,
            disabledBackgroundColor: Colors.grey,
          ),
          child: const Text('Confirm Booking'),
        ),
      ],
    );
  }

  bool _canConfirmBooking() {
    if (_isASAP) return true;
    return _selectedDate != null && _selectedTime != null;
  }

  void _confirmBooking() {
    String finalDate;
    String finalTime;
    if (_isASAP) {
      finalDate = widget.asapSlot['date']!;
      finalTime = widget.asapSlot['time']!;
    } else {
      finalDate = DateFormat('MMM d, y').format(_selectedDate!);
      finalTime = _selectedTime!;
    }
    Navigator.pop(context);
    widget.onBookingConfirmed(finalDate, finalTime, _isASAP);
  }
}

// Booking Confirmation Page
class BookingConfirmationPage extends StatelessWidget {
  final String bookingId;
  final Map<String, dynamic> washerData;
  final String vehicleType;
  final Map<String, dynamic> package;
  final String scheduledDate;
  final String scheduledTime;
  final bool isASAP;
  final bool isExpertMoose;

  const BookingConfirmationPage({
    super.key,
    required this.bookingId,
    required this.washerData,
    required this.vehicleType,
    required this.package,
    required this.scheduledDate,
    required this.scheduledTime,
    required this.isASAP,
    required this.isExpertMoose,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text('Booking Confirmation'),
        backgroundColor: Colors.amber,
        automaticallyImplyLeading: false,
      ),
      body: SingleChildScrollView( // FIXED: Wrap in SingleChildScrollView
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.green.withOpacity(0.8), Colors.green.withOpacity(0.6)],
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min, // FIXED: Prevent overflow
                children: [
                  const Icon(
                    Icons.check_circle,
                    color: Colors.white,
                    size: 64,
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Booking Request Sent!',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Booking ID: $bookingId',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.8),
                      fontSize: 14,
                    ),
                    textAlign: TextAlign.center,
                    overflow: TextOverflow.ellipsis, // FIXED: Add overflow handling
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            _buildDetailCard('Service Details', [
              _buildDetailRow('Washer', washerData['name']),
              _buildDetailRow('Package', package['name']),
              _buildDetailRow('Vehicle Type', vehicleType),
              _buildDetailRow('Price', '\$${package['price']}'),
              _buildDetailRow('Duration', '${package['duration']} minutes'),
            ]),
            const SizedBox(height: 16),
            _buildDetailCard('Schedule Details', [
              _buildDetailRow('Date', scheduledDate),
              _buildDetailRow('Time', scheduledTime),
              _buildDetailRow('Type', isASAP ? 'ASAP Booking' : 'Scheduled Booking'),
              _buildDetailRow('Status', 'Pending Confirmation'),
            ]),
            const SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.amber.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.amber.withOpacity(0.3)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min, // FIXED: Prevent overflow
                children: [
                  Row(
                    children: [
                      const Icon(Icons.info, color: Colors.amber, size: 20),
                      const SizedBox(width: 8),
                      const Expanded( // FIXED: Use Expanded
                        child: Text(
                          'What happens next?',
                          style: TextStyle(
                            color: Colors.amber,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    '• ${washerData['name']} will review your booking request\n'
                    '• They can accept your time or offer an alternative within 3 days\n'
                    '• You\'ll receive a notification once they respond\n'
                    '• Payment will be processed after confirmation',
                    style: const TextStyle(color: Colors.white70, height: 1.5),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    icon: const Icon(Icons.message),
                    label: const Text('Message Washer'),
                    onPressed: () => _showMessageDialog(context),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.amber,
                      side: const BorderSide(color: Colors.amber),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.home),
                    label: const Text('Back to Home'),
                    onPressed: () => Navigator.popUntil(context, (route) => route.isFirst),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.amber,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailCard(String title, List<Widget> children) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[850],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.amber.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min, // FIXED: Prevent overflow
        children: [
          Text(
            title,
            style: const TextStyle(
              color: Colors.amber,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          ...children,
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded( // FIXED: Use Expanded for label
            flex: 2,
            child: Text(
              label,
              style: const TextStyle(color: Colors.white70),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(width: 8),
          Expanded( // FIXED: Use Expanded for value
            flex: 3,
            child: Text(
              value,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.end,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  void _showMessageDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.grey[850],
        title: Text(
          'Message ${washerData['name']}',
          style: const TextStyle(color: Colors.white),
          overflow: TextOverflow.ellipsis, // FIXED: Add overflow handling
        ),
        content: SingleChildScrollView( // FIXED: Wrap in SingleChildScrollView
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Send a message about your booking:',
                style: TextStyle(color: Colors.white70),
              ),
              const SizedBox(height: 16),
              TextField(
                maxLines: 4,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  hintText: 'Ask about timing, location details, special requests...',
                  hintStyle: TextStyle(color: Colors.grey[400]),
                  filled: true,
                  fillColor: Colors.grey[800],
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Message sent to washer!'),
                  backgroundColor: Colors.green,
                ),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.amber),
            child: const Text('Send Message'),
          ),
        ],
      ),
    );
  }
}