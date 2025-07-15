import 'package:flutter/material.dart';
import 'regular_wash_page.dart';
import 'detail_wash_page.dart';
import 'app_theme.dart';
import 'wash_components.dart';

class VehicleSelectionPage extends StatefulWidget {
  final String serviceType;

  const VehicleSelectionPage({
    super.key, 
    this.serviceType = 'regular',
  });

  @override
  State<VehicleSelectionPage> createState() => _VehicleSelectionPageState();
}

class _VehicleSelectionPageState extends State<VehicleSelectionPage> {
  int selectedVehicleIndex = 0; // Default to sedan
  
  @override
  Widget build(BuildContext context) {
    // Use appropriate color based on service type
    final Color serviceColor = widget.serviceType == 'regular' 
        ? AppTheme.primaryColor 
        : Colors.green;
    
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.serviceType == 'regular' ? 'Regular Wash' : 'Detail Wash'),
        backgroundColor: serviceColor,
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.black,
              Color(0xFF121212),
              Color(0xFF181818),
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Vehicle Type Selection
              Container(
                padding: const EdgeInsets.symmetric(vertical: 16),
                decoration: BoxDecoration(
                  color: serviceColor.withOpacity(0.1),
                  border: Border(
                    bottom: BorderSide(color: Colors.grey.withOpacity(0.3)),
                  ),
                ),
                child: Column(
                  children: [
                    const Text(
                      'Select Vehicle Type',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        for (int i = 0; i < vehicleTypes.length; i++)
                          buildVehicleIcon(
                            index: i,
                            label: i == 0 ? 'Sedan' : 
                                   i == 1 ? 'SUV' : 
                                   i == 2 ? 'Large SUV' : 'Van',
                            icon: vehicleTypes[i]['icon'] as IconData,
                            selectedVehicleIndex: selectedVehicleIndex,
                            serviceColor: serviceColor,
                            onSelect: (index) {
                              setState(() {
                                selectedVehicleIndex = index;
                              });
                            },
                          ),
                      ],
                    ),
                  ],
                ),
              ),
              
              // Continue Button
              Expanded(
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'You selected: ${vehicleTypes[selectedVehicleIndex]['label']}',
                          style: TextStyle(
                            fontSize: 18,
                            color: Colors.white,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        SizedBox(height: 32),
                        SizedBox(
                          width: double.infinity,
                          height: 50,
                          child: ElevatedButton(
                            onPressed: () {
                              if (widget.serviceType == 'regular') {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => RegularWashPage(initialVehicleIndex: selectedVehicleIndex),
                                  ),
                                );
                              } else {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => DetailWashPage(initialVehicleIndex: selectedVehicleIndex),
                                  ),
                                );
                              }
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: serviceColor,
                            ),
                            child: Text(
                              'Continue',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ],
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