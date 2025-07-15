import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class CustomerSettingsTheme extends StatefulWidget {
  const CustomerSettingsTheme({super.key});

  @override
  State<CustomerSettingsTheme> createState() => _CustomerSettingsThemeState();
}

class _CustomerSettingsThemeState extends State<CustomerSettingsTheme> {
  // Firebase instances
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Theme settings
  String selectedTheme = 'Light';
  bool isLoading = true;
  bool isSaving = false;

  // Available themes
  final List<Map<String, dynamic>> themes = [
    {
      'id': 'light',
      'name': 'Light',
      'description': 'Clean and bright interface',
      'icon': Icons.light_mode,
      'primaryColor': Color(0xFF00C2CB),
      'backgroundColor': Colors.white,
      'textColor': Colors.black87,
      'cardColor': Colors.grey.shade50,
    },
    {
      'id': 'dark',
      'name': 'Dark',
      'description': 'Easy on the eyes, perfect for night use',
      'icon': Icons.dark_mode,
      'primaryColor': Color(0xFF00C2CB),
      'backgroundColor': Color(0xFF121212),
      'textColor': Colors.white,
      'cardColor': Color(0xFF1E1E1E),
    },
    {
      'id': 'system',
      'name': 'System',
      'description': 'Follows your device settings',
      'icon': Icons.settings_system_daydream,
      'primaryColor': Color(0xFF00C2CB),
      'backgroundColor': Colors.grey.shade200,
      'textColor': Colors.black54,
      'cardColor': Colors.grey.shade100,
    },
    {
      'id': 'auto',
      'name': 'Auto',
      'description': 'Light during day, dark at night',
      'icon': Icons.brightness_auto,
      'primaryColor': Color(0xFF00C2CB),
      'backgroundColor': Colors.blue.shade50,
      'textColor': Colors.blue.shade900,
      'cardColor': Colors.blue.shade50,
    },
  ];

  // Theme customization options
  Map<String, bool> themeOptions = {
    'enableAnimations': true,
    'useSystemAccentColor': false,
    'highContrast': false,
    'reducedMotion': false,
  };

  @override
  void initState() {
    super.initState();
    _loadThemeSettings();
  }

