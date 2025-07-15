import 'package:flutter/material.dart';

class WasherMyServicesPage extends StatelessWidget {
  final String washerType;
  
  const WasherMyServicesPage({
    super.key,
    this.washerType = 'everyday',
  });

  bool get isExpertMoose => washerType == 'expert';

  @override
  Widget build(BuildContext context) {
    final themeColor = isExpertMoose ? Colors.amber : const Color(0xFF00C2CB);
    
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Text(isExpertMoose ? 'Expert Moose Services' : 'Everyday Moose Services'),
        backgroundColor: themeColor,
        automaticallyImplyLeading: false,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(height: 60),
              
              // Animated Icon
              TweenAnimationBuilder<double>(
                tween: Tween(begin: 0.0, end: 1.0),
                duration: const Duration(seconds: 2),
                builder: (context, value, child) {
                  return Transform.scale(
                    scale: 0.8 + (0.2 * value),
                    child: Container(
                      padding: const EdgeInsets.all(32),
                      decoration: BoxDecoration(
                        color: themeColor.withOpacity(0.1),
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: themeColor.withOpacity(0.3),
                          width: 2,
                        ),
                      ),
                      child: Icon(
                        Icons.tune,
                        size: 80,
                        color: themeColor,
                      ),
                    ),
                  );
                },
              ),
              
              const SizedBox(height: 32),
              
              // Coming Soon Title
              TweenAnimationBuilder<double>(
                tween: Tween(begin: 0.0, end: 1.0),
                duration: const Duration(milliseconds: 1500),
                builder: (context, value, child) {
                  return Opacity(
                    opacity: value,
                    child: Text(
                      'My Services',
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: themeColor,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  );
                },
              ),
              
              const SizedBox(height: 12),
              
              // Coming Soon Subtitle
              TweenAnimationBuilder<double>(
                tween: Tween(begin: 0.0, end: 1.0),
                duration: const Duration(milliseconds: 2000),
                builder: (context, value, child) {
                  return Opacity(
                    opacity: value,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: themeColor.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: themeColor.withOpacity(0.5)),
                      ),
                      child: Text(
                        'COMING SOON',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: themeColor,
                          letterSpacing: 2,
                        ),
                      ),
                    ),
                  );
                },
              ),
              
              const SizedBox(height: 32),
              
              // Description
              TweenAnimationBuilder<double>(
                tween: Tween(begin: 0.0, end: 1.0),
                duration: const Duration(milliseconds: 2500),
                builder: (context, value, child) {
                  return Opacity(
                    opacity: value,
                    child: Text(
                      isExpertMoose 
                        ? 'Manage your premium services, custom packages, and advanced pricing options.'
                        : 'Customize your service offerings, set availability, and manage your pricing.',
                      style: TextStyle(
                        fontSize: 18,
                        color: Colors.grey[300],
                        height: 1.5,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  );
                },
              ),
              
              const SizedBox(height: 48),
              
              // Features Preview
              TweenAnimationBuilder<double>(
                tween: Tween(begin: 0.0, end: 1.0),
                duration: const Duration(milliseconds: 3000),
                builder: (context, value, child) {
                  return Opacity(
                    opacity: value,
                    child: Column(
                      children: [
                        Text(
                          'Upcoming Features:',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 24),
                        _buildFeatureCard(
                          icon: Icons.schedule,
                          title: 'Availability Management',
                          description: 'Set your working hours and days',
                          color: themeColor,
                        ),
                        const SizedBox(height: 16),
                        _buildFeatureCard(
                          icon: Icons.attach_money,
                          title: 'Custom Pricing',
                          description: 'Set your own service rates and packages',
                          color: themeColor,
                        ),
                        const SizedBox(height: 16),
                        _buildFeatureCard(
                          icon: Icons.location_on,
                          title: 'Service Areas',
                          description: 'Define your coverage zones',
                          color: themeColor,
                        ),
                        if (isExpertMoose) ...[
                          const SizedBox(height: 16),
                          _buildFeatureCard(
                            icon: Icons.star,
                            title: 'Premium Services',
                            description: 'Offer specialized detailing packages',
                            color: themeColor,
                          ),
                        ],
                      ],
                    ),
                  );
                },
              ),
              
              const SizedBox(height: 48),
              
              // Notification Card
              TweenAnimationBuilder<double>(
                tween: Tween(begin: 0.0, end: 1.0),
                duration: const Duration(milliseconds: 3500),
                builder: (context, value, child) {
                  return Opacity(
                    opacity: value,
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            themeColor.withOpacity(0.1),
                            themeColor.withOpacity(0.05),
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: themeColor.withOpacity(0.3),
                          width: 1,
                        ),
                      ),
                      child: Column(
                        children: [
                          Icon(
                            Icons.notifications_active,
                            color: themeColor,
                            size: 32,
                          ),
                          const SizedBox(height: 12),
                          Text(
                            'Get Notified',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'We\'ll notify you when My Services is ready to launch!',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[400],
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
              
              const SizedBox(height: 32),
              
              // Back to Jobs Button
              TweenAnimationBuilder<double>(
                tween: Tween(begin: 0.0, end: 1.0),
                duration: const Duration(milliseconds: 4000),
                builder: (context, value, child) {
                  return Opacity(
                    opacity: value,
                    child: ElevatedButton.icon(
                      onPressed: () {
                        // Show a simple message
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Go to Jobs tab to start earning!'),
                            backgroundColor: themeColor,
                            duration: const Duration(seconds: 2),
                          ),
                        );
                      },
                      icon: const Icon(Icons.work),
                      label: const Text('Start Taking Jobs'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: themeColor,
                        foregroundColor: isExpertMoose ? Colors.black : Colors.white,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 32,
                          vertical: 16,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                      ),
                    ),
                  );
                },
              ),
              
              const SizedBox(height: 60),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFeatureCard({
    required IconData icon,
    required String title,
    required String description,
    required Color color,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.grey[850],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: color.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              icon,
              color: color,
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[400],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}