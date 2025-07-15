import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class CustomerSettingsHelpCenter extends StatefulWidget {
  const CustomerSettingsHelpCenter({super.key});

  @override
  State<CustomerSettingsHelpCenter> createState() => _CustomerSettingsHelpCenterState();
}

class _CustomerSettingsHelpCenterState extends State<CustomerSettingsHelpCenter> {
  // Search functionality
  final TextEditingController _searchController = TextEditingController();
  String searchQuery = '';
  List<Map<String, dynamic>> filteredFAQs = [];

  // FAQ categories and questions
  final List<Map<String, dynamic>> faqCategories = [
    {
      'category': 'Booking & Services',
      'icon': Icons.event_note,
      'color': Color(0xFF00C2CB),
      'faqs': [
        {
          'question': 'How do I book a car wash?',
          'answer': 'You can book a car wash in three ways:\n\n1. Fixed Packages: Select your vehicle type and preferred service package\n2. Custom Job Posting: Upload photos and describe your specific needs\n3. Washer Marketplace: Browse washer profiles and book directly\n\nAll bookings can be scheduled for immediate service or at a future time.',
        },
        {
          'question': 'How do I cancel or reschedule a booking?',
          'answer': 'To cancel or reschedule:\n\n1. Go to "My Bookings" in the app\n2. Find your booking and tap on it\n3. Select "Cancel" or "Reschedule"\n4. Confirm your choice\n\nNote: Cancellations made less than 2 hours before the appointment may incur a small fee.',
        },
        {
          'question': 'What if my washer doesn\'t show up?',
          'answer': 'If your washer doesn\'t arrive:\n\n1. Wait 15 minutes past the scheduled time\n2. Try contacting them through the app\n3. If no response, report the issue in "My Bookings"\n4. Our support team will find you a replacement washer\n\nYou won\'t be charged if the washer is a no-show.',
        },
        {
          'question': 'Can I request the same washer again?',
          'answer': 'Yes! If you had a great experience:\n\n1. Go to your booking history\n2. Find the washer you liked\n3. Tap "Book Again" or go to their profile\n4. You can also add them to your favorites\n\nMany customers build relationships with preferred washers.',
        },
      ],
    },
    {
      'category': 'Payments & Pricing',
      'icon': Icons.payment,
      'color': Colors.green,
      'faqs': [
        {
          'question': 'What payment methods are accepted?',
          'answer': 'We accept:\n\n• Credit and debit cards (Visa, Mastercard, Amex)\n• Digital wallets (Apple Pay, Google Pay)\n• Bank transfers\n• WashMoose credits\n\nAll payments are processed securely through our encrypted payment system.',
        },
        {
          'question': 'When am I charged for a booking?',
          'answer': 'Payment timing:\n\n• Fixed Packages: Charged when booking is confirmed\n• Custom Jobs: Small deposit at booking, remainder after completion\n• Marketplace: Payment schedule set by individual washers\n\nYou\'ll receive a receipt via email after each payment.',
        },
        {
          'question': 'Can I get a refund?',
          'answer': 'Refund policy:\n\n• Full refund if cancelled 4+ hours before appointment\n• Partial refund (50%) if cancelled 2-4 hours before\n• No refund for cancellations less than 2 hours before\n• Full refund if washer doesn\'t show up\n\nRefunds are processed within 3-5 business days.',
        },
        {
          'question': 'Are there any hidden fees?',
          'answer': 'Our pricing is transparent:\n\n• Service price is clearly shown before booking\n• Small platform fee (included in total)\n• Late cancellation fee (if applicable)\n• No surge pricing or hidden charges\n\nAll costs are displayed upfront during booking.',
        },
      ],
    },
    {
      'category': 'Account & Profile',
      'icon': Icons.account_circle,
      'color': Colors.orange,
      'faqs': [
        {
          'question': 'How do I update my profile information?',
          'answer': 'To update your profile:\n\n1. Go to Settings > Profile\n2. Tap "Edit Profile"\n3. Update your information\n4. Save changes\n\nYou can change your name, email, phone number, and profile picture.',
        },
        {
          'question': 'How do I change my password?',
          'answer': 'To change your password:\n\n1. Go to Settings > Security\n2. Tap "Change Password"\n3. Enter your current password\n4. Enter and confirm your new password\n5. Save changes\n\nUse a strong password with at least 8 characters.',
        },
        {
          'question': 'Can I delete my account?',
          'answer': 'To delete your account:\n\n1. Contact our support team\n2. We\'ll verify your identity\n3. All your data will be permanently removed\n4. You\'ll receive confirmation via email\n\nNote: This action cannot be undone.',
        },
        {
          'question': 'How do I enable notifications?',
          'answer': 'To manage notifications:\n\n1. Go to Settings > Notifications\n2. Toggle the notifications you want\n3. Settings save automatically\n\nWe recommend keeping booking updates enabled for important service information.',
        },
      ],
    },
    {
      'category': 'Technical Support',
      'icon': Icons.settings,
      'color': Colors.purple,
      'faqs': [
        {
          'question': 'The app is running slowly or crashing',
          'answer': 'Try these troubleshooting steps:\n\n1. Close and restart the app\n2. Update to the latest version\n3. Restart your device\n4. Clear app cache (Android)\n5. Reinstall the app if needed\n\nContact support if issues persist.',
        },
        {
          'question': 'I can\'t log into my account',
          'answer': 'Login troubleshooting:\n\n1. Check your email and password\n2. Try "Forgot Password" to reset\n3. Ensure stable internet connection\n4. Update the app to latest version\n5. Contact support if still having issues\n\nMake sure you\'re using the correct email address.',
        },
        {
          'question': 'Photos won\'t upload for custom jobs',
          'answer': 'Photo upload issues:\n\n1. Check your internet connection\n2. Ensure photos are under 10MB each\n3. Try using different photos\n4. Grant camera/photo permissions\n5. Restart the app and try again\n\nSupported formats: JPG, PNG, HEIC.',
        },
        {
          'question': 'Location services aren\'t working',
          'answer': 'Location troubleshooting:\n\n1. Enable location permissions for WashMoose\n2. Turn location services on in device settings\n3. Try refreshing your location in the app\n4. Restart your device\n5. Enter address manually if needed\n\nAccurate location helps washers find you easily.',
        },
      ],
    },
  ];

