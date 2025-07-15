import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

// Vehicle types data - shared across both pages
final vehicleTypes = [
  {'label': 'Sedan / Hatchback / Coupe', 'image': 'assets/icons/sedan.jpg', 'icon': Icons.directions_car},
  {'label': 'SUV (5-Seater)', 'image': 'assets/icons/smallsuv.jpg', 'icon': Icons.directions_car},
  {'label': 'Large SUV (6–8 Seater) / Ute / 1T Van', 'image': 'assets/icons/largesuv.jpg', 'icon': Icons.directions_car},
  {'label': 'People Mover (9–12 Seater) / 2T Van', 'image': 'assets/icons/12seater.jpg', 'icon': Icons.airport_shuttle},
];

// Add-on data - shared across both pages
final addOnMap = {
  0: [
    {'label': 'Light Pet Hair Removal', 'price': 15, 'time': 15},
    {'label': 'Heavy Pet Hair Removal', 'price': 20, 'time': 20},
    {'label': 'Excess Cleaning - Level 1 (Not washed for 1+ month)', 'price': 10, 'time': 10},
    {'label': 'Excess Cleaning - Level 2 (Not washed for 3+ months)', 'price': 15, 'time': 15},
    {'label': 'Excess Cleaning - Level 3 (Extremely dirty, mud-covered or heavily soiled)', 'price': 30, 'time': 25},
    {'label': 'Fragrance', 'price': 5, 'time': 5},
  ],
  1: [
    {'label': 'Light Pet Hair Removal', 'price': 20, 'time': 20},
    {'label': 'Heavy Pet Hair Removal', 'price': 30, 'time': 20},
    {'label': 'Excess Cleaning - Level 1 (Not washed for 1+ month)', 'price': 10, 'time': 10},
    {'label': 'Excess Cleaning - Level 2 (Not washed for 3+ months)', 'price': 15, 'time': 15},
    {'label': 'Excess Cleaning - Level 3 (Extremely dirty, mud-covered or heavily soiled)', 'price': 40, 'time': 25},
    {'label': 'Fragrance', 'price': 5, 'time': 5},
  ],
  2: [
    {'label': 'Light Pet Hair Removal', 'price': 25, 'time': 20},
    {'label': 'Heavy Pet Hair Removal', 'price': 35, 'time': 25},
    {'label': 'Excess Cleaning - Level 1 (Not washed for 1+ month)', 'price': 15, 'time': 15},
    {'label': 'Excess Cleaning - Level 2 (Not washed for 3+ months)', 'price': 20, 'time': 20},
    {'label': 'Excess Cleaning - Level 3 (Extremely dirty, mud-covered or heavily soiled)', 'price': 50, 'time': 35},
    {'label': 'Fragrance', 'price': 5, 'time': 5},
  ],
  3: [
    {'label': 'Light Pet Hair Removal', 'price': 40, 'time': 30},
    {'label': 'Heavy Pet Hair Removal', 'price': 50, 'time': 40},
    {'label': 'Excess Cleaning - Level 1 (Not washed for 1+ month)', 'price': 25, 'time': 20},
    {'label': 'Excess Cleaning - Level 2 (Not washed for 3+ months)', 'price': 30, 'time': 30},
    {'label': 'Excess Cleaning - Level 3 (Extremely dirty, mud-covered or heavily soiled)', 'price': 60, 'time': 50},
    {'label': 'Fragrance', 'price': 10, 'time': 5},
  ],
};

// Utility functions
List<String> generateTimeSlots() {
  List<String> times = [];
  for (int hour = 8; hour <= 20; hour++) {
    times.add(DateFormat.jm().format(DateTime(0, 0, 0, hour, 0)));
    if (hour != 20) {
      times.add(DateFormat.jm().format(DateTime(0, 0, 0, hour, 30)));
    }
  }
  return times;
}

