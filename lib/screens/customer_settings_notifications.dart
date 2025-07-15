import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class CustomerSettingsNotifications extends StatefulWidget {
  const CustomerSettingsNotifications({super.key});

  @override
  State<CustomerSettingsNotifications> createState() => _CustomerSettingsNotificationsState();
}

class _CustomerSettingsNotificationsState extends State<CustomerSettingsNotifications> {
  // Firebase instances
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // ✅ SIMPLIFIED: 4 Essential Notification Settings
  Map<String, bool> notificationSettings = {
    'allNotifications': true,
    'bookingUpdates': true,
    'paymentAlerts': true,
    'promotions': false,
  };
  
  bool isNotificationLoading = false;
  bool isInitialLoading = true;

  @override
  void initState() {
    super.initState();
    _loadNotificationSettings();
  }

  // ✅ Load Simplified Notification Settings from Firestore
  Future<void> _loadNotificationSettings() async {
    try {
      final User? currentUser = _auth.currentUser;
      if (currentUser == null) return;

      final DocumentSnapshot doc = await _firestore
          .collection('users')
          .doc(currentUser.uid)
          .get();

      if (doc.exists) {
        final data = doc.data() as Map<String, dynamic>;
        if (data.containsKey('notificationSettings')) {
          final savedSettings = data['notificationSettings'] as Map<String, dynamic>;
          setState(() {
            notificationSettings = {
              'allNotifications': savedSettings['allNotifications'] ?? true,
              'bookingUpdates': savedSettings['bookingUpdates'] ?? true,
              'paymentAlerts': savedSettings['paymentAlerts'] ?? true,
              'promotions': savedSettings['promotions'] ?? false,
            };
            isInitialLoading = false;
          });
        } else {
          setState(() {
            isInitialLoading = false;
          });
        }
      } else {
        setState(() {
          isInitialLoading = false;
        });
      }
    } catch (e) {
      print('Error loading notification settings: $e');
      setState(() {
        isInitialLoading = false;
      });
    }
  }

  // ✅ Save Notification Settings to Firestore
  Future<void> _saveNotificationSettings() async {
    setState(() {
      isNotificationLoading = true;
    });

    try {
      final User? currentUser = _auth.currentUser;
      if (currentUser == null) return;

      await _firestore
          .collection('users')
          .doc(currentUser.uid)
          .update({
        'notificationSettings': notificationSettings,
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✅ Notification settings saved'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 2),
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
        isNotificationLoading = false;
      });
    }
  }

  // ✅ Update Individual Notification Setting
  void _updateNotificationSetting(String key, bool value) {
    setState(() {
      notificationSettings[key] = value;
      
      // If turning off "All Notifications", turn off others too
      if (key == 'allNotifications' && !value) {
        notificationSettings['bookingUpdates'] = false;
        notificationSettings['paymentAlerts'] = false;
        notificationSettings['promotions'] = false;
      }
      // If turning on any specific notification, turn on "All Notifications"
      else if (key != 'allNotifications' && value) {
        notificationSettings['allNotifications'] = true;
      }
    });
    
    // Auto-save after short delay
    Future.delayed(const Duration(milliseconds: 500), () {
      _saveNotificationSettings();
    });
  }

