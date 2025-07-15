import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'dart:io';
import '../services/phone_verification_service.dart'; // ✅ NEW: Import phone service

class WasherEditProfilePage extends StatefulWidget {
  final Map<String, dynamic> currentData;
  final Function(Map<String, dynamic>) onProfileUpdated;

  const WasherEditProfilePage({
    super.key,
    required this.currentData,
    required this.onProfileUpdated,
  });

  @override
  State<WasherEditProfilePage> createState() => _WasherEditProfilePageState();
}

class _WasherEditProfilePageState extends State<WasherEditProfilePage> with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  bool _isUploadingPhoto = false;
  String? _newProfileImageUrl;
  
  // Animation controllers
  late AnimationController _animationController;
  late Animation<double> _slideAnimation;

  // Form controllers
  late TextEditingController _firstNameController;
  late TextEditingController _lastNameController;
  late TextEditingController _emailController;
  late TextEditingController _phoneController;
  late TextEditingController _bioController;
  final otpController = TextEditingController(); // ✅ NEW: OTP input controller

  // ✅ NEW: Phone verification state variables
  String? _originalPhone;
  bool _phoneChanged = false;
  bool _isOtpSent = false;
  bool _isPhoneVerified = false;
  bool _isSendingOtp = false;
  bool _isVerifyingOtp = false;
  String? _verificationId;
  String? _phoneError;
  String? _otpError;

  // Firebase instances
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final PhoneVerificationService _phoneService = PhoneVerificationService(); // ✅ NEW: Phone service instance

  @override
  void initState() {
    super.initState();
    _initializeControllers();
    _setupAnimations();
  }

  void _initializeControllers() {
    _firstNameController = TextEditingController(text: widget.currentData['firstName'] ?? '');
    _lastNameController = TextEditingController(text: widget.currentData['lastName'] ?? '');
    _emailController = TextEditingController(text: widget.currentData['email'] ?? '');
    _originalPhone = widget.currentData['phone'] ?? ''; // ✅ NEW: Store original phone
    _phoneController = TextEditingController(text: _originalPhone);
    _bioController = TextEditingController(text: widget.currentData['bio'] ?? '');

    // ✅ NEW: Listen for phone changes
    _phoneController.addListener(() {
      setState(() {
        _phoneChanged = _phoneController.text.trim() != _originalPhone;
        // Reset phone verification if phone changed
        if (_phoneChanged) {
          _isOtpSent = false;
          _isPhoneVerified = false;
          _phoneError = null;
          _otpError = null;
          otpController.clear();
        }
      });
    });
  }

  void _setupAnimations() {
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _slideAnimation = Tween<double>(begin: 30.0, end: 0.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _bioController.dispose();
    otpController.dispose(); // ✅ NEW: Dispose OTP controller
    super.dispose();
  }

  // ✅ NEW: Send OTP to new phone number
  Future<void> _sendOtp() async {
    String phone = _phoneController.text.trim();
    
    if (phone.isEmpty) {
      setState(() {
        _phoneError = 'Please enter your phone number';
      });
      return;
    }
    
    // Validate Australian phone number
    if (!_phoneService.isValidAustralianPhone(phone)) {
      setState(() {
        _phoneError = 'Please enter a valid Australian phone number';
      });
      return;
    }
    
    setState(() {
      _isSendingOtp = true;
      _phoneError = null;
      _otpError = null;
    });
    
    await _phoneService.sendOTP(
      phoneNumber: phone,
      onCodeSent: (verificationId) {
        setState(() {
          _verificationId = verificationId;
          _isOtpSent = true;
          _isSendingOtp = false;
          _phoneError = null;
        });
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('OTP sent to ${_phoneService.formatAustralianPhone(phone)}'),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
          ),
        );
      },
      onError: (error) {
        setState(() {
          _isSendingOtp = false;
          _phoneError = error;
          _isOtpSent = false;
        });
      },
      onAutoVerification: () {
        // Handle auto-verification if supported
        setState(() {
          _isPhoneVerified = true;
          _isSendingOtp = false;
        });
        
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Phone verified automatically!'),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
          ),
        );
      },
    );
  }
  
  // ✅ NEW: Verify OTP code
  Future<void> _verifyOtp() async {
    String otp = otpController.text.trim();
    
    if (otp.isEmpty || otp.length != 6) {
      setState(() {
        _otpError = 'Please enter the 6-digit OTP';
      });
      return;
    }
    
    setState(() {
      _isVerifyingOtp = true;
      _otpError = null;
    });
    
    try {
      PhoneAuthCredential? credential = await _phoneService.verifyOTP(
        otpCode: otp,
        customVerificationId: _verificationId,
      );
      
      if (credential != null) {
        setState(() {
          _isPhoneVerified = true;
          _isVerifyingOtp = false;
          _otpError = null;
        });
        
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Phone verified successfully!'),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      setState(() {
        _isVerifyingOtp = false;
        _otpError = 'Invalid OTP. Please try again.';
      });
    }
  }
  
  // ✅ NEW: Resend OTP
  Future<void> _resendOtp() async {
    await _sendOtp();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      appBar: _buildAppBar(),
      body: AnimatedBuilder(
        animation: _slideAnimation,
        builder: (context, child) {
          return Transform.translate(
            offset: Offset(0, _slideAnimation.value),
            child: Opacity(
              opacity: 1 - (_slideAnimation.value / 30),
              child: Form(
                key: _formKey,
                child: SingleChildScrollView(
                  padding: EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildProfilePhotoSection(),
                      SizedBox(height: 32),
                      _buildPersonalInfoSection(),
                      SizedBox(height: 24),
                      _buildContactInfoSection(),
                      SizedBox(height: 24),
                      _buildProfessionalInfoSection(),
                      SizedBox(height: 40),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  AppBar _buildAppBar() {
    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      leading: IconButton(
        icon: Icon(Icons.close, color: Theme.of(context).colorScheme.onSurface),
        onPressed: () => Navigator.pop(context),
      ),
      title: Text(
        'Edit Profile',
        style: TextStyle(
          color: Theme.of(context).colorScheme.onSurface,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),
      centerTitle: true,
      actions: [
        TextButton(
          onPressed: _isLoading ? null : _saveProfile,
          child: _isLoading
            ? SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  color: Colors.amber,
                  strokeWidth: 2,
                ),
              )
            : Text(
                'Save',
                style: TextStyle(
                  color: Colors.amber,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
        ),
      ],
      flexibleSpace: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.amber.withOpacity(0.1),
              Colors.orange.withOpacity(0.05),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProfilePhotoSection() {
    final String? currentPhotoUrl = _newProfileImageUrl ?? widget.currentData['profileImageUrl'];
    
    return Center(
      child: Column(
        children: [
          Stack(
            children: [
              Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.amber, width: 3),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.amber.withOpacity(0.3),
                      blurRadius: 15,
                      offset: Offset(0, 5),
                    ),
                  ],
                ),
                child: CircleAvatar(
                  radius: 60,
                  backgroundColor: Colors.grey[200],
                  backgroundImage: currentPhotoUrl != null ? NetworkImage(currentPhotoUrl) : null,
                  child: currentPhotoUrl == null
                    ? Icon(Icons.person, size: 60, color: Colors.grey[600])
                    : null,
                ),
              ),
              Positioned(
                bottom: 0,
                right: 0,
                child: GestureDetector(
                  onTap: _isUploadingPhoto ? null : _updateProfilePhoto,
                  child: Container(
                    padding: EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.amber,
                      shape: BoxShape.circle,
                      border: Border.all(color: Theme.of(context).colorScheme.surface, width: 2),
                    ),
                    child: _isUploadingPhoto
                      ? SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(
                            color: Colors.black,
                            strokeWidth: 2,
                          ),
                        )
                      : Icon(Icons.camera_alt, color: Colors.black, size: 20),
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 12),
          Text(
            'Tap to change photo',
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPersonalInfoSection() {
    return _buildSection(
      'Personal Information',
      Icons.person,
      [
        Row(
          children: [
            Expanded(
              child: _buildTextField(
                controller: _firstNameController,
                label: 'First Name',
                icon: Icons.person_outline,
                validator: (value) => value?.trim().isEmpty == true ? 'First name is required' : null,
              ),
            ),
            SizedBox(width: 16),
            Expanded(
              child: _buildTextField(
                controller: _lastNameController,
                label: 'Last Name',
                icon: Icons.person_outline,
                validator: (value) => value?.trim().isEmpty == true ? 'Last name is required' : null,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildContactInfoSection() {
    return _buildSection(
      'Contact Information',
      Icons.contact_phone,
      [
        _buildTextField(
          controller: _emailController,
          label: 'Email Address',
          icon: Icons.email_outlined,
          keyboardType: TextInputType.emailAddress,
          validator: (value) {
            if (value?.trim().isEmpty == true) return 'Email is required';
            if (!RegExp(r'^[\w\-\.]+@([\w\-]+\.)+[\w\-]{2,4}$').hasMatch(value!)) {
              return 'Please enter a valid email address';
            }
            return null;
          },
        ),
        SizedBox(height: 16),
        
        // ✅ UPDATED: Phone field with verification UI
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildTextField(
              controller: _phoneController,
              label: 'Phone Number',
              icon: Icons.phone_outlined,
              keyboardType: TextInputType.phone,
              hintText: 'e.g., 0412 345 678',
              enabled: !(_phoneChanged && _isPhoneVerified), // ✅ NEW: Disable after verification
              suffixWidget: (_phoneChanged && _isPhoneVerified) 
                  ? Icon(Icons.verified, color: Colors.green, size: 20) // ✅ NEW: Show verified icon
                  : (_phoneChanged ? Icon(Icons.warning, color: Colors.orange, size: 20) : null),
              validator: (value) {
                if (value?.trim().isEmpty == true) return 'Phone number is required';
                if (!_phoneService.isValidAustralianPhone(value!.trim())) {
                  return 'Please enter a valid Australian phone number';
                }
                return null;
              },
            ),
            
            // ✅ NEW: Phone error message
            if (_phoneError != null)
              Padding(
                padding: const EdgeInsets.only(top: 4, left: 12),
                child: Text(
                  _phoneError!,
                  style: const TextStyle(color: Colors.red, fontSize: 12),
                ),
              ),
            
            // ✅ NEW: Phone change helper text
            if (_phoneChanged && !_isPhoneVerified)
              Padding(
                padding: const EdgeInsets.only(top: 4, left: 12),
                child: Text(
                  'Phone change requires verification',
                  style: TextStyle(color: Colors.orange, fontSize: 12),
                ),
              ),
            
            if (_phoneChanged && _isPhoneVerified)
              Padding(
                padding: const EdgeInsets.only(top: 4, left: 12),
                child: Text(
                  'Phone verified successfully',
                  style: TextStyle(color: Colors.green, fontSize: 12),
                ),
              ),
            
            // ✅ NEW: Send OTP button (shows when phone is changed but not verified)
            if (_phoneChanged && !_isPhoneVerified && !_isOtpSent) ...[
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isSendingOtp ? null : _sendOtp,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.amber.withOpacity(0.1),
                    foregroundColor: Colors.amber,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                      side: BorderSide(color: Colors.amber),
                    ),
                  ),
                  child: _isSendingOtp
                      ? const SizedBox(
                          height: 16,
                          width: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text('Send OTP to New Number'),
                ),
              ),
            ],
          ],
        ),
        
        // ✅ NEW: OTP verification section (shows after OTP is sent)
        if (_isOtpSent && !_isPhoneVerified) ...[
          const SizedBox(height: 16),
          
          // OTP input field
          _buildTextField(
            controller: otpController,
            label: 'Enter 6-digit OTP',
            icon: Icons.sms_outlined,
            keyboardType: TextInputType.number,
            maxLength: 6,
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Please enter the OTP';
              }
              if (value.trim().length != 6) {
                return 'OTP must be 6 digits';
              }
              return null;
            },
          ),
          
          // OTP error message
          if (_otpError != null)
            Padding(
              padding: const EdgeInsets.only(top: 4, left: 12),
              child: Text(
                _otpError!,
                style: const TextStyle(color: Colors.red, fontSize: 12),
              ),
            ),
          
          const SizedBox(height: 12),
          
          // Verify OTP and Resend buttons
          Row(
            children: [
              Expanded(
                flex: 2,
                child: ElevatedButton(
                  onPressed: _isVerifyingOtp ? null : _verifyOtp,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.amber,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: _isVerifyingOtp
                      ? const SizedBox(
                          height: 16,
                          width: 16,
                          child: CircularProgressIndicator(
                            color: Colors.black,
                            strokeWidth: 2,
                          ),
                        )
                      : const Text('Verify OTP', style: TextStyle(color: Colors.black)),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: TextButton(
                  onPressed: _isSendingOtp ? null : _resendOtp,
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.amber,
                  ),
                  child: const Text('Resend'),
                ),
              ),
            ],
          ),
        ],
      ],
    );
  }

  Widget _buildProfessionalInfoSection() {
    return _buildSection(
      'Professional Information',
      Icons.work,
      [
        _buildTextField(
          controller: _bioController,
          label: 'Bio',
          icon: Icons.description_outlined,
          maxLines: 4,
          validator: (value) {
            if (value?.trim().isEmpty == true) return 'Bio is required';
            final wordCount = value!.trim().split(RegExp(r'\s+')).length;
            if (wordCount > 70) return 'Bio cannot exceed 70 words (currently $wordCount words)';
            return null;
          },
          hintText: 'Tell customers about your experience and specialties... (Max 70 words)',
        ),
      ],
    );
  }

  Widget _buildSection(String title, IconData icon, List<Widget> children) {
    return Container(
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey[300]!),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: Colors.amber, size: 20),
              SizedBox(width: 8),
              Text(
                title,
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onSurface,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          SizedBox(height: 16),
          ...children,
        ],
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType? keyboardType,
    int maxLines = 1,
    int? maxLength, // ✅ NEW: Max length for OTP
    String? Function(String?)? validator,
    String? hintText,
    bool enabled = true, // ✅ NEW: Enable/disable field
    Widget? suffixWidget, // ✅ NEW: Custom suffix widget
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      maxLines: maxLines,
      maxLength: maxLength, // ✅ NEW: Max length support
      enabled: enabled, // ✅ NEW: Enable/disable functionality
      validator: validator,
      style: TextStyle(
        color: enabled 
            ? Theme.of(context).colorScheme.onSurface 
            : Colors.grey, // ✅ NEW: Grey out disabled text
        fontSize: 16,
      ),
      decoration: InputDecoration(
        labelText: label,
        hintText: hintText,
        prefixIcon: Icon(icon, color: Colors.amber, size: 20),
        suffixIcon: suffixWidget, // ✅ NEW: Custom suffix support
        labelStyle: TextStyle(color: Colors.grey[600]),
        hintStyle: TextStyle(color: Colors.grey[500], fontSize: 14),
        filled: true,
        fillColor: enabled 
            ? Colors.grey[50] 
            : Colors.grey[25], // ✅ NEW: Different background for disabled
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.amber, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.red, width: 2),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.red, width: 2),
        ),
        contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        counterText: maxLength != null ? "" : null, // ✅ NEW: Hide counter for OTP
      ),
    );
  }

  Future<void> _updateProfilePhoto() async {
    try {
      final ImageSource? source = await _showPhotoSourceDialog();
      if (source == null) return;

      setState(() {
        _isUploadingPhoto = true;
      });

      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(
        source: source,
        maxWidth: 800,
        maxHeight: 800,
        imageQuality: 90,
      );

      if (image == null) {
        setState(() {
          _isUploadingPhoto = false;
        });
        return;
      }

      final User? currentUser = _auth.currentUser;
      if (currentUser != null) {
        final String fileName = '${currentUser.uid}_profile_${DateTime.now().millisecondsSinceEpoch}.jpg';
        final Reference storageRef = _storage.ref().child('profile_images/$fileName');
        
        final UploadTask uploadTask = storageRef.putFile(File(image.path));
        final TaskSnapshot snapshot = await uploadTask;
        final String downloadUrl = await snapshot.ref.getDownloadURL();

        setState(() {
          _newProfileImageUrl = downloadUrl;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Photo updated! Save to confirm changes.'),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to update photo: ${e.toString()}'),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
        ),
      );
    } finally {
      setState(() {
        _isUploadingPhoto = false;
      });
    }
  }

  Future<ImageSource?> _showPhotoSourceDialog() async {
    return await showModalBottomSheet<ImageSource>(
      context: context,
      backgroundColor: Theme.of(context).colorScheme.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Update Profile Photo',
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurface,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: _buildPhotoSourceButton(
                    'Camera',
                    Icons.camera_alt,
                    () => Navigator.pop(context, ImageSource.camera),
                  ),
                ),
                SizedBox(width: 12),
                Expanded(
                  child: _buildPhotoSourceButton(
                    'Gallery',
                    Icons.photo_library,
                    () => Navigator.pop(context, ImageSource.gallery),
                  ),
                ),
              ],
            ),
            SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildPhotoSourceButton(String title, IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.amber.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.amber.withOpacity(0.3)),
        ),
        child: Column(
          children: [
            Icon(icon, color: Colors.amber, size: 32),
            SizedBox(height: 8),
            Text(
              title,
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurface,
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;

    // ✅ NEW: Check phone verification if phone was changed
    if (_phoneChanged && !_isPhoneVerified) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please verify your new phone number before saving'),
          backgroundColor: Colors.orange,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final User? currentUser = _auth.currentUser;
      if (currentUser != null) {
        final Map<String, dynamic> updatedData = {
          'firstName': _firstNameController.text.trim(),
          'lastName': _lastNameController.text.trim(),
          'email': _emailController.text.trim(),
          'bio': _bioController.text.trim(),
          'updatedAt': FieldValue.serverTimestamp(),
        };

        // ✅ NEW: Handle phone update with verification
        if (_phoneChanged && _isPhoneVerified) {
          // Phone was changed and verified, so update it
          updatedData['phone'] = _phoneService.formatAustralianPhone(_phoneController.text.trim());
          updatedData['phoneVerified'] = true;
          
          // ✅ NEW: Link phone credential to user if available
          if (_phoneService.phoneCredential != null) {
            try {
              await _phoneService.linkPhoneToCurrentUser(_phoneService.phoneCredential!);
            } catch (e) {
              print('Warning: Could not link phone credential: $e');
              // Continue with update even if phone linking fails
            }
          }
        } else if (!_phoneChanged) {
          // Phone wasn't changed, keep original
          updatedData['phone'] = _originalPhone ?? '';
        }
        // If phone was changed but not verified, don't update it (this case is caught above)

        // Include profile image if updated
        if (_newProfileImageUrl != null) {
          updatedData['profileImageUrl'] = _newProfileImageUrl!;
        }

        // Update Firebase
        await _firestore.collection('users').doc(currentUser.uid).update(updatedData);
        
        // Update local data
        final fullUpdatedData = Map<String, dynamic>.from(widget.currentData);
        fullUpdatedData.addAll(updatedData);
        
        // Call parent callback
        widget.onProfileUpdated(fullUpdatedData);
        
        if (mounted) {
          String message = '✅ Profile updated successfully!';
          if (_phoneChanged && _isPhoneVerified) {
            message = '✅ Profile updated successfully! Your phone number has been verified.';
          }
          
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(message),
              backgroundColor: Colors.green,
              behavior: SnackBarBehavior.floating,
            ),
          );
          Navigator.pop(context);
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to update profile: ${e.toString()}'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }
}