// Extract addon labels without parentheses descriptions
List<String> getSelectedAddOnLabels(int? vehicleIndex, List<bool> selectedAddOns) {
  if (vehicleIndex == null) return [];
  final addOns = addOnMap[vehicleIndex]!;
  List<String> selected = [];
  for (int i = 0; i < selectedAddOns.length; i++) {
    if (selectedAddOns[i]) {
      String label = addOns[i]['label'] as String;
      if (label.contains('(')) {
        label = label.substring(0, label.indexOf('(')).trim();
      }
      selected.add(label);
    }
  }
  return selected;
}

// UI Components
Widget buildVehicleIcon({
  required int index, 
  required String label, 
  required IconData icon,
  required int? selectedVehicleIndex,
  required Color serviceColor,
  required Function(int) onSelect,
}) {
  final bool isSelected = selectedVehicleIndex == index;
  
  return GestureDetector(
    onTap: () => onSelect(index),
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 70,
          height: 70,
          decoration: BoxDecoration(
            color: isSelected ? serviceColor.withOpacity(0.15) : Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected ? serviceColor : Color(0xFFD1D5DB),
              width: isSelected ? 2.5 : 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: isSelected ? serviceColor.withOpacity(0.2) : Colors.black.withOpacity(0.05),
                blurRadius: isSelected ? 8 : 4,
                offset: Offset(0, 2),
              ),
            ],
          ),
          child: Icon(
            icon,
            color: isSelected ? serviceColor : Color(0xFF374151),
            size: 32,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: TextStyle(
            color: isSelected ? serviceColor : Color(0xFF111827),
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
            fontSize: 12,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    ),
  );
}

Widget buildPackageCard({
  required Map<String, dynamic> package,
  required bool isSelected,
  required int index,
  required Color serviceColor,
  required Function(int) onSelect,
}) {
  final title = package['title'] as String;
  final price = package['price'] as int;
  final time = package['time'] as int;
  final services = package['services'] as List<dynamic>;
  
  return Container(
    margin: const EdgeInsets.only(bottom: 16),
    decoration: BoxDecoration(
      color: isSelected ? serviceColor.withOpacity(0.05) : Colors.white,
      borderRadius: BorderRadius.circular(16),
      border: Border.all(
        color: isSelected ? serviceColor : Color(0xFFE5E7EB),
        width: isSelected ? 2.5 : 1.5,
      ),
      boxShadow: [
        BoxShadow(
          color: isSelected ? serviceColor.withOpacity(0.15) : Colors.black.withOpacity(0.08),
          blurRadius: isSelected ? 12 : 6,
          offset: Offset(0, isSelected ? 4 : 2),
        ),
      ],
    ),
    child: Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => onSelect(index),
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header with title and price
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      title,
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF111827),
                        height: 1.2,
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: isSelected ? serviceColor : Color(0xFF111827),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      '\$$price',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 8),
              
              // Duration
              Text(
                'Duration: $time minutes',
                style: TextStyle(
                  color: Color(0xFF6B7280),
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
              
              const SizedBox(height: 16),
              
              // Divider
              Container(
                height: 1,
                color: Color(0xFFE5E7EB),
              ),
              
              const SizedBox(height: 16),
              
              // Services header
              Text(
                'Services Included:',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF111827),
                ),
              ),
              
              const SizedBox(height: 12),
              
              // Services list
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: services.map<Widget>((service) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          margin: EdgeInsets.only(top: 2),
                          child: Icon(
                            Icons.check_circle,
                            color: isSelected ? serviceColor : Color(0xFF10B981),
                            size: 18,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            service as String,
                            style: TextStyle(
                              color: Color(0xFF374151),
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              height: 1.4,
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),
              
              const SizedBox(height: 20),
              
              // Selection button
              Container(
                width: double.infinity,
                height: 50,
                decoration: BoxDecoration(
                  color: isSelected ? serviceColor : Color(0xFF111827),
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: (isSelected ? serviceColor : Color(0xFF111827)).withOpacity(0.3),
                      blurRadius: 8,
                      offset: Offset(0, 4),
                    ),
                  ],
                ),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: () => onSelect(index),
                    borderRadius: BorderRadius.circular(12),
                    child: Center(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          if (isSelected) ...[
                            Icon(
                              Icons.check_circle,
                              color: Colors.white,
                              size: 20,
                            ),
                            SizedBox(width: 8),
                          ],
                          Text(
                            isSelected ? 'SELECTED' : 'SELECT PACKAGE',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w700,
                              fontSize: 16,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    ),
  );
}

