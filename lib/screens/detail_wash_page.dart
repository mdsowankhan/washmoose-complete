import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'wash_components.dart';
import 'app_theme.dart';
import 'address_collection_page.dart'; // UPDATED: Import address collection

class DetailWashPage extends StatefulWidget {
  final int initialVehicleIndex;
  
  const DetailWashPage({
    super.key, 
    this.initialVehicleIndex = 0,
  });

  @override
  State<DetailWashPage> createState() => _DetailWashPageState();
}

class _DetailWashPageState extends State<DetailWashPage> {
  int? selectedVehicleIndex;
  int? selectedPackageIndex;
  DateTime? selectedDate;
  String? selectedTime;
  bool isASAP = false; // New ASAP option
  
  // ✅ FIXED: Complete detail wash package map with all vehicle types
  final detailPackageMap = {
    0: [ // Sedan
      {
        'title': 'Interior Detail', 
        'price': 129, 
        'time': 120,
        'services': [
          'Deep leather cleaning & conditioning',
          'Carpet & fabric seat extraction',
          'Dashboard & trim restoration',
          'Compartment & cup holder cleaning',
          'Door jam & boot cleaning',
          'Premium interior treatment',
        ]
      },
      {
        'title': 'Exterior Detail', 
        'price': 129, 
        'time': 120,
        'services': [
          'Clay bar decontamination',
          'Light scratch & swirl correction',
          'Trim protection & enhancement',
          'Professional paint sealant',
          'Premium wash & wax',
          'Wheel & tire treatment',
        ]
      },
      {
        'title': 'Full Detail', 
        'price': 219, 
        'time': 220,
        'services': [
          'Complete interior restoration',
          'Professional paint correction',
          'Enhanced trim conditioning',
          'Long-lasting paint protection',
          'Premium interior & exterior care',
          'Complete surface treatment',
        ]
      },
      {
        'title': 'Paint Protection', 
        'price': 279, 
        'time': 240,
        'services': [
          'Advanced clay bar process',
          'Professional scratch correction',
          'Superior trim restoration',
          'Advanced paint protection system',
          'Premium surface treatments',
          'Complete detail package',
        ]
      },
    ],
    1: [ // Small SUV
      {
        'title': 'Interior Detail', 
        'price': 155, 
        'time': 135,
        'services': [
          'Deep leather cleaning & conditioning',
          'Carpet & fabric seat extraction',
          'Dashboard & trim restoration',
          'Compartment & cup holder cleaning',
          'Door jam & boot cleaning',
          'Premium interior treatment',
        ]
      },
      {
        'title': 'Exterior Detail', 
        'price': 155, 
        'time': 135,
        'services': [
          'Clay bar decontamination',
          'Light scratch & swirl correction',
          'Trim protection & enhancement',
          'Professional paint sealant',
          'Premium wash & wax',
          'Wheel & tire treatment',
        ]
      },
      {
        'title': 'Full Detail', 
        'price': 265, 
        'time': 245,
        'services': [
          'Complete interior restoration',
          'Professional paint correction',
          'Enhanced trim conditioning',
          'Long-lasting paint protection',
          'Premium interior & exterior care',
          'Complete surface treatment',
        ]
      },
      {
        'title': 'Paint Protection', 
        'price': 335, 
        'time': 270,
        'services': [
          'Advanced clay bar process',
          'Professional scratch correction',
          'Superior trim restoration',
          'Advanced paint protection system',
          'Premium surface treatments',
          'Complete detail package',
        ]
      },
    ],
    2: [ // Large SUV
      {
        'title': 'Interior Detail', 
        'price': 180, 
        'time': 150,
        'services': [
          'Deep leather cleaning & conditioning',
          'Carpet & fabric seat extraction',
          'Dashboard & trim restoration',
          'Compartment & cup holder cleaning',
          'Door jam & boot cleaning',
          'Premium interior treatment',
        ]
      },
      {
        'title': 'Exterior Detail', 
        'price': 180, 
        'time': 150,
        'services': [
          'Clay bar decontamination',
          'Light scratch & swirl correction',
          'Trim protection & enhancement',
          'Professional paint sealant',
          'Premium wash & wax',
          'Wheel & tire treatment',
        ]
      },
      {
        'title': 'Full Detail', 
        'price': 305, 
        'time': 270,
        'services': [
          'Complete interior restoration',
          'Professional paint correction',
          'Enhanced trim conditioning',
          'Long-lasting paint protection',
          'Premium interior & exterior care',
          'Complete surface treatment',
        ]
      },
      {
        'title': 'Paint Protection', 
        'price': 390, 
        'time': 300,
        'services': [
          'Advanced clay bar process',
          'Professional scratch correction',
          'Superior trim restoration',
          'Advanced paint protection system',
          'Premium surface treatments',
          'Complete detail package',
        ]
      },
    ],
    3: [ // Van/12-seater
      {
        'title': 'Interior Detail', 
        'price': 220, 
        'time': 180,
        'services': [
          'Deep leather cleaning & conditioning',
          'Carpet & fabric seat extraction',
          'Dashboard & trim restoration',
          'Compartment & cup holder cleaning',
          'Door jam & boot cleaning',
          'Premium interior treatment',
        ]
      },
      {
        'title': 'Exterior Detail', 
        'price': 220, 
        'time': 180,
        'services': [
          'Clay bar decontamination',
          'Light scratch & swirl correction',
          'Trim protection & enhancement',
          'Professional paint sealant',
          'Premium wash & wax',
          'Wheel & tire treatment',
        ]
      },
      {
        'title': 'Full Detail', 
        'price': 375, 
        'time': 320,
        'services': [
          'Complete interior restoration',
          'Professional paint correction',
          'Enhanced trim conditioning',
          'Long-lasting paint protection',
          'Premium interior & exterior care',
          'Complete surface treatment',
        ]
      },
      {
        'title': 'Paint Protection', 
        'price': 475, 
        'time': 360,
        'services': [
          'Advanced clay bar process',
          'Professional scratch correction',
          'Superior trim restoration',
          'Advanced paint protection system',
          'Premium surface treatments',
          'Complete detail package',
        ]
      },
    ],
  };

