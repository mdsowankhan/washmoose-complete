import 'package:flutter/material.dart';

class EverydayMooseServicesPage extends StatefulWidget {
  final String washerType;
  
  const EverydayMooseServicesPage({
    super.key,
    this.washerType = 'everyday',
  });

  @override
  State<EverydayMooseServicesPage> createState() => _EverydayMooseServicesPageState();
}

class _EverydayMooseServicesPageState extends State<EverydayMooseServicesPage> {
  final Color themeColor = const Color(0xFF00C2CB);
  
  // Fixed WashMoose service packages for Everyday Moose
  List<Map<String, dynamic>> washMooseServices = [
    {
      'name': 'Interior Only',
      'description': 'Complete interior cleaning including vacuum, dashboard, and surface sanitization.',
      'pricing': {'Sedan': 25, 'SUV': 25, 'Large SUV': 30, 'Van': 40},
      'duration': {'Sedan': 25, 'SUV': 25, 'Large SUV': 30, 'Van': 40},
      'isActive': true,
    },
    {
      'name': 'Exterior Only',
      'description': 'Thorough exterior wash with foam, hand wash, and wheel cleaning.',
      'pricing': {'Sedan': 25, 'SUV': 30, 'Large SUV': 35, 'Van': 45},
      'duration': {'Sedan': 25, 'SUV': 30, 'Large SUV': 35, 'Van': 45},
      'isActive': true,
    },
    {
      'name': 'Full Inside & Out',
      'description': 'Complete interior and exterior cleaning service.',
      'pricing': {'Sedan': 45, 'SUV': 50, 'Large SUV': 60, 'Van': 80},
      'duration': {'Sedan': 55, 'SUV': 60, 'Large SUV': 70, 'Van': 90},
      'isActive': true,
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Everyday Moose Services'),
        backgroundColor: themeColor,
        automaticallyImplyLeading: false,  // 👈 FIXED! Removes back button
        actions: [
          IconButton(
            icon: const Icon(Icons.info_outline),
            onPressed: () => _showEverydayMooseInfo(),
            tooltip: 'About Everyday Moose',
          ),
        ],
      ),
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Column(
          children: [
            // Header info
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: themeColor.withOpacity(0.1),
                border: Border(
                  bottom: BorderSide(color: themeColor.withOpacity(0.3)),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.cleaning_services, color: themeColor, size: 24),
                      const SizedBox(width: 8),
                      Text(
                        'WashMoose Fixed Services',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: themeColor,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Manage your availability for WashMoose\'s standard packages',
                    style: TextStyle(
                      color: Colors.grey[300],
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
            
            // Services list
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: washMooseServices.length,
                itemBuilder: (context, index) {
                  return _buildServiceCard(washMooseServices[index], index);
                },
              ),
            ),
            
            // Info section
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey[900],
                border: Border(
                  top: BorderSide(color: Colors.grey[800]!),
                ),
              ),
              child: Column(
                children: [
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: themeColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: themeColor.withOpacity(0.3)),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.info, color: themeColor, size: 20),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Everyday Moose Benefits:',
                                style: TextStyle(
                                  color: themeColor,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                ),
                              ),
                              const SizedBox(height: 4),
                              const Text(
                                '• Guaranteed job allocation\n• Tools provided by WashMoose\n• Fixed pricing - no complex decisions\n• Focus on quality service delivery',
                                style: TextStyle(
                                  color: Colors.white70,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: _saveServiceAvailability,
                      icon: const Icon(Icons.save, size: 20),
                      label: const Text('Save Availability'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: themeColor,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildServiceCard(Map<String, dynamic> service, int index) {
    final isActive = service['isActive'] as bool;
    
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: isActive ? themeColor.withOpacity(0.3) : Colors.grey.withOpacity(0.2),
          width: 1,
        ),
      ),
      color: isActive ? Colors.grey[850] : Colors.grey[900],
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with service name and toggle
            Row(
              children: [
                Expanded(
                  child: Text(
                    service['name'],
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: isActive ? Colors.white : Colors.grey[500],
                    ),
                  ),
                ),
                Switch(
                  value: isActive,
                  onChanged: (value) {
                    setState(() {
                      washMooseServices[index]['isActive'] = value;
                    });
                  },
                  activeColor: themeColor,
                ),
                const SizedBox(width: 8),
                Text(
                  isActive ? 'Available' : 'Unavailable',
                  style: TextStyle(
                    fontSize: 12,
                    color: isActive ? themeColor : Colors.grey[500],
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            
            if (isActive) ...[
              const SizedBox(height: 12),
              
              // Description
              Text(
                'Service Description:',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: themeColor,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                service['description'],
                style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 14,
                  height: 1.3,
                ),
              ),
              
              const SizedBox(height: 12),
              
              // Fixed pricing table
              Text(
                'WashMoose Fixed Pricing:',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: themeColor,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 8),
              
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey[800],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: themeColor.withOpacity(0.2)),
                ),
                child: Column(
                  children: [
                    _buildPricingRow('Vehicle Type', 'Customer Pays', 'You Earn', 'Duration', isHeader: true),
                    const Divider(color: Colors.grey, height: 8),
                    ...(service['pricing'] as Map<String, dynamic>).entries.map((entry) {
                      final vehicleType = entry.key;
                      final price = entry.value as int;
                      final duration = (service['duration'] as Map<String, dynamic>)[vehicleType] as int;
                      final washerEarning = (price * 0.75).toInt(); // 75% to washer
                      
                      return _buildPricingRow(
                        vehicleType,
                        '\$${price}',
                        '\$${washerEarning}',
                        '${duration}min',
                      );
                    }).toList(),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
  
  Widget _buildPricingRow(String vehicle, String customerPrice, String washerEarning, String duration, {bool isHeader = false}) {
    final textStyle = TextStyle(
      fontSize: 12,
      fontWeight: isHeader ? FontWeight.bold : FontWeight.normal,
      color: isHeader ? themeColor : Colors.white70,
    );
    
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Expanded(flex: 3, child: Text(vehicle, style: textStyle)),
          Expanded(flex: 2, child: Text(customerPrice, style: textStyle, textAlign: TextAlign.center)),
          Expanded(flex: 2, child: Text(washerEarning, style: textStyle, textAlign: TextAlign.center)),
          Expanded(flex: 2, child: Text(duration, style: textStyle, textAlign: TextAlign.center)),
        ],
      ),
    );
  }
  
  void _showEverydayMooseInfo() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.grey[850],
        title: Text(
          'Everyday Moose Benefits',
          style: TextStyle(color: themeColor),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildInfoItem("🎯", "Focus on service quality, not pricing"),
            _buildInfoItem("🔧", "All tools and supplies provided"),
            _buildInfoItem("📋", "Simple fixed service packages"),
            _buildInfoItem("💰", "Guaranteed 75% commission on all jobs"),
            _buildInfoItem("📱", "Job allocation through WashMoose system"),
            _buildInfoItem("🎓", "Training and support provided"),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.amber.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.amber.withOpacity(0.3)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Want more flexibility?',
                    style: TextStyle(
                      color: Colors.amber,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Consider upgrading to Expert Moose!',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            style: ElevatedButton.styleFrom(backgroundColor: themeColor),
            child: const Text('Got it!'),
          ),
        ],
      ),
    );
  }
  
  Widget _buildInfoItem(String icon, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(icon, style: const TextStyle(fontSize: 16)),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }
  
  void _saveServiceAvailability() {
    // Here you would save to Firebase/database
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Service availability saved! ✅'),
        backgroundColor: themeColor,
        duration: const Duration(seconds: 2),
      ),
    );
  }
}