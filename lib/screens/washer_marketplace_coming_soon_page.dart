import 'package:flutter/material.dart';

class WasherMarketplaceComingSoonPage extends StatelessWidget {
  const WasherMarketplaceComingSoonPage({super.key});

  @override
  Widget build(BuildContext context) {
    const washMooseColor = Color(0xFF00C2CB);

    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            children: [
              const SizedBox(height: 60),
              
              // Main icon
              Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  color: washMooseColor.withOpacity(0.1),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: washMooseColor.withOpacity(0.3),
                    width: 2,
                  ),
                ),
                child: const Icon(
                  Icons.storefront,
                  size: 50,
                  color: washMooseColor,
                ),
              ),
              
              const SizedBox(height: 24),
              
              // Title
              const Text(
                "Washer Marketplace",
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
                textAlign: TextAlign.center,
              ),
              
              const SizedBox(height: 12),
              
              // Coming soon message
              Text(
                "Find expert washers near you - coming soon!",
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey[300],
                  height: 1.4,
                ),
                textAlign: TextAlign.center,
              ),
              
              const SizedBox(height: 24),
              
              // Feature preview
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: Colors.grey[850],
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: washMooseColor.withOpacity(0.2),
                    width: 1,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Coming Features:",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: washMooseColor,
                      ),
                    ),
                    const SizedBox(height: 14),
                    _buildFeatureItem("👥", "Browse verified expert washers"),
                    _buildFeatureItem("⭐", "View ratings and portfolio photos"),
                    _buildFeatureItem("💰", "Compare custom pricing packages"),
                    _buildFeatureItem("💬", "Message washers directly"),
                    _buildFeatureItem("📍", "Find washers near your location"),
                    _buildFeatureItem("🔒", "Secure booking with reviews"),
                  ],
                ),
              ),
              
              const SizedBox(height: 28),
              
              // CTA for current services
              Text(
                "For now, choose from our standard services:",
                style: TextStyle(
                  fontSize: 15,
                  color: Colors.grey[400],
                ),
              ),
              
              const SizedBox(height: 18),
              
              // Navigate to services button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () {
                    // Navigate to service selection (home tab)
                    Navigator.pushNamedAndRemoveUntil(
                      context,
                      '/main',
                      (route) => false,
                    );
                  },
                  icon: const Icon(Icons.cleaning_services, size: 20),
                  label: const Text("Browse Our Services"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: washMooseColor,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
              
              const SizedBox(height: 14),
              
              // Notify when ready button
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: const Text("We'll notify you when the marketplace is ready!"),
                        backgroundColor: washMooseColor,
                        duration: const Duration(seconds: 3),
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                  },
                  icon: const Icon(Icons.notifications_outlined, size: 18),
                  label: const Text("Notify Me When Ready"),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: washMooseColor,
                    side: BorderSide(color: washMooseColor),
                    padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
              
              const SizedBox(height: 60),
            ],
          ),
        ),
      ),
    );
  }
  
  Widget _buildFeatureItem(String emoji, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            emoji,
            style: const TextStyle(fontSize: 18),
          ),
          const SizedBox(width: 12),
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
}