  @override
  void initState() {
    super.initState();
    _buildFilteredFAQs();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _buildFilteredFAQs() {
    filteredFAQs.clear();
    for (var category in faqCategories) {
      for (var faq in category['faqs']) {
        if (searchQuery.isEmpty ||
            faq['question'].toLowerCase().contains(searchQuery.toLowerCase()) ||
            faq['answer'].toLowerCase().contains(searchQuery.toLowerCase())) {
          filteredFAQs.add({
            ...faq,
            'category': category['category'],
            'categoryIcon': category['icon'],
            'categoryColor': category['color'],
          });
        }
      }
    }
  }

  void _onSearchChanged(String query) {
    setState(() {
      searchQuery = query;
      _buildFilteredFAQs();
    });
  }

  @override
  Widget build(BuildContext context) {
    const washMooseColor = Color(0xFF00C2CB);

    return Scaffold(
      appBar: AppBar(
        title: const Row(
          children: [
            Icon(Icons.help_center, color: Colors.white),
            SizedBox(width: 8),
            Text('Help Center'),
          ],
        ),
        backgroundColor: washMooseColor,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Info
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: washMooseColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: washMooseColor.withOpacity(0.3),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.support_agent,
                      color: washMooseColor,
                      size: 24,
                    ),
                    const SizedBox(width: 12),
                    const Expanded(
                      child: Text(
                        'Find answers to common questions or contact our support team for help.',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.black87,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Search Bar
              Container(
                decoration: BoxDecoration(
                  color: Colors.grey.shade50,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                child: TextField(
                  controller: _searchController,
                  onChanged: _onSearchChanged,
                  decoration: InputDecoration(
                    hintText: 'Search help articles...',
                    prefixIcon: Icon(Icons.search, color: washMooseColor),
                    suffixIcon: searchQuery.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear),
                            onPressed: () {
                              _searchController.clear();
                              _onSearchChanged('');
                            },
                          )
                        : null,
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // Quick Actions
              if (searchQuery.isEmpty) ...[
                _buildQuickActions(),
                const SizedBox(height: 24),
              ],

              // FAQ Categories or Search Results
              if (searchQuery.isEmpty)
                ..._buildFAQCategories()
              else
                _buildSearchResults(),

              const SizedBox(height: 24),

              // Contact Support Section
              _buildContactSupport(),

              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildQuickActions() {
    const washMooseColor = Color(0xFF00C2CB);

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.flash_on, color: washMooseColor, size: 20),
                const SizedBox(width: 8),
                const Text(
                  'Quick Actions',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildQuickActionButton(
                    'Contact Support',
                    Icons.headset_mic,
                    () => _contactSupport(),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildQuickActionButton(
                    'Report Issue',
                    Icons.report_problem,
                    () => _reportIssue(),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _buildQuickActionButton(
                    'Video Tutorials',
                    Icons.play_circle,
                    () => _openVideoTutorials(),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildQuickActionButton(
                    'User Guide',
                    Icons.menu_book,
                    () => _openUserGuide(),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickActionButton(String title, IconData icon, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFF00C2CB).withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: const Color(0xFF00C2CB).withOpacity(0.3)),
        ),
        child: Column(
          children: [
            Icon(icon, color: const Color(0xFF00C2CB), size: 24),
            const SizedBox(height: 8),
            Text(
              title,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: Color(0xFF00C2CB),
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildFAQCategories() {
    return faqCategories.map((category) {
      return Padding(
        padding: const EdgeInsets.only(bottom: 16),
        child: Card(
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: Theme(
            data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
            child: ExpansionTile(
              leading: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: category['color'].withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  category['icon'],
                  color: category['color'],
                  size: 20,
                ),
              ),
              title: Text(
                category['category'],
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              subtitle: Text('${category['faqs'].length} articles'),
              children: [
                ...category['faqs'].map<Widget>((faq) => _buildFAQItem(faq)).toList(),
              ],
            ),
          ),
        ),
      );
    }).toList();
  }

  Widget _buildSearchResults() {
    if (filteredFAQs.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(32),
        child: Column(
          children: [
            Icon(
              Icons.search_off,
              size: 64,
              color: Colors.grey.shade400,
            ),
            const SizedBox(height: 16),
            Text(
              'No results found',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.grey.shade600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Try different keywords or browse categories below',
              style: TextStyle(
                color: Colors.grey.shade500,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Search Results (${filteredFAQs.length})',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 16),
            ...filteredFAQs.map((faq) => _buildFAQItem(faq, showCategory: true)).toList(),
          ],
        ),
      ),
    );
  }

  Widget _buildFAQItem(Map<String, dynamic> faq, {bool showCategory = false}) {
    return Card(
      elevation: 1,
      margin: const EdgeInsets.only(bottom: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          title: Text(
            faq['question'],
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
          subtitle: showCategory
              ? Row(
                  children: [
                    Icon(
                      faq['categoryIcon'],
                      size: 16,
                      color: faq['categoryColor'],
                    ),
                    const SizedBox(width: 4),
                    Text(
                      faq['category'],
                      style: TextStyle(
                        fontSize: 12,
                        color: faq['categoryColor'],
                      ),
                    ),
                  ],
                )
              : null,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: Text(
                faq['answer'],
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.grey.shade700,
                  height: 1.4,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContactSupport() {
    const washMooseColor = Color(0xFF00C2CB);

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.support, color: washMooseColor, size: 20),
                const SizedBox(width: 8),
                const Text(
                  'Still Need Help?',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            const Text(
              'Can\'t find what you\'re looking for? Our support team is here to help!',
              style: TextStyle(fontSize: 14),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _contactSupport,
                    icon: const Icon(Icons.chat),
                    label: const Text('Live Chat'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: washMooseColor,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _emailSupport,
                    icon: const Icon(Icons.email),
                    label: const Text('Email Us'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: washMooseColor,
                      side: const BorderSide(color: washMooseColor),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _contactSupport() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Contact Support'),
        content: const Text(
          'Opening live chat with our support team...\n\n'
          'Average response time: 2-5 minutes\n'
          'Available 24/7 for urgent issues',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Live chat opened')),
              );
            },
            child: const Text('Start Chat'),
          ),
        ],
      ),
    );
  }

  void _emailSupport() async {
    const email = 'support@washmoose.com';
    const subject = 'WashMoose App Support Request';
    const body = 'Please describe your issue or question:';
    
    final Uri emailUri = Uri(
      scheme: 'mailto',
      path: email,
      queryParameters: {
        'subject': subject,
        'body': body,
      },
    );

    try {
      if (await canLaunchUrl(emailUri)) {
        await launchUrl(emailUri);
      } else {
        throw 'Could not launch email client';
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Could not open email client. Please email support@washmoose.com directly.'),
          ),
        );
      }
    }
  }

  void _reportIssue() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Report an Issue'),
        content: const Text('What type of issue would you like to report?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _contactSupport();
            },
            child: const Text('Technical Issue'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _contactSupport();
            },
            child: const Text('Service Issue'),
          ),
        ],
      ),
    );
  }

  void _openVideoTutorials() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Video tutorials coming soon!')),
    );
  }

  void _openUserGuide() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('User guide coming soon!')),
    );
  }
}