  @override
  void initState() {
    super.initState();
    
    // Use the initially selected vehicle index
    Future.delayed(Duration.zero, () {
      if (mounted) {
        setState(() {
          selectedVehicleIndex = widget.initialVehicleIndex;
        });
      }
    });
  }

  void onVehicleSelect(int index) {
    setState(() {
      selectedVehicleIndex = index;
      selectedPackageIndex = null;
      selectedDate = null;
      selectedTime = null;
      isASAP = false; // Reset ASAP when changing vehicle
    });
  }

  void selectPackage(int index) {
    setState(() {
      selectedPackageIndex = index;
    });
  }

  int calculateTotalPrice() {
    if (selectedPackageIndex == null || selectedVehicleIndex == null) return 0;
    final packages = detailPackageMap[selectedVehicleIndex]!;
    return packages[selectedPackageIndex!]['price'] as int;
  }

  int calculateTotalTime() {
    if (selectedPackageIndex == null || selectedVehicleIndex == null) return 0;
    final packages = detailPackageMap[selectedVehicleIndex]!;
    return packages[selectedPackageIndex!]['time'] as int;
  }

  Future<void> pickDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: now,
      firstDate: now,
      lastDate: now.add(const Duration(days: 30)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: Colors.green,
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: Color(0xFF111827),
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        selectedDate = picked;
        selectedTime = null;
      });
    }
  }

  // ✅ FIXED: Navigate to address collection with isASAP parameter
  void proceedToBooking() {
    if (selectedVehicleIndex != null &&
        selectedPackageIndex != null &&
        (isASAP || (selectedDate != null && selectedTime != null))) {
      final packages = detailPackageMap[selectedVehicleIndex]!;
      final vehicleLabel = vehicleTypes[selectedVehicleIndex!]['label'];
      
      // Navigate to address collection with all booking data
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => const AddressCollectionPage(serviceType: 'detail'),
          settings: RouteSettings(
            arguments: {
              'vehicleType': vehicleLabel is String ? vehicleLabel : 'Unknown Vehicle',
              'packageName': packages[selectedPackageIndex!]['title'] as String,
              'addOns': <String>[], // No add-ons for detail wash
              'date': isASAP ? 'ASAP' : DateFormat.yMMMd().format(selectedDate!),
              'time': isASAP ? '' : selectedTime!,
              'totalPrice': calculateTotalPrice().toDouble(),
              'duration': calculateTotalTime(),
              'serviceType': 'detail',
              'isASAP': isASAP, // ✅ FIXED: Added missing isASAP parameter
            },
          ),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please complete all selections')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final Color serviceColor = Colors.green; // Use green for detail wash
    
    return buildWashPageScaffold(
      context: context,
      title: 'Detail Wash',
      serviceColor: serviceColor,
      selectedVehicleIndex: selectedVehicleIndex,
      onVehicleSelect: onVehicleSelect,
      content: selectedVehicleIndex == null 
          ? Center(
              child: Text(
                'Please select a vehicle type above',
                style: TextStyle(color: Color(0xFF6B7280)),
              ),
            )
          : _buildMainContent(serviceColor),
    );
  }

  Widget _buildMainContent(Color serviceColor) {
    final packages = detailPackageMap[selectedVehicleIndex!];
    final vehicleLabel = vehicleTypes[selectedVehicleIndex!]['label'];
    
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Detail Wash Options for ${vehicleLabel is String ? vehicleLabel : 'Selected Vehicle'}',
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF111827),
            ),
          ),
          const SizedBox(height: 16),
          
          // First row - Interior and Exterior Details
          Row(
            children: [
              // Interior Detail Card
              Expanded(
                child: _buildDetailPackageCard(
                  packages![0], 
                  isSelected: selectedPackageIndex == 0,
                  index: 0,
                  serviceColor: serviceColor,
                ),
              ),
              const SizedBox(width: 10),
              // Exterior Detail Card
              Expanded(
                child: _buildDetailPackageCard(
                  packages[1], 
                  isSelected: selectedPackageIndex == 1,
                  index: 1,
                  serviceColor: serviceColor,
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 10),
          
          // Second row - Full Detail and Paint Protection
          Row(
            children: [
              // Full Detail Card
              Expanded(
                child: _buildDetailPackageCard(
                  packages[2], 
                  isSelected: selectedPackageIndex == 2,
                  index: 2,
                  serviceColor: serviceColor,
                ),
              ),
              const SizedBox(width: 10),
              // Paint Protection Card
              Expanded(
                child: _buildDetailPackageCard(
                  packages[3], 
                  isSelected: selectedPackageIndex == 3,
                  index: 3,
                  serviceColor: serviceColor,
                ),
              ),
            ],
          ),
          
          if (selectedPackageIndex != null) ...[
            const SizedBox(height: 24),
            
            // Date & Time selection with ASAP option
            const Text(
              'Select Date & Time',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF111827),
              ),
            ),
            const SizedBox(height: 16),
            
            Card(
              color: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: BorderSide(color: Color(0xFFE5E7EB)),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ASAP vs Custom Time Toggle
                    Row(
                      children: [
                        Expanded(
                          child: GestureDetector(
                            onTap: () {
                              setState(() {
                                isASAP = true;
                                selectedDate = null;
                                selectedTime = null;
                              });
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              decoration: BoxDecoration(
                                color: isASAP ? serviceColor : Color(0xFFF7F8FA),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.flash_on,
                                    color: isASAP ? Colors.white : Color(0xFF6B7280),
                                    size: 20,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    'ASAP',
                                    style: TextStyle(
                                      color: isASAP ? Colors.white : Color(0xFF6B7280),
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: GestureDetector(
                            onTap: () {
                              setState(() {
                                isASAP = false;
                                selectedDate = null;
                                selectedTime = null;
                              });
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              decoration: BoxDecoration(
                                color: !isASAP ? serviceColor : Color(0xFFF7F8FA),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.schedule,
                                    color: !isASAP ? Colors.white : Color(0xFF6B7280),
                                    size: 20,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    'Custom Time',
                                    style: TextStyle(
                                      color: !isASAP ? Colors.white : Color(0xFF6B7280),
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    
                    const SizedBox(height: 16),
                    
                    // Show ASAP message or custom time selection
                    if (isASAP) ...[
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: serviceColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: serviceColor.withOpacity(0.3)),
                        ),
                        child: Column(
                          children: [
                            Icon(
                              Icons.flash_on,
                              color: serviceColor,
                              size: 32,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'ASAP Service Selected',
                              style: TextStyle(
                                color: serviceColor,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 4),
                            const Text(
                              'We\'ll get a detailing specialist to you as soon as possible!',
                              style: TextStyle(
                                color: Color(0xFF6B7280),
                                fontSize: 14,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                    ] else ...[
                      // Custom date/time selection
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          icon: const Icon(Icons.calendar_today),
                          label: Text(
                            selectedDate == null 
                                ? 'Select Date' 
                                : DateFormat.yMMMd().format(selectedDate!),
                            style: const TextStyle(fontSize: 16),
                          ),
                          onPressed: pickDate,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: selectedDate != null 
                                ? serviceColor 
                                : Color(0xFFF7F8FA),
                            foregroundColor: selectedDate != null 
                                ? Colors.white 
                                : Color(0xFF6B7280),
                            padding: const EdgeInsets.symmetric(vertical: 12),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'Choose Time',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF111827),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: generateTimeSlots().map((slot) {
                          final isSelectedTime = selectedTime == slot;
                          final isDisabled = selectedDate == null;
                          
                          return ChoiceChip(
                            label: Text(slot),
                            selected: isSelectedTime,
                            onSelected: isDisabled 
                                ? null 
                                : (selected) {
                                    if (selected) {
                                      setState(() {
                                        selectedTime = slot;
                                      });
                                    }
                                  },
                            backgroundColor: Color(0xFFF7F8FA),
                            selectedColor: serviceColor,
                            disabledColor: Color(0xFFF3F4F6),
                            labelStyle: TextStyle(
                              color: isSelectedTime 
                                  ? Colors.white 
                                  : isDisabled 
                                      ? Color(0xFF9CA3AF)
                                      : Color(0xFF111827),
                            ),
                          );
                        }).toList(),
                      ),
                    ],
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 24),
            
            // Booking summary
            Card(
              color: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: BorderSide(color: Color(0xFFE5E7EB)),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Booking Summary',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF111827),
                      ),
                    ),
                    const SizedBox(height: 16),
                    buildSummaryRow('Vehicle', vehicleLabel is String ? vehicleLabel : 'Selected Vehicle'),
                    buildSummaryRow('Package', packages[selectedPackageIndex!]['title'] as String),
                    if (isASAP)
                      buildSummaryRow('Service Time', 'ASAP'),
                    if (!isASAP && selectedDate != null)
                      buildSummaryRow('Date', DateFormat.yMMMd().format(selectedDate!)),
                    if (!isASAP && selectedTime != null)
                      buildSummaryRow('Time', selectedTime!),
                    
                    const Divider(height: 24, color: Color(0xFFE5E7EB)),
                    
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Total Price:',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF111827),
                          ),
                        ),
                        Text(
                          '\$${calculateTotalPrice()}',
                          style: TextStyle(
                            fontSize: 22,
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
                        const Text(
                          'Estimated Duration:',
                          style: TextStyle(
                            fontSize: 14,
                            color: Color(0xFF6B7280),
                          ),
                        ),
                        Text(
                          '${calculateTotalTime()} minutes',
                          style: const TextStyle(
                            fontSize: 14,
                            color: Color(0xFF6B7280),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: (isASAP || (selectedDate != null && selectedTime != null))
                            ? proceedToBooking
                            : null,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green[700],
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          disabledBackgroundColor: Color(0xFFF3F4F6),
                        ),
                        child: const Text(
                          'CONTINUE', // UPDATED: Changed from 'BOOK NOW' to 'CONTINUE'
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 40),
          ],
        ],
      ),
    );
  }
  
  // ✅ FIXED: Corrected string interpolation in price display
  Widget _buildDetailPackageCard(Map<String, dynamic> package, {
    required bool isSelected,
    required int index,
    required Color serviceColor,
  }) {
    final title = package['title'] as String;
    final price = package['price'] as int;
    final time = package['time'] as int;
    final services = package['services'] as List<dynamic>;
    
    return Card(
      elevation: isSelected ? 8 : 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: isSelected ? serviceColor : Color(0xFFE5E7EB),
          width: isSelected ? 2 : 1,
        ),
      ),
      color: isSelected ? serviceColor.withOpacity(0.05) : Colors.white,
      child: InkWell(
        onTap: () => selectPackage(index),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Package Title
              Text(
                title,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: isSelected ? serviceColor : Color(0xFF111827),
                ),
              ),
              
              // ✅ FIXED: Corrected string interpolation
              Text(
                '\$$price • $time min',
                style: TextStyle(
                  fontSize: 14,
                  color: isSelected ? serviceColor : Color(0xFF6B7280),
                ),
              ),
              
              const Divider(height: 16, color: Color(0xFFE5E7EB)),
              
              // Services Included (bullet points)
              ...services.take(6).map((service) => Padding(
                padding: const EdgeInsets.only(bottom: 3),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('• ', style: TextStyle(color: isSelected ? serviceColor : Colors.green[600])),
                    Expanded(
                      child: Text(
                        service as String,
                        style: const TextStyle(
                          color: Color(0xFF374151),
                          fontSize: 12,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              )),
              
              const SizedBox(height: 12),
              
              // Select button
              Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: isSelected ? serviceColor : Color(0xFF111827),
                  borderRadius: BorderRadius.circular(8),
                ),
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Center(
                  child: Text(
                    isSelected ? 'SELECTED' : 'SELECT',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
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