  // Load theme settings from Firestore
  Future<void> _loadThemeSettings() async {
    try {
      final User? currentUser = _auth.currentUser;
      if (currentUser == null) return;

      final DocumentSnapshot doc = await _firestore
          .collection('users')
          .doc(currentUser.uid)
          .get();

      if (doc.exists) {
        final data = doc.data() as Map<String, dynamic>;
        setState(() {
          selectedTheme = data['theme'] ?? 'Light';
          if (data.containsKey('themeOptions')) {
            final savedOptions = data['themeOptions'] as Map<String, dynamic>;
            themeOptions = {
              'enableAnimations': savedOptions['enableAnimations'] ?? true,
              'useSystemAccentColor': savedOptions['useSystemAccentColor'] ?? false,
              'highContrast': savedOptions['highContrast'] ?? false,
              'reducedMotion': savedOptions['reducedMotion'] ?? false,
            };
          }
          isLoading = false;
        });
      } else {
        setState(() {
          isLoading = false;
        });
      }
    } catch (e) {
      print('Error loading theme settings: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  // Save theme settings to Firestore
  Future<void> _saveThemeSettings(String theme) async {
    setState(() {
      isSaving = true;
    });

    try {
      final User? currentUser = _auth.currentUser;
      if (currentUser == null) return;

      await _firestore
          .collection('users')
          .doc(currentUser.uid)
          .update({
        'theme': theme,
        'themeOptions': themeOptions,
      });

      setState(() {
        selectedTheme = theme;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('✅ Theme changed to $theme'),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ Failed to save: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      setState(() {
        isSaving = false;
      });
    }
  }

  // Save theme options
  Future<void> _saveThemeOptions() async {
    try {
      final User? currentUser = _auth.currentUser;
      if (currentUser == null) return;

      await _firestore
          .collection('users')
          .doc(currentUser.uid)
          .update({
        'themeOptions': themeOptions,
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✅ Theme options saved'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 1),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ Failed to save options: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  // Get theme data from theme name
  Map<String, dynamic>? _getThemeData(String themeName) {
    try {
      return themes.firstWhere((theme) => theme['name'] == themeName);
    } catch (e) {
      return themes[0]; // Default to Light
    }
  }

  @override
  Widget build(BuildContext context) {
    const washMooseColor = Color(0xFF00C2CB);

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            const Icon(Icons.palette, color: Colors.white),
            const SizedBox(width: 8),
            const Text('Theme Settings'),
            if (isSaving) ...[
              const SizedBox(width: 8),
              const SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              ),
            ],
          ],
        ),
        backgroundColor: washMooseColor,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: isLoading
          ? const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF00C2CB)),
              ),
            )
          : SingleChildScrollView(
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
                            Icons.color_lens,
                            color: washMooseColor,
                            size: 24,
                          ),
                          const SizedBox(width: 12),
                          const Expanded(
                            child: Text(
                              'Customize your WashMoose app appearance and visual preferences.',
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

                    // Current Theme Section
                    Card(
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
                                Icon(
                                  Icons.check_circle,
                                  color: washMooseColor,
                                  size: 20,
                                ),
                                const SizedBox(width: 8),
                                const Text(
                                  'Current Theme',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.grey,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            _buildCurrentThemeCard(),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Available Themes Section
                    Card(
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
                                Icon(
                                  Icons.format_paint,
                                  color: washMooseColor,
                                  size: 20,
                                ),
                                const SizedBox(width: 8),
                                const Text(
                                  'Available Themes',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.grey,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            ...themes.map((theme) => _buildThemeOption(theme)).toList(),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Theme Options Section
                    Card(
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
                                Icon(
                                  Icons.tune,
                                  color: washMooseColor,
                                  size: 20,
                                ),
                                const SizedBox(width: 8),
                                const Text(
                                  'Theme Options',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.grey,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            _buildThemeOptionToggle(
                              'enableAnimations',
                              'Enable Animations',
                              'Smooth transitions and animations',
                              Icons.animation,
                            ),
                            const SizedBox(height: 12),
                            _buildThemeOptionToggle(
                              'useSystemAccentColor',
                              'Use System Accent Color',
                              'Match your device accent color',
                              Icons.color_lens_outlined,
                            ),
                            const SizedBox(height: 12),
                            _buildThemeOptionToggle(
                              'highContrast',
                              'High Contrast',
                              'Improved visibility for accessibility',
                              Icons.contrast,
                            ),
                            const SizedBox(height: 12),
                            _buildThemeOptionToggle(
                              'reducedMotion',
                              'Reduced Motion',
                              'Minimize animations for accessibility',
                              Icons.accessible,
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Theme Information
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade50,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.grey.shade300),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(
                                Icons.info_outline,
                                color: Colors.grey.shade600,
                                size: 20,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'Theme Information',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.grey.shade700,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            '• Light: Best for daytime use and bright environments\n'
                            '• Dark: Reduces eye strain in low light conditions\n'
                            '• System: Automatically matches your device theme\n'
                            '• Auto: Changes based on time of day\n'
                            '• Theme changes apply immediately',
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.grey.shade600,
                              height: 1.4,
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildCurrentThemeCard() {
    final currentThemeData = _getThemeData(selectedTheme);
    if (currentThemeData == null) return const SizedBox();

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            const Color(0xFF00C2CB).withOpacity(0.1),
            const Color(0xFF00C2CB).withOpacity(0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: const Color(0xFF00C2CB).withOpacity(0.3),
          width: 2,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: currentThemeData['primaryColor'],
              shape: BoxShape.circle,
            ),
            child: Icon(
              currentThemeData['icon'],
              color: Colors.white,
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  currentThemeData['name'],
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF00C2CB),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  currentThemeData['description'],
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          ),
          // Theme preview
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: currentThemeData['backgroundColor'],
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.grey.shade300),
            ),
            child: Center(
              child: Container(
                width: 20,
                height: 20,
                decoration: BoxDecoration(
                  color: currentThemeData['primaryColor'],
                  shape: BoxShape.circle,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildThemeOption(Map<String, dynamic> theme) {
    final isSelected = theme['name'] == selectedTheme;

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: isSaving ? null : () => _saveThemeSettings(theme['name']),
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isSelected 
                ? const Color(0xFF00C2CB).withOpacity(0.1)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected 
                  ? const Color(0xFF00C2CB)
                  : Colors.grey.shade300,
              width: isSelected ? 2 : 1,
            ),
          ),
          child: Row(
            children: [
              // Theme icon
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: isSelected 
                      ? theme['primaryColor']
                      : Colors.grey.shade400,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  theme['icon'],
                  color: Colors.white,
                  size: 20,
                ),
              ),
              
              const SizedBox(width: 16),
              
              // Theme info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      theme['name'],
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: isSelected 
                            ? const Color(0xFF00C2CB)
                            : Colors.black87,
                      ),
                    ),
                    Text(
                      theme['description'],
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ),
              
              // Theme preview
              Container(
                width: 32,
                height: 32,
                margin: const EdgeInsets.only(right: 8),
                decoration: BoxDecoration(
                  color: theme['backgroundColor'],
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                child: Center(
                  child: Container(
                    width: 12,
                    height: 12,
                    decoration: BoxDecoration(
                      color: theme['primaryColor'],
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
              ),
              
              // Selection indicator
              if (isSelected)
                const Icon(
                  Icons.radio_button_checked,
                  color: Color(0xFF00C2CB),
                )
              else
                Icon(
                  Icons.radio_button_unchecked,
                  color: Colors.grey.shade400,
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildThemeOptionToggle(String key, String title, String description, IconData icon) {
    return Row(
      children: [
        Icon(
          icon,
          color: themeOptions[key]! ? const Color(0xFF00C2CB) : Colors.grey.shade400,
          size: 20,
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 15,
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
        Switch(
          value: themeOptions[key]!,
          onChanged: (value) {
            setState(() {
              themeOptions[key] = value;
            });
            _saveThemeOptions();
          },
          activeColor: const Color(0xFF00C2CB),
          materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
        ),
      ],
    );
  }
}