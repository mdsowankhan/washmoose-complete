import 'package:flutter/material.dart';

class WasherBrowseOffersPage extends StatelessWidget {
  final String washerType;
  
  const WasherBrowseOffersPage({
    super.key,
    this.washerType = 'everyday',
  });

  @override
  Widget build(BuildContext context) {
    // Use color based on washer type
    final themeColor = washerType == 'expert' ? Colors.amber : const Color(0xFF00C2CB);
    
    // Check if this is Expert Moose
    final bool isExpertMoose = washerType == 'expert';
    
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
                  color: themeColor.withOpacity(0.1),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: themeColor.withOpacity(0.3),
                    width: 2,
                  ),
                ),
                child: Icon(
                  isExpertMoose ? Icons.search : Icons.lock,
                  size: 50,
                  color: themeColor,
                ),
              ),
              
              const SizedBox(height: 24),
              
              // Title
              Text(
                isExpertMoose ? "Browse & Offers" : "Expert Feature Only",
                style: const TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
                textAlign: TextAlign.center,
              ),
              
              const SizedBox(height: 12),
              
              // Description
              Text(
                isExpertMoose 
                    ? "Browse customer job posts and make offers - coming soon!"
                    : "This feature is exclusively for Expert Moose washers",
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey[300],
                  height: 1.4,
                ),
                textAlign: TextAlign.center,
              ),
              
              const SizedBox(height: 24),
              
              // Feature preview or restriction message
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: Colors.grey[850],
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: themeColor.withOpacity(0.2),
                    width: 1,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      isExpertMoose ? "Coming Features:" : "Expert Moose Features:",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: themeColor,
                      ),
                    ),
                    const SizedBox(height: 14),
                    _buildFeatureItem("🔍", "Browse customer job postings"),
                    _buildFeatureItem("💰", "Make competitive offers"),
                    _buildFeatureItem("💬", "Negotiate with customers"),
                    _buildFeatureItem("✅", "Accept jobs and get paid"),
                    
                    if (!isExpertMoose) ...[
                      const SizedBox(height: 16),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.amber.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.amber.withOpacity(0.3)),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.star, color: Colors.amber, size: 20),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                "As an Everyday Moose, you focus on WashMoose's fixed services with guaranteed job allocation!",
                                style: TextStyle(
                                  color: Colors.amber[200],
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              
              const SizedBox(height: 28),
              
              // CTA for current features
              Text(
                isExpertMoose 
                    ? "For now, focus on your fixed services:"
                    : "Your focus as an Everyday Moose:",
                style: TextStyle(
                  fontSize: 15,
                  color: Colors.grey[400],
                ),
              ),
              
              const SizedBox(height: 18),
              
              // Navigate to services button or alternative action
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () {
                    if (isExpertMoose) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: const Text("My Services tab coming soon!"),
                          backgroundColor: themeColor,
                          duration: const Duration(seconds: 2),
                        ),
                      );
                    } else {
                      // Navigate back to jobs tab for Everyday Moose
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: const Text("Check the Jobs tab for available work!"),
                          backgroundColor: themeColor,
                          duration: const Duration(seconds: 2),
                        ),
                      );
                    }
                  },
                  icon: Icon(
                    isExpertMoose ? Icons.tune : Icons.work,
                    size: 20,
                  ),
                  label: Text(isExpertMoose ? "Manage My Services" : "Go to Available Jobs"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: themeColor,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
              
              const SizedBox(height: 14),
              
              // Secondary button
              if (isExpertMoose) ...[
                // Notify when ready button for Expert Moose
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: const Text("We'll notify you when Browse & Offers is available!"),
                          backgroundColor: themeColor,
                          duration: const Duration(seconds: 3),
                          behavior: SnackBarBehavior.floating,
                        ),
                      );
                    },
                    icon: const Icon(Icons.notifications_outlined, size: 18),
                    label: const Text("Notify Me When Ready"),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: themeColor,
                      side: BorderSide(color: themeColor),
                      padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
              ] else ...[
                // Info button for Everyday Moose
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: () {
                      _showEverydayMooseInfo(context);
                    },
                    icon: const Icon(Icons.info_outline, size: 18),
                    label: const Text("Learn About Expert Moose"),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.amber,
                      side: const BorderSide(color: Colors.amber),
                      padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
              ],
              
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
  
  void _showEverydayMooseInfo(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.grey[850],
        title: Row(
          children: [
            const Icon(Icons.star, color: Colors.amber, size: 24),
            const SizedBox(width: 8),
            const Text(
              'Expert Moose vs Everyday Moose',
              style: TextStyle(color: Colors.white, fontSize: 18),
            ),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildInfoSection(
                'Everyday Moose (You)',
                const Color(0xFF00C2CB),
                [
                  '✅ Fixed WashMoose packages',
                  '✅ Guaranteed job allocation',
                  '✅ Tools provided by WashMoose',
                  '✅ Steady, reliable income',
                  '✅ No customer negotiation needed',
                ],
              ),
              const SizedBox(height: 16),
              _buildInfoSection(
                'Expert Moose',
                Colors.amber,
                [
                  '⭐ Custom pricing & services',
                  '⭐ Browse & negotiate custom jobs',
                  '⭐ Use own equipment',
                  '⭐ Higher earning potential',
                  '⭐ Build personal brand',
                ],
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.blue.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.blue.withOpacity(0.3)),
                ),
                child: const Text(
                  '💡 Both roles are valuable! Everyday Moose focuses on reliable service delivery, while Expert Moose handles specialized detailing work.',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 14,
                  ),
                ),
              ),
            ],
          ),
        ),
        actions: [
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF00C2CB),
            ),
            child: const Text('Got it!'),
          ),
        ],
      ),
    );
  }
  
  Widget _buildInfoSection(String title, Color color, List<String> items) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            color: color,
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        const SizedBox(height: 8),
        ...items.map((item) => Padding(
          padding: const EdgeInsets.only(bottom: 4),
          child: Text(
            item,
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 14,
            ),
          ),
        )),
      ],
    );
  }
}