  @override
  Widget build(BuildContext context) {
    const washMooseColor = Color(0xFF00C2CB);

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            const Icon(Icons.notifications_outlined, color: Colors.white),
            const SizedBox(width: 8),
            const Text('Notification Settings'),
            if (isNotificationLoading) ...[
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
      body: isInitialLoading
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
                            Icons.info_outline,
                            color: washMooseColor,
                            size: 24,
                          ),
                          const SizedBox(width: 12),
                          const Expanded(
                            child: Text(
                              'Manage your notification preferences. Changes are saved automatically.',
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

                    // 1. All Notifications (Master Toggle)
                    _buildNotificationCard(
                      icon: Icons.notifications_active,
                      title: 'All Notifications',
                      subtitle: 'Enable or disable all notifications',
                      value: notificationSettings['allNotifications']!,
                      onChanged: (value) {
                        _updateNotificationSetting('allNotifications', value);
                      },
                      isMain: true,
                    ),
                    
                    const SizedBox(height: 16),
                    
                    // Individual Notification Settings
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
                            const Text(
                              'Individual Settings',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.grey,
                              ),
                            ),
                            const SizedBox(height: 16),
                            
                            // 2. Booking Updates
                            _buildNotificationToggle(
                              icon: Icons.event_available,
                              title: 'Booking Updates',
                              subtitle: 'Confirmations, status changes, completion',
                              value: notificationSettings['bookingUpdates']!,
                              onChanged: (value) {
                                _updateNotificationSetting('bookingUpdates', value);
                              },
                            ),
                            
                            const SizedBox(height: 16),
                            
                            // 3. Payment Alerts
                            _buildNotificationToggle(
                              icon: Icons.payment,
                              title: 'Payment Alerts',
                              subtitle: 'Payment confirmations and receipts',
                              value: notificationSettings['paymentAlerts']!,
                              onChanged: (value) {
                                _updateNotificationSetting('paymentAlerts', value);
                              },
                            ),
                            
                            const SizedBox(height: 16),
                            
                            // 4. Promotions (Optional)
                            _buildNotificationToggle(
                              icon: Icons.local_offer,
                              title: 'Promotions & Offers',
                              subtitle: 'Special deals and discounts (optional)',
                              value: notificationSettings['promotions']!,
                              onChanged: (value) {
                                _updateNotificationSetting('promotions', value);
                              },
                              isOptional: true,
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Additional Info
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
                                Icons.tips_and_updates_outlined,
                                color: Colors.grey.shade600,
                                size: 20,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'Notification Tips',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.grey.shade700,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            '• Booking Updates: Essential for service coordination\n'
                            '• Payment Alerts: Keep track of transactions\n'
                            '• Promotions: Get notified about special offers\n'
                            '• You can change these settings anytime',
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

  // ✅ Build Main Notification Card (All Notifications)
  Widget _buildNotificationCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required bool value,
    required Function(bool) onChanged,
    bool isMain = false,
  }) {
    const primaryColor = Color(0xFF00C2CB);
    
    return Card(
      elevation: isMain ? 4 : 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          gradient: isMain && value
              ? LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    primaryColor.withOpacity(0.1),
                    primaryColor.withOpacity(0.05),
                  ],
                )
              : null,
          border: Border.all(
            color: value && isMain ? primaryColor : Colors.grey.shade300,
            width: value && isMain ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            // Icon
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: value ? primaryColor : Colors.grey.shade400,
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                color: Colors.white,
                size: isMain ? 24 : 20,
              ),
            ),
            
            const SizedBox(width: 16),
            
            // Title & Subtitle
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontWeight: isMain ? FontWeight.bold : FontWeight.w600,
                      fontSize: isMain ? 18 : 16,
                      color: value ? primaryColor : Colors.grey.shade700,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
            ),
            
            // Toggle Switch
            Switch(
              value: value,
              onChanged: onChanged,
              activeColor: primaryColor,
              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
          ],
        ),
      ),
    );
  }

  // ✅ Build Simple Notification Toggle
  Widget _buildNotificationToggle({
    required IconData icon,
    required String title,
    required String subtitle,
    required bool value,
    required Function(bool) onChanged,
    bool isOptional = false,
  }) {
    const primaryColor = Color(0xFF00C2CB);
    
    return Row(
      children: [
        // Icon
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: value ? primaryColor : Colors.grey.shade400,
            shape: BoxShape.circle,
          ),
          child: Icon(
            icon,
            color: Colors.white,
            size: 18,
          ),
        ),
        
        const SizedBox(width: 12),
        
        // Title & Subtitle
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 15,
                      color: value ? primaryColor : Colors.grey.shade700,
                    ),
                  ),
                  if (isOptional) ...[
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.orange.shade100,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        'Optional',
                        style: TextStyle(
                          fontSize: 10,
                          color: Colors.orange.shade700,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey.shade600,
                ),
              ),
            ],
          ),
        ),
        
        // Toggle Switch
        Switch(
          value: value,
          onChanged: onChanged,
          activeColor: primaryColor,
          materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
        ),
      ],
    );
  }
}