Widget buildSummaryRow(String label, String value) {
  return Padding(
    padding: const EdgeInsets.only(bottom: 12),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 120,
          child: Text(
            '$label:',
            style: TextStyle(
              color: Color(0xFF6B7280),
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: TextStyle(
              color: Color(0xFF111827),
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    ),
  );
}

// Helper function for vehicle details text (DARK TEXT FOR LIGHT BACKGROUNDS)
Widget buildVehicleDetailsText(String text) {
  return Text(
    text,
    style: TextStyle(
      fontSize: 16,
      fontWeight: FontWeight.w600,
      color: Color(0xFF111827), // DARK TEXT - VERY VISIBLE
    ),
  );
}

// Helper function for package description text
Widget buildPackageDescription(String text) {
  return Text(
    text,
    style: TextStyle(
      fontSize: 14,
      color: Color(0xFF374151), // DARK GREY - VERY VISIBLE
      fontWeight: FontWeight.w500,
    ),
  );
}

// Common page scaffold for wash pages
Widget buildWashPageScaffold({
  required BuildContext context,
  required String title,
  required Color serviceColor,
  required int? selectedVehicleIndex,
  required Function(int) onVehicleSelect,
  required Widget content,
}) {
  return Scaffold(
    appBar: AppBar(
      title: Text(
        title,
        style: TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w600,
        ),
      ),
      backgroundColor: serviceColor,
      centerTitle: true,
      elevation: 0,
    ),
    body: Container(
      decoration: BoxDecoration(
        color: Color(0xFFF9FAFB),
      ),
      child: SafeArea(
        child: Column(
          children: [
            // Vehicle type icons row
            Container(
              padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border(
                  bottom: BorderSide(color: Color(0xFFE5E7EB), width: 1),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 4,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Text(
                    'Select Vehicle Type',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF111827),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      buildVehicleIcon(
                        index: 0,
                        label: 'Sedan', 
                        icon: Icons.directions_car,
                        selectedVehicleIndex: selectedVehicleIndex,
                        serviceColor: serviceColor,
                        onSelect: onVehicleSelect,
                      ),
                      buildVehicleIcon(
                        index: 1,
                        label: 'SUV', 
                        icon: Icons.directions_car_filled,
                        selectedVehicleIndex: selectedVehicleIndex,
                        serviceColor: serviceColor,
                        onSelect: onVehicleSelect,
                      ),
                      buildVehicleIcon(
                        index: 2,
                        label: 'Large SUV', 
                        icon: Icons.directions_car_filled_outlined,
                        selectedVehicleIndex: selectedVehicleIndex,
                        serviceColor: serviceColor,
                        onSelect: onVehicleSelect,
                      ),
                      buildVehicleIcon(
                        index: 3,
                        label: 'Van', 
                        icon: Icons.airport_shuttle,
                        selectedVehicleIndex: selectedVehicleIndex,
                        serviceColor: serviceColor,
                        onSelect: onVehicleSelect,
                      ),
                    ],
                  ),
                ],
              ),
            ),
            
            // Main content area
            Expanded(
              child: selectedVehicleIndex == null
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.directions_car_outlined,
                            size: 64,
                            color: Color(0xFF9CA3AF),
                          ),
                          SizedBox(height: 16),
                          Text(
                            'Please select a vehicle type above',
                            style: TextStyle(
                              color: Color(0xFF6B7280),
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    )
                  : Container(
                      padding: EdgeInsets.all(16),
                      child: content,
                    ),
            ),
          ],
        ),
      ),
    ),
  );
}