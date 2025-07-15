import 'package:flutter/material.dart';

class CustomerJobPostingPage extends StatelessWidget {
  const CustomerJobPostingPage({super.key});

  @override
  Widget build(BuildContext context) {
    const washMooseColor = Color(0xFF00C2CB);

    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const SizedBox(height: 40),

                      // Main icon
                      Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          color: washMooseColor.withOpacity(0.1),
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: washMooseColor.withOpacity(0.3),
                            width: 2,
                          ),
                        ),
                        child: const Icon(
                          Icons.build_circle_outlined,
                          size: 40,
                          color: washMooseColor,
                        ),
                      ),

                      const SizedBox(height: 20),

                      // Title
                      const Text(
                        "Custom Job Posting",
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                        textAlign: TextAlign.center,
                      ),

                      const SizedBox(height: 10),

                      // Description
                      Text(
                        "Need something special? Custom job posting is coming soon!",
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[300],
                        ),
                        textAlign: TextAlign.center,
                      ),

                      const SizedBox(height: 20),

                      // Feature preview
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.grey[850],
                          borderRadius: BorderRadius.circular(10),
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
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: washMooseColor,
                              ),
                            ),
                            const SizedBox(height: 8),
                            _buildFeatureItem("📸", "Upload photos"),
                            _buildFeatureItem("✍️", "Describe requirements"),
                            _buildFeatureItem("💰", "Set budget"),
                            _buildFeatureItem("🤝", "Get quotes"),
                          ],
                        ),
                      ),

                      const SizedBox(height: 20),

                      // CTA text
                      Text(
                        "For now, try our fixed packages:",
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[400],
                        ),
                      ),

                      const SizedBox(height: 12),

                      // Navigate to services button
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: () {
                            Navigator.pushNamedAndRemoveUntil(
                              context,
                              '/main',
                              (route) => false,
                            );
                          },
                          icon: const Icon(Icons.cleaning_services, size: 18),
                          label: const Text("Browse Our Services"),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: washMooseColor,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 8),

                      // Notify button
                      SizedBox(
                        width: double.infinity,
                        child: OutlinedButton.icon(
                          onPressed: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: const Text("We'll notify you when ready!"),
                                backgroundColor: washMooseColor,
                                duration: const Duration(seconds: 2),
                              ),
                            );
                          },
                          icon: const Icon(Icons.notifications_outlined, size: 16),
                          label: const Text("Notify Me"),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: washMooseColor,
                            side: const BorderSide(color: washMooseColor),
                            padding: const EdgeInsets.symmetric(vertical: 10),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 24),
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

  Widget _buildFeatureItem(String emoji, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        children: [
          Text(emoji, style: const TextStyle(fontSize: 14)),
          const SizedBox(width: 8),
          Text(
            text,
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}
