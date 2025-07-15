import 'package:flutter/material.dart';
import 'washer_login_page.dart';

class WasherTypeSelectionPage extends StatelessWidget {
  const WasherTypeSelectionPage({super.key});

  @override
  Widget build(BuildContext context) {
    const washMooseColor = Color(0xFF00C2CB);

    return Scaffold(
      backgroundColor: const Color(0xFFFAFBFC),
      appBar: AppBar(
        title: const Text('Join WashMoose Team'),
        backgroundColor: washMooseColor,
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              // 🎯 SMALL COMPACT HEADER BAR
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                decoration: BoxDecoration(
                  color: washMooseColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: washMooseColor.withOpacity(0.2)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.local_car_wash,
                      size: 20,
                      color: washMooseColor,
                    ),
                    const SizedBox(width: 8),
                    const Text(
                      'Choose Your Role',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1A202C),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // 🌟 BIG EVERYDAY MOOSE CARD
              Expanded(
                flex: 2,
                child: _buildCleanRoleCard(
                  context,
                  title: 'Everyday Moose',
                  subtitle: 'Standard Service Provider',
                  icon: Icons.directions_car,
                  color: Colors.amber,
                  gradient: [Colors.amber, Colors.orange.shade300],
                  bulletPoints: [
                    'Fixed packages',
                    'Work on your own schedule',
                    'Regular wash',
                    'Easy sign up',
                    'Basic experience needed',
                  ],
                  washerType: 'everyday',
                ),
              ),

              const SizedBox(height: 16),

              // 🎯 BIG EXPERT MOOSE CARD
              Expanded(
                flex: 2,
                child: _buildCleanRoleCard(
                  context,
                  title: 'Expert Moose',
                  subtitle: 'Premium Detail Specialist',
                  icon: Icons.star,
                  color: washMooseColor,
                  gradient: [washMooseColor, Colors.blue.shade400],
                  bulletPoints: [
                    'Premium services',
                    'Work on your own schedule',
                    'Advanced tools needed',
                    'Well experience needed',
                  ],
                  washerType: 'expert',
                ),
              ),

              const SizedBox(height: 20),

              // 📖 LEARN MORE BUTTON
              Container(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () => _showLearnMoreDialog(context),
                  icon: Icon(Icons.info_outline, size: 18, color: washMooseColor),
                  label: Text(
                    'Learn More About Each Role',
                    style: TextStyle(
                      color: washMooseColor,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  style: OutlinedButton.styleFrom(
                    padding: EdgeInsets.symmetric(vertical: 12),
                    side: BorderSide(color: washMooseColor),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 12),

              // 💡 UPGRADE INFO
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.amber.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.amber.withOpacity(0.3)),
                ),
                child: Row(
                  children: [
                    Icon(Icons.upgrade, color: Colors.amber, size: 16),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'You can upgrade from Everyday to Expert Moose later!',
                        style: TextStyle(
                          color: Colors.amber[800],
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
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

  // 🎯 ULTRA COMPACT ROLE CARD (PERFECT FIT)
  Widget _buildCleanRoleCard(
    BuildContext context, {
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required List<Color> gradient,
    required List<String> bulletPoints,
    required String washerType,
  }) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          // ULTRA COMPACT HEADER
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 14),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: gradient,
              ),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.25),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Icon(icon, size: 16, color: Colors.white),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      Text(
                        subtitle,
                        style: TextStyle(
                          fontSize: 10,
                          color: Colors.white.withOpacity(0.9),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // MAXIMUM CONTENT SPACE
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                children: [
                  // BULLET POINTS (MAXIMUM SPACE)
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        ...bulletPoints.map((point) => Padding(
                          padding: const EdgeInsets.only(bottom: 4),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                width: 4,
                                height: 4,
                                margin: const EdgeInsets.only(top: 5),
                                decoration: BoxDecoration(
                                  color: color,
                                  shape: BoxShape.circle,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  point,
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: Color(0xFF4A5568),
                                    fontWeight: FontWeight.w500,
                                    height: 1.2,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        )),
                      ],
                    ),
                  ),
                  
                  const SizedBox(height: 10),
                  
                  // CLEAN BUTTON (NO REDUNDANT TEXT)
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => WasherLoginPage(washerType: washerType),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: color,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        elevation: 2,
                      ),
                      child: const Text(
                        'Sign Up/Sign In',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // 📖 LEARN MORE DIALOG (UNCHANGED)
  void _showLearnMoreDialog(BuildContext context) {
    const washMooseColor = Color(0xFF00C2CB);
    
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Container(
          constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.8),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // HEADER
              Container(
                padding: EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [washMooseColor.withOpacity(0.1), Colors.blue.withOpacity(0.05)],
                  ),
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(20),
                    topRight: Radius.circular(20),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(Icons.info_outline, color: washMooseColor, size: 24),
                    SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Role Details',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1A202C),
                        ),
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: Icon(Icons.close, color: Color(0xFF6C757D)),
                    ),
                  ],
                ),
              ),
              
              // SCROLLABLE CONTENT
              Flexible(
                child: SingleChildScrollView(
                  padding: EdgeInsets.all(20),
                  child: Column(
                    children: [
                      _buildDetailedRoleSection(
                        title: 'Everyday Moose',
                        color: Colors.amber,
                        icon: Icons.directions_car,
                        earningPercentage: '85%',
                        features: [
                          'Fixed WashMoose service packages',
                          'Regular wash services',
                          'Work on your own schedule',
                          'Steady income stream',
                          'Standard service delivery',
                        ],
                        benefits: [
                          'Earn 85% of job earnings',
                          'Consistent work availability',
                          'Simple service structure',
                          'Minimum experience required',
                        ],
                      ),
                      
                      SizedBox(height: 24),
                      
                      _buildDetailedRoleSection(
                        title: 'Expert Moose',
                        color: washMooseColor,
                        icon: Icons.star,
                        earningPercentage: '90%',
                        features: [
                          'Premium detail services',
                          'Advanced cleaning techniques',
                          'Complex vehicle treatments',
                          'Work on your own schedule',
                          'WashMoose premium packages',
                        ],
                        benefits: [
                          'Earn 90% of job earnings',
                          'Premium service rates',
                          'Specialized work focus',
                          'Well experience and in-depth knowledge required',
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // 📖 DETAILED ROLE SECTION WIDGET (UNCHANGED)
  Widget _buildDetailedRoleSection({
    required String title,
    required Color color,
    required IconData icon,
    required String earningPercentage,
    required List<String> features,
    required List<String> benefits,
  }) {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, size: 20, color: color),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
              ),
              // EARNING PERCENTAGE IN DIALOG
              Container(
                padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  'Earn $earningPercentage',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 12),
          
          Text(
            'What You\'ll Do:',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1A202C),
            ),
          ),
          const SizedBox(height: 6),
          ...features.map((feature) => Padding(
            padding: const EdgeInsets.only(bottom: 3),
            child: Row(
              children: [
                Icon(Icons.check, size: 12, color: color),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    feature,
                    style: const TextStyle(
                      fontSize: 11,
                      color: Color(0xFF4A5568),
                    ),
                  ),
                ),
              ],
            ),
          )),
          
          const SizedBox(height: 8),
          
          Text(
            'Key Benefits:',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1A202C),
            ),
          ),
          const SizedBox(height: 6),
          ...benefits.map((benefit) => Padding(
            padding: const EdgeInsets.only(bottom: 3),
            child: Row(
              children: [
                Icon(Icons.star, size: 12, color: Colors.green),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    benefit,
                    style: const TextStyle(
                      fontSize: 11,
                      color: Color(0xFF4A5568),
                    ),
                  ),
                ),
              ],
            ),
          )),
        ],
      ),
    );
  }
}