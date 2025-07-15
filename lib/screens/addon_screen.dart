import 'package:flutter/material.dart';
import 'datetime_screen.dart';
import 'app_theme.dart';
import 'wash_components.dart';

class AddonScreen extends StatefulWidget {
  final String vehicleType;
  final String packageType;
  final int vehicleIndex;

  const AddonScreen({
    super.key, 
    required this.vehicleType,
    required this.packageType,
    required this.vehicleIndex,
  });

  @override
  State<AddonScreen> createState() => _AddonScreenState();
}

class _AddonScreenState extends State<AddonScreen> {
  List<bool> selectedAddOns = [];

  @override
  void initState() {
    super.initState();
    // Initialize the selected add-ons list based on the vehicle index
    selectedAddOns = List.filled(addOnMap[widget.vehicleIndex]!.length, false);
  }

  int calculateTotalPrice() {
    int addOnPrice = 0;
    final addOns = addOnMap[widget.vehicleIndex]!;
    for (int i = 0; i < selectedAddOns.length; i++) {
      if (selectedAddOns[i]) addOnPrice += addOns[i]['price'] as int;
    }
    return addOnPrice;
  }

  int calculateTotalTime() {
    int addOnTime = 0;
    final addOns = addOnMap[widget.vehicleIndex]!;
    for (int i = 0; i < selectedAddOns.length; i++) {
      if (selectedAddOns[i]) addOnTime += addOns[i]['time'] as int;
    }
    return addOnTime;
  }

  @override
  Widget build(BuildContext context) {
    final Color serviceColor = AppTheme.primaryColor;
    
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Add-ons",
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
        backgroundColor: serviceColor,
        elevation: 0,
      ),
      body: Container(
        decoration: BoxDecoration(
          color: Color(0xFFF9FAFB),
        ),
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20.0),
                decoration: BoxDecoration(
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 4,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Choose Add-ons',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF111827),
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Enhance your wash experience with these premium extras',
                      style: TextStyle(
                        fontSize: 16,
                        color: Color(0xFF6B7280),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              
              // Add-ons list
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: addOnMap[widget.vehicleIndex]!.length,
                  itemBuilder: (context, index) {
                    final addon = addOnMap[widget.vehicleIndex]![index];
                    final isSelected = selectedAddOns[index];
                    
                    return Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      decoration: BoxDecoration(
                        color: isSelected ? serviceColor.withOpacity(0.05) : Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: isSelected ? serviceColor : Color(0xFFE5E7EB),
                          width: isSelected ? 2.5 : 1.5,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: isSelected ? serviceColor.withOpacity(0.15) : Colors.black.withOpacity(0.05),
                            blurRadius: isSelected ? 8 : 4,
                            offset: Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          onTap: () {
                            setState(() {
                              selectedAddOns[index] = !selectedAddOns[index];
                            });
                          },
                          borderRadius: BorderRadius.circular(16),
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Row(
                              children: [
                                // Custom checkbox
                                Container(
                                  width: 24,
                                  height: 24,
                                  decoration: BoxDecoration(
                                    color: isSelected ? serviceColor : Colors.transparent,
                                    border: Border.all(
                                      color: isSelected ? serviceColor : Color(0xFFD1D5DB),
                                      width: 2,
                                    ),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: isSelected
                                      ? Icon(
                                          Icons.check,
                                          color: Colors.white,
                                          size: 16,
                                        )
                                      : null,
                                ),
                                
                                SizedBox(width: 16),
                                
                                // Content
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        addon['label'] as String,
                                        style: TextStyle(
                                          color: Color(0xFF111827),
                                          fontWeight: FontWeight.w600,
                                          fontSize: 16,
                                          height: 1.3,
                                        ),
                                      ),
                                      SizedBox(height: 4),
                                      Row(
                                        children: [
                                          Container(
                                            padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                            decoration: BoxDecoration(
                                              color: serviceColor.withOpacity(0.1),
                                              borderRadius: BorderRadius.circular(8),
                                            ),
                                            child: Text(
                                              '\$${addon['price']}',
                                              style: TextStyle(
                                                color: serviceColor,
                                                fontWeight: FontWeight.w700,
                                                fontSize: 14,
                                              ),
                                            ),
                                          ),
                                          SizedBox(width: 8),
                                          Text(
                                            '• ${addon['time']} min',
                                            style: TextStyle(
                                              color: Color(0xFF6B7280),
                                              fontWeight: FontWeight.w500,
                                              fontSize: 14,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                                
                                // Arrow indicator
                                Icon(
                                  isSelected ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                                  color: isSelected ? serviceColor : Color(0xFF9CA3AF),
                                  size: 20,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
              
              // Summary and Next button
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 8,
                      offset: Offset(0, -4),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    // Total summary
                    Container(
                      padding: EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Color(0xFFF9FAFB),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Color(0xFFE5E7EB)),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Total Add-ons:',
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF111827),
                              fontSize: 16,
                            ),
                          ),
                          Text(
                            '\$${calculateTotalPrice()} • +${calculateTotalTime()} min',
                            style: TextStyle(
                              fontWeight: FontWeight.w700,
                              color: serviceColor,
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                    ),
                    
                    SizedBox(height: 16),
                    
                    // Continue button
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.push(
                            context, 
                            MaterialPageRoute(builder: (_) => DateTimeScreen())
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: serviceColor,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'Continue to Date & Time',
                              style: TextStyle(
                                fontWeight: FontWeight.w700,
                                fontSize: 16,
                                color: Colors.white,
                              ),
                            ),
                            SizedBox(width: 8),
                            Icon(
                              Icons.arrow_forward,
                              color: Colors.white,
                              size: 20,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}