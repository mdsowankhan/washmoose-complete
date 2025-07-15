import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'wash_components.dart';
import 'app_theme.dart';
import 'address_collection_page.dart'; // UPDATED: Import address collection

class RegularWashPage extends StatefulWidget {
  final int initialVehicleIndex;
  
  const RegularWashPage({
    super.key, 
    this.initialVehicleIndex = 0,
  });

  @override
  State<RegularWashPage> createState() => _RegularWashPageState();
}

class _RegularWashPageState extends State<RegularWashPage> {
  int? selectedVehicleIndex;
  int? selectedPackageIndex;
  List<bool> selectedAddOns = [];

  DateTime? selectedDate;
  String? selectedTime;
  bool isASAP = false; // New ASAP option

  // Regular wash package map with included service details
  final regularPackageMap = {
    0: [
      {
        'title': 'Interior Only', 
        'price': 25, 
        'time': 25, 
        'services': [
          'Vacuum interior',
          'Clean dashboard',
          'Clean door panels',
          'Clean & sanitize surfaces',
          'Window cleaning (interior)',
        ]
      },
      {
        'title': 'Exterior Only', 
        'price': 25, 
        'time': 25,
        'services': [
          'Pre-rinse',
          'Foam wash',
          'Hand wash',
          'Wheel cleaning',
          'Window cleaning (exterior)',
        ]
      },
      {
        'title': 'Full Inside & Out', 
        'price': 45, 
        'time': 55,
        'services': [
          'Full interior vacuum',
          'Dashboard cleaning',
          'Door panel cleaning',
          'Window cleaning (all)',
          'Pre-rinse & foam wash',
          'Hand wash & dry',
          'Wheel cleaning',
        ]
      },
    ],
    1: [
      {
        'title': 'Interior Only', 
        'price': 25, 
        'time': 25,
        'services': [
          'Vacuum interior',
          'Clean dashboard',
          'Clean door panels',
          'Clean & sanitize surfaces',
          'Window cleaning (interior)',
        ]
      },
      {
        'title': 'Exterior Only', 
        'price': 30, 
        'time': 30,
        'services': [
          'Pre-rinse',
          'Foam wash',
          'Hand wash',
          'Wheel cleaning',
          'Window cleaning (exterior)',
        ]
      },
      {
        'title': 'Full Inside & Out', 
        'price': 50, 
        'time': 60,
        'services': [
          'Full interior vacuum',
          'Dashboard cleaning',
          'Door panel cleaning',
          'Window cleaning (all)',
          'Pre-rinse & foam wash',
          'Hand wash & dry',
          'Wheel cleaning',
        ]
      },
    ],
    2: [
      {
        'title': 'Interior Only', 
        'price': 30, 
        'time': 30,
        'services': [
          'Vacuum interior',
          'Clean dashboard',
          'Clean door panels',
          'Clean & sanitize surfaces',
          'Window cleaning (interior)',
        ]
      },
      {
        'title': 'Exterior Only', 
        'price': 35, 
        'time': 35,
        'services': [
          'Pre-rinse',
          'Foam wash',
          'Hand wash',
          'Wheel cleaning',
          'Window cleaning (exterior)',
        ]
      },
      {
        'title': 'Full Inside & Out', 
        'price': 60, 
        'time': 70,
        'services': [
          'Full interior vacuum',
          'Dashboard cleaning',
          'Door panel cleaning',
          'Window cleaning (all)',
          'Pre-rinse & foam wash',
          'Hand wash & dry',
          'Wheel cleaning',
        ]
      },
    ],
    3: [
      {
        'title': 'Interior Only', 
        'price': 40, 
        'time': 40,
        'services': [
          'Vacuum interior',
          'Clean dashboard',
          'Clean door panels',
          'Clean & sanitize surfaces',
          'Window cleaning (interior)',
        ]
      },
      {
        'title': 'Exterior Only', 
        'price': 45, 
        'time': 45,
        'services': [
          'Pre-rinse',
          'Foam wash',
          'Hand wash',
          'Wheel cleaning',
          'Window cleaning (exterior)',
        ]
      },
      {
        'title': 'Full Inside & Out', 
        'price': 80, 
        'time': 90,
        'services': [
          'Full interior vacuum',
          'Dashboard cleaning',
          'Door panel cleaning',
          'Window cleaning (all)',
          'Pre-rinse & foam wash',
          'Hand wash & dry',
          'Wheel cleaning',
        ]
      },
    ],
  };

