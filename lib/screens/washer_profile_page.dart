import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../services/washer_connection_service.dart';
import 'washer_documents_page.dart';
import 'washer_edit_profile_page.dart';

class WasherProfilePage extends StatefulWidget {
  const WasherProfilePage({super.key});

  @override
  State<WasherProfilePage> createState() => _WasherProfilePageState();
}

class _WasherProfilePageState extends State<WasherProfilePage> with TickerProviderStateMixin {
  Map<String, dynamic> washerData = {};
  bool isLoading = true;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  // Firebase instances
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final WasherConnectionService _connectionService = WasherConnectionService();

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    _loadWasherProfile();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _loadWasherProfile() async {
    try {
      final User? currentUser = _auth.currentUser;
      if (currentUser != null) {
        final DocumentSnapshot userDoc = await _firestore
            .collection('users')
            .doc(currentUser.uid)
            .get();
        
        if (userDoc.exists) {
          setState(() {
            washerData = userDoc.data() as Map<String, dynamic>;
            isLoading = false;
          });
          _animationController.forward();
        } else {
          await _createInitialProfile(currentUser);
        }
      }
    } catch (e) {
      setState(() => isLoading = false);
    }
  }

  Future<void> _createInitialProfile(User user) async {
    final initialData = {
      'uid': user.uid,
      'email': user.email ?? '',
      'firstName': '',
      'lastName': '',
      'phone': '',
      'bio': '',
      'location': '',
      'businessName': '',
      'availability': '',
      'profileImageUrl': null,
      'rating': 0.0,
      'completedJobs': 0,
      'totalEarnings': 0.0,
      'joinDate': DateTime.now().toIso8601String(),
      'washerType': 'everyday',
      'userType': 'washer',
      'isVerified': false,
      'isOnline': false,
      'documentsStatus': 'pending',
      'documents': {
        'driverLicence': null,
        'visa': null,
        'policeCheck': null,
        'profilePhoto': null,
      },
      'createdAt': FieldValue.serverTimestamp(),
    };

    await _firestore.collection('users').doc(user.uid).set(initialData);
    setState(() {
      washerData = initialData;
      isLoading = false;
    });
    _animationController.forward();
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Scaffold(
        backgroundColor: const Color(0xFFFAFBFC),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(color: Colors.amber),
              SizedBox(height: 16),
              Text(
                'Loading Profile...', 
                style: TextStyle(color: Color(0xFF1A202C), fontSize: 16),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFFFAFBFC),
      appBar: AppBar(
        title: Text('My Profile'),
        backgroundColor: Colors.white,
        foregroundColor: Color(0xFF1A202C),
        elevation: 0,
        centerTitle: true,
        automaticallyImplyLeading: false,
      ),
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: SingleChildScrollView(
          padding: EdgeInsets.all(16),
          child: Column(
            children: [
              _buildProfileHeader(),
              SizedBox(height: 20),
              _buildProfileSections(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProfileHeader() {
    final String firstName = washerData['firstName'] ?? '';
    final String lastName = washerData['lastName'] ?? '';
    final String email = washerData['email'] ?? 'No email';
    final String washerType = washerData['washerType'] ?? 'everyday';
    final bool isVerified = washerData['isVerified'] ?? false;
    final bool isOnline = washerData['isOnline'] ?? false;
    final String? profileImageUrl = washerData['profileImageUrl'];
    final double rating = (washerData['rating'] ?? 0.0).toDouble();

    return Container(
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              // Profile Picture
              Stack(
                children: [
                  CircleAvatar(
                    radius: 35,
                    backgroundColor: Color(0xFFF0F0F0),
                    backgroundImage: profileImageUrl != null ? NetworkImage(profileImageUrl) : null,
                    child: profileImageUrl == null
                      ? Text(
                          _getInitials(firstName, lastName, email),
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF1A202C),
                          ),
                        )
                      : null,
                  ),
                  // Status dot
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: Container(
                      width: 16,
                      height: 16,
                      decoration: BoxDecoration(
                        color: _getStatusColor(isVerified, isOnline),
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 2),
                      ),
                    ),
                  ),
                ],
              ),
              
              SizedBox(width: 16),
              
              // Name and details
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      firstName.isNotEmpty || lastName.isNotEmpty
                        ? '$firstName $lastName'.trim()
                        : 'Complete Your Profile',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1A202C),
                      ),
                    ),
                    SizedBox(height: 2),
                    Text(
                      email,
                      style: TextStyle(
                        fontSize: 13,
                        color: Color(0xFF6C757D),
                      ),
                    ),
                    SizedBox(height: 4),
                    Row(
                      children: [
                        Container(
                          padding: EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: washerType == 'expert' ? Colors.amber.withOpacity(0.2) : Colors.blue.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            washerType == 'expert' ? 'Expert Moose' : 'Everyday Moose',
                            style: TextStyle(
                              fontSize: 10,
                              color: washerType == 'expert' ? Colors.amber[700] : Colors.blue[700],
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        if (isVerified) ...[
                          SizedBox(width: 6),
                          Icon(Icons.verified, color: Colors.green, size: 14),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
              
              // Rating
              Column(
                children: [
                  Row(
                    children: [
                      Icon(Icons.star, color: Colors.amber, size: 16),
                      SizedBox(width: 2),
                      Text(
                        rating > 0 ? rating.toStringAsFixed(1) : 'N/A',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1A202C),
                        ),
                      ),
                    ],
                  ),
                  Text(
                    'Rating',
                    style: TextStyle(
                      fontSize: 10,
                      color: Color(0xFF6C757D),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildProfileSections() {
    return Column(
      children: [
        // Documents Section (PROMINENT)
        _buildDocumentsSection(),
        SizedBox(height: 16),
        
        // Profile Management
        _buildSectionCard(
          title: 'Profile Management',
          children: [
            _buildListItem(
              icon: Icons.edit,
              title: 'Edit Profile',
              subtitle: 'Update your personal information',
              onTap: () => _navigateToEditProfile(),
              color: Colors.blue,
            ),
            _buildDivider(),
            _buildListItem(
              icon: Icons.info_outline,
              title: 'About Me',
              subtitle: washerData['bio']?.isNotEmpty == true 
                ? 'Bio added' 
                : 'Add your bio',
              onTap: () => _navigateToEditProfile(),
              color: Colors.purple,
              trailing: washerData['bio']?.isNotEmpty == true 
                ? Icon(Icons.check_circle, color: Colors.green, size: 16)
                : Icon(Icons.add_circle_outline, color: Colors.grey, size: 16),
            ),
          ],
        ),
        
        SizedBox(height: 16),
        
        // Account Settings
        _buildSectionCard(
          title: 'Account',
          children: [
            _buildListItem(
              icon: Icons.location_on,
              title: 'Location',
              subtitle: washerData['location']?.isNotEmpty == true 
                ? washerData['location'] 
                : 'Set your location',
              onTap: () => _navigateToEditProfile(),
              color: Colors.orange,
            ),
            _buildDivider(),
            _buildListItem(
              icon: Icons.logout,
              title: 'Sign Out',
              subtitle: 'Log out of your account',
              onTap: () => _signOut(),
              color: Colors.red,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildDocumentsSection() {
    final String documentsStatus = washerData['documentsStatus'] ?? 'pending';
    final Map<String, dynamic> documents = washerData['documents'] ?? {};
    
    // Count completed documents
    int completedDocs = 0;
    int totalDocs = 4; // driver licence, visa, police check, profile photo
    
    if (documents['driverLicence'] != null) completedDocs++;
    if (documents['visa'] != null) completedDocs++;
    if (documents['policeCheck'] != null) completedDocs++;
    if (documents['profilePhoto'] != null) completedDocs++;

    Color statusColor = Colors.grey;
    String statusText = 'Pending';
    IconData statusIcon = Icons.pending;

    switch (documentsStatus) {
      case 'approved':
        statusColor = Colors.green;
        statusText = 'Verified';
        statusIcon = Icons.verified;
        break;
      case 'rejected':
        statusColor = Colors.red;
        statusText = 'Rejected';
        statusIcon = Icons.error;
        break;
      case 'under_review':
        statusColor = Colors.orange;
        statusText = 'Under Review';
        statusIcon = Icons.hourglass_top;
        break;
      default:
        statusColor = Colors.grey;
        statusText = 'Pending';
        statusIcon = Icons.pending;
    }

    return _buildSectionCard(
      title: 'Verification Documents',
      children: [
        Container(
          padding: EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: statusColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: statusColor.withOpacity(0.3)),
          ),
          child: Row(
            children: [
              Icon(statusIcon, color: statusColor, size: 20),
              SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Status: $statusText',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: statusColor,
                      ),
                    ),
                    Text(
                      'Documents: $completedDocs/$totalDocs completed',
                      style: TextStyle(
                        fontSize: 12,
                        color: statusColor,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(Icons.arrow_forward_ios, color: statusColor, size: 16),
            ],
          ),
        ),
        SizedBox(height: 12),
        _buildListItem(
          icon: Icons.upload_file,
          title: 'Manage Documents',
          subtitle: 'Upload and view verification documents',
          onTap: () => _navigateToDocuments(),
          color: Colors.blue,
          showBorder: false,
        ),
      ],
    );
  }

  Widget _buildSectionCard({
    required String title,
    required List<Widget> children,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Text(
              title,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1A202C),
              ),
            ),
          ),
          ...children,
        ],
      ),
    );
  }

  Widget _buildListItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    required Color color,
    Widget? trailing,
    bool showBorder = true,
  }) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          border: showBorder ? Border(
            top: BorderSide(color: Color(0xFFF0F0F0), width: 0.5),
          ) : null,
        ),
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: color, size: 20),
            ),
            SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF1A202C),
                    ),
                  ),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 13,
                      color: Color(0xFF6C757D),
                    ),
                  ),
                ],
              ),
            ),
            trailing ?? Icon(Icons.arrow_forward_ios, color: Color(0xFFCCC), size: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildDivider() {
    return Container(
      height: 0.5,
      margin: EdgeInsets.symmetric(horizontal: 16),
      color: Color(0xFFF0F0F0),
    );
  }

  // Helper Methods
  String _getInitials(String firstName, String lastName, String email) {
    if (firstName.isNotEmpty && lastName.isNotEmpty) {
      return '${firstName[0].toUpperCase()}${lastName[0].toUpperCase()}';
    } else if (email.isNotEmpty) {
      return email[0].toUpperCase();
    }
    return '?';
  }

  Color _getStatusColor(bool isVerified, bool isOnline) {
    if (isVerified && isOnline) return Colors.green;
    if (isVerified) return Colors.amber;
    return Colors.grey;
  }

  // Navigation Methods
  void _navigateToEditProfile() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => WasherEditProfilePage(
          currentData: washerData,
          onProfileUpdated: (updatedData) {
            setState(() {
              washerData = updatedData;
            });
          },
        ),
      ),
    );
  }

  void _navigateToDocuments() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => WasherDocumentsPage(
          userData: washerData,
          onDocumentsUpdated: (updatedData) {
            setState(() {
              washerData = updatedData;
            });
          },
        ),
      ),
    );
  }

  Future<void> _signOut() async {
    final bool? shouldSignOut = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        title: Text(
          'Sign Out', 
          style: TextStyle(
            color: Color(0xFF1A202C),
            fontWeight: FontWeight.bold,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Are you sure you want to sign out?',
              style: TextStyle(color: Color(0xFF495057)),
            ),
            SizedBox(height: 12),
            if (washerData['isOnline'] == true) ...[
              Container(
                padding: EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.orange.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.orange.withOpacity(0.3)),
                ),
                child: Row(
                  children: [
                    Icon(Icons.info_outline, color: Colors.orange, size: 18),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'You will be automatically taken offline',
                        style: TextStyle(
                          color: Colors.orange,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('Cancel', style: TextStyle(color: Color(0xFF6C757D))),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text('Sign Out', style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );

    if (shouldSignOut == true) {
      try {
        await _connectionService.forceOfflineOnLogout();
        await _auth.signOut();
        
        if (mounted) {
          Navigator.pushNamedAndRemoveUntil(context, '/', (route) => false);
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to sign out: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}