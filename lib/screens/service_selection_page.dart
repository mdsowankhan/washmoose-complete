import 'package:flutter/material.dart';
import 'regular_wash_page.dart';
import 'detail_wash_page.dart';

class ServiceSelectionPage extends StatelessWidget {
  const ServiceSelectionPage({super.key});

  @override
  Widget build(BuildContext context) {
    // WashMoose teal color
    const washMooseColor = Color(0xFF00C2CB);

    return Scaffold(
      backgroundColor: const Color(0xFFFAFBFC), // ✅ CHANGED: Light background
      appBar: AppBar(
        title: const Text('Choose Your Service'),
        backgroundColor: washMooseColor,
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                // Simple header
                const SizedBox(height: 20),
                const Text(
                  'Select the perfect wash for your vehicle',
                  style: TextStyle(
                    fontSize: 16,
                    color: Color(0xFF4A5568),
                    fontWeight: FontWeight.w500,
                  ),
                  textAlign: TextAlign.center,
                ),
                
                const SizedBox(height: 40),
                
                // Regular Wash Card
                _buildServiceCard(
                  title: 'Regular Wash',
                  description: 'Standard cleaning service for your vehicle',
                  icon: Icons.directions_car,
                  color: washMooseColor,
                  features: const [
                    'Interior & exterior options',
                    'Quick service',
                    'Affordable pricing',
                  ],
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const RegularWashPage(),
                      ),
                    );
                  },
                ),
                
                const SizedBox(height: 20),
                
                // Detail Wash Card
                _buildServiceCard(
                  title: 'Detail Wash',
                  description: 'Premium cleaning with extra attention to detail',
                  icon: Icons.car_repair,
                  color: Colors.green,
                  features: const [
                    'Deep cleaning service',
                    'Paint protection options',
                    'Professional detailing',
                  ],
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const DetailWashPage(),
                      ),
                    );
                  },
                ),
                
                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),
    );
  }
  
  Widget _buildServiceCard({
    required String title,
    required String description,
    required IconData icon,
    required Color color,
    required List<String> features,
    required VoidCallback onTap,
  }) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: const Color(0xFFFFFFFF), // ✅ CHANGED: Clean white background
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFFE2E8F0), // ✅ CHANGED: Light border
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04), // ✅ CHANGED: Subtle shadow
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(24), // ✅ IMPROVED: Better internal padding
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header with icon and title
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(16), // ✅ IMPROVED: Larger icon container
                      decoration: BoxDecoration(
                        color: color.withOpacity(0.1), // ✅ CHANGED: Light tint
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: color.withOpacity(0.2),
                          width: 1,
                        ),
                      ),
                      child: Icon(
                        icon,
                        color: color,
                        size: 32, // ✅ IMPROVED: Larger icon
                      ),
                    ),
                    const SizedBox(width: 20), // ✅ IMPROVED: Better spacing
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            title,
                            style: TextStyle(
                              fontSize: 22, // ✅ IMPROVED: Larger title
                              fontWeight: FontWeight.bold,
                              color: color,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            description,
                            style: const TextStyle(
                              fontSize: 15, // ✅ IMPROVED: Better readability
                              color: Color(0xFF4A5568), // ✅ CHANGED: Dark text
                              height: 1.4,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                
                const SizedBox(height: 20), // ✅ IMPROVED: Better spacing
                
                // Features
                Column(
                  children: features
                    .map((feature) => Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4), // ✅ IMPROVED: Better spacing
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(2),
                            decoration: BoxDecoration(
                              color: color.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Icon(
                              Icons.check,
                              color: color,
                              size: 14,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Flexible(
                            child: Text(
                              feature,
                              style: const TextStyle(
                                color: Color(0xFF1A202C), // ✅ CHANGED: Dark text
                                fontSize: 15,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                    )).toList(),
                ),
                
                const SizedBox(height: 20), // ✅ IMPROVED: Better spacing
                
                // Enhanced Select button
                SizedBox(
                  width: double.infinity, // ✅ IMPROVED: Full width button
                  child: ElevatedButton(
                    onPressed: onTap,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: color,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16), // ✅ IMPROVED: Better padding
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 2,
                      shadowColor: color.withOpacity(0.3),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text(
                          'SELECT',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 0.5,
                          ),
                        ),
                        const SizedBox(width: 8),
                        const Icon(Icons.arrow_forward, size: 18),
                      ],
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
}