  // Add-on map for each vehicle type
  final addOnMap = {
    0: [
      {'title': 'Light Pet Hair Removal', 'price': 5, 'time': 5},
      {'title': 'Excess Cleaning', 'price': 15, 'time': 15},
      {'title': 'Fragrance', 'price': 5, 'time': 0},
    ],
    1: [
      {'title': 'Light Pet Hair Removal', 'price': 5, 'time': 5},
      {'title': 'Excess Cleaning', 'price': 15, 'time': 15},
      {'title': 'Fragrance', 'price': 5, 'time': 0},
    ],
    2: [
      {'title': 'Light Pet Hair Removal', 'price': 10, 'time': 10},
      {'title': 'Excess Cleaning', 'price': 20, 'time': 20},
      {'title': 'Fragrance', 'price': 5, 'time': 0},
    ],
    3: [
      {'title': 'Light Pet Hair Removal', 'price': 15, 'time': 15},
      {'title': 'Excess Cleaning', 'price': 25, 'time': 25},
      {'title': 'Fragrance', 'price': 5, 'time': 0},
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
          selectedAddOns = List.filled(addOnMap[selectedVehicleIndex]!.length, false);
        });
      }
    });
  }

  void onVehicleSelect(int index) {
    setState(() {
      selectedVehicleIndex = index;
      selectedPackageIndex = null;
      selectedAddOns = List.filled(addOnMap[index]!.length, false);
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

  void toggleAddOn(int index) {
    setState(() {
      selectedAddOns[index] = !selectedAddOns[index];
    });
  }

  int calculateTotalPrice() {
    if (selectedPackageIndex == null || selectedVehicleIndex == null) return 0;
    final packages = regularPackageMap[selectedVehicleIndex]!;
    int price = packages[selectedPackageIndex!]['price'] as int;
    final addOns = addOnMap[selectedVehicleIndex]!;
    for (int i = 0; i < selectedAddOns.length; i++) {
      if (selectedAddOns[i]) price += addOns[i]['price'] as int;
    }
    return price;
  }

  int calculateTotalTime() {
    if (selectedPackageIndex == null || selectedVehicleIndex == null) return 0;
    final packages = regularPackageMap[selectedVehicleIndex]!;
    int time = packages[selectedPackageIndex!]['time'] as int;
    final addOns = addOnMap[selectedVehicleIndex]!;
    for (int i = 0; i < selectedAddOns.length; i++) {
      if (selectedAddOns[i]) time += addOns[i]['time'] as int;
    }
    return time;
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
              primary: AppTheme.primaryColor,
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
      final packages = regularPackageMap[selectedVehicleIndex]!;
      final vehicleLabel = vehicleTypes[selectedVehicleIndex!]['label'];
      
      // Navigate to address collection with all booking data
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => const AddressCollectionPage(serviceType: 'regular'),
          settings: RouteSettings(
            arguments: {
              'vehicleType': vehicleLabel is String ? vehicleLabel : 'Unknown Vehicle',
              'packageName': packages[selectedPackageIndex!]['title'] as String,
              'addOns': getSelectedAddOnLabels(selectedVehicleIndex, selectedAddOns),
              'date': isASAP ? 'ASAP' : DateFormat.yMMMd().format(selectedDate!),
              'time': isASAP ? '' : selectedTime!,
              'totalPrice': calculateTotalPrice().toDouble(),
              'duration': calculateTotalTime(),
              'serviceType': 'regular',
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
    final Color serviceColor = AppTheme.primaryColor;
    
    return buildWashPageScaffold(
      context: context,
      title: 'Regular Wash',
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
    final packages = regularPackageMap[selectedVehicleIndex!];
    final addOns = addOnMap[selectedVehicleIndex!];
    final vehicleLabel = vehicleTypes[selectedVehicleIndex!]['label'];
    
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Regular Wash Options for ${vehicleLabel is String ? vehicleLabel : 'Selected Vehicle'}',
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF111827),
            ),
          ),
          const SizedBox(height: 16),
          
          // Package cards
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: packages!.length,
            itemBuilder: (context, index) {
              final package = packages[index];
              final isSelected = selectedPackageIndex == index;
              
              return buildPackageCard(
                package: package,
                isSelected: isSelected,
                index: index,
                serviceColor: serviceColor,
                onSelect: selectPackage,
              );
            },
          ),
          
          if (selectedPackageIndex != null) ...[
            const SizedBox(height: 24),
            
            // Add-ons section
            const Text(
              'Add-ons',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF111827),
              ),
            ),
            const SizedBox(height: 16),
            
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: addOns!.length,
              itemBuilder: (context, index) {
                final addon = addOns[index];
                final isSelected = index < selectedAddOns.length && selectedAddOns[index];
                
                return Card(
                  margin: const EdgeInsets.only(bottom: 8),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                    side: BorderSide(
                      color: isSelected ? serviceColor : Color(0xFFE5E7EB),
                      width: isSelected ? 2 : 1,
                    ),
                  ),
                  color: isSelected ? serviceColor.withOpacity(0.1) : Colors.white,
                  child: CheckboxListTile(
                    title: Text(
                      addon['title'] as String,
                      style: TextStyle(
                        color: isSelected ? serviceColor : Color(0xFF111827),
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                      ),
                    ),
                    subtitle: Text(
                      '\$${addon['price']} • ${addon['time']} min',
                      style: TextStyle(
                        color: Color(0xFF6B7280),
                      ),
                    ),
                    value: isSelected,
                    onChanged: (value) {
                      setState(() {
                        if (index < selectedAddOns.length) {
                          selectedAddOns[index] = value ?? false;
                        }
                      });
                    },
                    activeColor: serviceColor,
                    checkColor: Colors.white,
                  ),
                );
              },
            ),
            
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
                              'We\'ll get a washer to you as soon as possible!',
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
                    buildSummaryRow(
                      'Add-ons', 
                      getSelectedAddOnLabels(selectedVehicleIndex, selectedAddOns).isEmpty 
                          ? 'None' 
                          : getSelectedAddOnLabels(selectedVehicleIndex, selectedAddOns).join(', ')
                    ),
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
                          backgroundColor: serviceColor,
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
}