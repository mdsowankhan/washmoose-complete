import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:package_info_plus/package_info_plus.dart';

class CustomerSettingsAbout extends StatefulWidget {
  const CustomerSettingsAbout({super.key});

  @override
  State<CustomerSettingsAbout> createState() => _CustomerSettingsAboutState();
}

class _CustomerSettingsAboutState extends State<CustomerSettingsAbout> {
  // App info
  String appVersion = 'Loading...';
  String buildNumber = 'Loading...';
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadAppInfo();
  }

  // Load app version and build info
  Future<void> _loadAppInfo() async {
    try {
      final PackageInfo packageInfo = await PackageInfo.fromPlatform();
      setState(() {
        appVersion = packageInfo.version;
        buildNumber = packageInfo.buildNumber;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        appVersion = '1.0.0';
        buildNumber = '1';
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    const washMooseColor = Color(0xFF00C2CB);

    return Scaffold(
      appBar: AppBar(
        title: const Row(
          children: [
            Icon(Icons.info, color: Colors.white),
            SizedBox(width: 8),
            Text('About WashMoose'),
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
              // App Header
              _buildAppHeader(),

              const SizedBox(height: 24),

              // App Information
              _buildAppInformation(),

              const SizedBox(height: 24),

              // Company Information
              _buildCompanyInformation(),

              const SizedBox(height: 24),

              // Legal & Policy
              _buildLegalSection(),

              const SizedBox(height: 24),

              // Social Media & Links
              _buildSocialMediaSection(),

              const SizedBox(height: 24),

              // Credits & Acknowledgments
              _buildCreditsSection(),

              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAppHeader() {
    const washMooseColor = Color(0xFF00C2CB);

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              washMooseColor,
              washMooseColor.withOpacity(0.8),
            ],
          ),
        ),
        child: Column(
          children: [
            // App Icon/Logo
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: const Icon(
                Icons.local_car_wash,
                size: 40,
                color: washMooseColor,
              ),
            ),
            
            const SizedBox(height: 16),
            
            // App Name
            const Text(
              'WashMoose',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            
            const SizedBox(height: 8),
            
            // App Tagline
            const Text(
              'On-Demand Mobile Car Wash',
              style: TextStyle(
                fontSize: 16,
                color: Colors.white,
                fontWeight: FontWeight.w500,
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Version Info
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                isLoading ? 'Loading...' : 'Version $appVersion ($buildNumber)',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAppInformation() {
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
                Icon(Icons.info_outline, color: washMooseColor, size: 20),
                const SizedBox(width: 8),
                const Text(
                  'App Information',
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
              'WashMoose is Australia\'s premier on-demand mobile car wash service. We bring professional car cleaning directly to your doorstep, making car care convenient and affordable.',
              style: TextStyle(
                fontSize: 14,
                height: 1.5,
                color: Colors.black87,
              ),
            ),
            
            const SizedBox(height: 16),
            
            _buildAppInfoItem('Release Date', 'December 2024'),
            _buildAppInfoItem('Platform', 'iOS & Android'),
            _buildAppInfoItem('Size', '45 MB'),
            _buildAppInfoItem('Language', 'English (More coming soon)'),
            _buildAppInfoItem('Category', 'Lifestyle & Services'),
            _buildAppInfoItem('Developer', 'WashMoose Pty Ltd'),
          ],
        ),
      ),
    );
  }

  Widget _buildAppInfoItem(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: TextStyle(
                fontSize: 13,
                color: Colors.grey.shade600,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCompanyInformation() {
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
                Icon(Icons.business, color: washMooseColor, size: 20),
                const SizedBox(width: 8),
                const Text(
                  'Company Information',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            
            _buildCompanyInfoItem(
              Icons.business_center,
              'Company Name',
              'WashMoose Pty Ltd',
              () => _copyToClipboard('WashMoose Pty Ltd'),
            ),
            _buildCompanyInfoItem(
              Icons.location_on,
              'Headquarters',
              'Sydney, NSW, Australia',
              () => _copyToClipboard('Sydney, NSW, Australia'),
            ),
            _buildCompanyInfoItem(
              Icons.calendar_today,
              'Founded',
              '2024',
              null,
            ),
            _buildCompanyInfoItem(
              Icons.email,
              'Contact Email',
              'hello@washmoose.com',
              () => _sendEmail('hello@washmoose.com'),
            ),
            _buildCompanyInfoItem(
              Icons.web,
              'Website',
              'www.washmoose.com',
              () => _openWebsite('https://www.washmoose.com'),
            ),
            _buildCompanyInfoItem(
              Icons.gavel,
              'ABN',
              '12 345 678 901',
              () => _copyToClipboard('12 345 678 901'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCompanyInfoItem(IconData icon, String label, String value, VoidCallback? onTap) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: Row(
            children: [
              Icon(icon, color: const Color(0xFF00C2CB), size: 18),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      label,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade600,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      value,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              if (onTap != null)
                Icon(
                  Icons.open_in_new,
                  color: Colors.grey.shade400,
                  size: 16,
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLegalSection() {
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
                Icon(Icons.gavel, color: washMooseColor, size: 20),
                const SizedBox(width: 8),
                const Text(
                  'Legal & Policies',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            
            _buildLegalItem(
              Icons.description,
              'Terms of Service',
              'Read our terms and conditions',
              () => _openDocument('terms'),
            ),
            _buildLegalItem(
              Icons.privacy_tip,
              'Privacy Policy',
              'How we protect your privacy',
              () => _openDocument('privacy'),
            ),
            _buildLegalItem(
              Icons.cookie,
              'Cookie Policy',
              'Information about cookies',
              () => _openDocument('cookies'),
            ),
            _buildLegalItem(
              Icons.security,
              'Data Security',
              'How we secure your data',
              () => _openDocument('security'),
            ),
            _buildLegalItem(
              Icons.help_outline,
              'Refund Policy',
              'Cancellation and refund terms',
              () => _openDocument('refund'),
            ),
            
            const SizedBox(height: 16),
            
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: Text(
                '© 2024 WashMoose Pty Ltd. All rights reserved.\n'
                'WashMoose and the WashMoose logo are trademarks of WashMoose Pty Ltd.',
                style: TextStyle(
                  fontSize: 11,
                  color: Colors.grey.shade600,
                  height: 1.4,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLegalItem(IconData icon, String title, String description, VoidCallback onTap) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: Row(
            children: [
              Icon(icon, color: const Color(0xFF00C2CB), size: 18),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      description,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.chevron_right,
                color: Colors.grey.shade400,
                size: 18,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSocialMediaSection() {
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
                Icon(Icons.share, color: washMooseColor, size: 20),
                const SizedBox(width: 8),
                const Text(
                  'Connect with Us',
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
              'Follow us on social media for updates, tips, and special offers!',
              style: TextStyle(fontSize: 14),
            ),
            
            const SizedBox(height: 16),
            
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildSocialButton(
                  'Facebook',
                  Icons.facebook,
                  Colors.blue,
                  () => _openSocialMedia('facebook'),
                ),
                _buildSocialButton(
                  'Instagram',
                  Icons.camera_alt,
                  Colors.purple,
                  () => _openSocialMedia('instagram'),
                ),
                _buildSocialButton(
                  'Twitter',
                  Icons.alternate_email,
                  Colors.lightBlue,
                  () => _openSocialMedia('twitter'),
                ),
                _buildSocialButton(
                  'LinkedIn',
                  Icons.work,
                  Colors.indigo,
                  () => _openSocialMedia('linkedin'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSocialButton(String name, IconData icon, Color color, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(height: 8),
            Text(
              name,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCreditsSection() {
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
                Icon(Icons.favorite, color: washMooseColor, size: 20),
                const SizedBox(width: 8),
                const Text(
                  'Credits & Acknowledgments',
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
              'WashMoose is built with love using:',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
            
            const SizedBox(height: 12),
            
            _buildCreditItem('Flutter', 'Google\'s UI toolkit'),
            _buildCreditItem('Firebase', 'Backend and authentication'),
            _buildCreditItem('Google Maps', 'Location services'),
            _buildCreditItem('Stripe', 'Secure payments'),
            
            const SizedBox(height: 16),
            
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: washMooseColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: washMooseColor.withOpacity(0.3)),
              ),
              child: Row(
                children: [
                  Icon(Icons.code, color: washMooseColor, size: 20),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Text(
                      'Made with ❤️ in Sydney, Australia',
                      style: TextStyle(
                        fontSize: 14,
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
    );
  }

  Widget _buildCreditItem(String name, String description) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: const BoxDecoration(
              color: Color(0xFF00C2CB),
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: RichText(
              text: TextSpan(
                children: [
                  TextSpan(
                    text: name,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                  TextSpan(
                    text: ' - $description',
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.grey.shade600,
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

  void _copyToClipboard(String text) {
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('$text copied to clipboard')),
    );
  }

  void _sendEmail(String email) async {
    final Uri emailUri = Uri(scheme: 'mailto', path: email);
    try {
      if (await canLaunchUrl(emailUri)) {
        await launchUrl(emailUri);
      } else {
        throw 'Could not launch email client';
      }
    } catch (e) {
      _copyToClipboard(email);
    }
  }

  void _openWebsite(String url) async {
    final Uri websiteUri = Uri.parse(url);
    try {
      if (await canLaunchUrl(websiteUri)) {
        await launchUrl(websiteUri);
      } else {
        throw 'Could not launch website';
      }
    } catch (e) {
      _copyToClipboard(url);
    }
  }

  void _openDocument(String type) {
    final Map<String, String> urls = {
      'terms': 'https://www.washmoose.com/terms',
      'privacy': 'https://www.washmoose.com/privacy',
      'cookies': 'https://www.washmoose.com/cookies',
      'security': 'https://www.washmoose.com/security',
      'refund': 'https://www.washmoose.com/refund',
    };
    
    final url = urls[type];
    if (url != null) {
      _openWebsite(url);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Document will be available soon')),
      );
    }
  }

  void _openSocialMedia(String platform) {
    final Map<String, String> urls = {
      'facebook': 'https://www.facebook.com/washmoose',
      'instagram': 'https://www.instagram.com/washmoose',
      'twitter': 'https://www.twitter.com/washmoose',
      'linkedin': 'https://www.linkedin.com/company/washmoose',
    };
    
    final url = urls[platform];
    if (url != null) {
      _openWebsite(url);
    }
  }
}