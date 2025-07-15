import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../services/phone_verification_service.dart'; // ✅ NEW: Import phone service

class EditInfoPage extends StatefulWidget {
  final Map<String, dynamic> currentData;
  final Function(Map<String, dynamic>) onUpdate;
  
  const EditInfoPage({
    super.key,
    required this.currentData,
    required this.onUpdate,
  });

  @override
  State<EditInfoPage> createState() => _EditInfoPageState();
}

class _EditInfoPageState extends State<EditInfoPage> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _phoneController;
  late TextEditingController _emailController;
  final otpController = TextEditingController(); // ✅ NEW: OTP input controller
  
  bool _isLoading = false;
  bool _emailChanged = false;
  String? _originalEmail;
  String? _originalPhone; // ✅ NEW: Track original phone

  // ✅ NEW: Phone verification state variables
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
  final PhoneVerificationService _phoneService = PhoneVerificationService(); // ✅ NEW: Phone service instance

  @override
  void initState() {
    super.initState();
    _originalEmail = widget.currentData['email'] ?? '';
    _originalPhone = widget.currentData['phone'] ?? ''; // ✅ NEW: Store original phone
    _nameController = TextEditingController(text: widget.currentData['fullName'] ?? '');
    _phoneController = TextEditingController(text: _originalPhone);
    _emailController = TextEditingController(text: _originalEmail);
    
    // 🔄 NEW: Check for email sync issues on page load
    _checkEmailSync();
    
    // Listen for email changes
    _emailController.addListener(() {
      setState(() {
        _emailChanged = _emailController.text.trim() != _originalEmail;
      });
    });

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

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    otpController.dispose(); // ✅ NEW: Dispose OTP controller
    super.dispose();
  }

  // 🔄 NEW: Check if Firebase Auth email and Firestore email are out of sync
  Future<void> _checkEmailSync() async {
    try {
      final User? currentUser = _auth.currentUser;
      if (currentUser == null) return;

      final String firebaseAuthEmail = currentUser.email ?? '';
      final String firestoreEmail = widget.currentData['email'] ?? '';

      // If emails don't match, Firebase Auth has been updated but Firestore hasn't
      if (firebaseAuthEmail.isNotEmpty && 
          firestoreEmail.isNotEmpty && 
          firebaseAuthEmail != firestoreEmail) {
        
        print('🔄 Email sync issue detected:');
        print('Firebase Auth: $firebaseAuthEmail');
        print('Firestore: $firestoreEmail');
        
        // Auto-sync Firestore to match Firebase Auth
        await _syncEmailToFirestore(currentUser, firebaseAuthEmail);
      }
    } catch (e) {
      print('Error checking email sync: $e');
    }
  }

  // 🔄 NEW: Sync Firestore email to match Firebase Auth email
  Future<void> _syncEmailToFirestore(User currentUser, String firebaseAuthEmail) async {
    try {
      // Update Firestore to match Firebase Auth
      await _firestore.collection('users').doc(currentUser.uid).update({
        'email': firebaseAuthEmail,
        'updatedAt': FieldValue.serverTimestamp(),
      });

      // Update the UI controllers to show the correct email
      setState(() {
        _originalEmail = firebaseAuthEmail;
        _emailController.text = firebaseAuthEmail;
      });

      // Call parent update function to refresh the profile display
      await widget.onUpdate({
        'email': firebaseAuthEmail,
        'fullName': widget.currentData['fullName'] ?? '',
        'phone': widget.currentData['phone'] ?? '',
      });

      print('✅ Email synced successfully to: $firebaseAuthEmail');
      
      // Show success message
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Email updated successfully! Your profile now shows the correct email.'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      print('Error syncing email: $e');
    }
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

// ✅ NEW: Debug logging
print('🔍 Debug: Phone validation passed');
print('🔍 Debug: Original phone: $_originalPhone');
print('🔍 Debug: New phone: $phone');
print('🔍 Debug: Formatted phone: ${_phoneService.formatAustralianPhone(phone)}');
    
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

  Future<void> _saveChanges() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    // ✅ NEW: Check phone verification if phone was changed
    if (_phoneChanged && !_isPhoneVerified) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please verify your new phone number before saving'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final User? currentUser = _auth.currentUser;
      if (currentUser == null) {
        throw Exception('No user logged in');
      }

      // Handle email change separately if needed
      if (_emailChanged) {
        await _handleEmailChange(currentUser);
      } else {
        // Just update name and phone
        await _updateBasicInfo(currentUser);
      }

      if (mounted) {
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to update: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  // ✅ UPDATED: This method now handles phone verification
  Future<void> _updateBasicInfo(User currentUser, {bool skipEmailUpdate = false}) async {
    // Update name and phone (with verification check)
    final Map<String, dynamic> updatedData = {
  'fullName': _nameController.text.trim(),
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

    // 🔒 CRITICAL FIX: Only update email in Firestore if it matches Firebase Auth
    if (!skipEmailUpdate && !_emailChanged) {
      // Safe to update email since it hasn't changed
      updatedData['email'] = _emailController.text.trim();
    }

    // Update Firestore
    await _firestore.collection('users').doc(currentUser.uid).update({
      ...updatedData,
      'updatedAt': FieldValue.serverTimestamp(),
    });

    // Update Firebase Auth display name
    await currentUser.updateDisplayName(updatedData['fullName']);

    // Call parent update function
    await widget.onUpdate(updatedData);

    if (mounted) {
      String message = 'Profile updated successfully!';
      if (_phoneChanged && _isPhoneVerified) {
        message = 'Profile updated successfully! Your phone number has been verified.';
      }
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  Future<void> _handleEmailChange(User currentUser) async {
    final newEmail = _emailController.text.trim();
    
    // Show confirmation dialog first
    final bool? confirmed = await _showEmailChangeConfirmation(newEmail);
    if (confirmed != true) return;

    try {
      // Step 1: Verify current password for security
      final String? password = await _requestCurrentPassword();
      if (password == null) return;

      // Step 2: Re-authenticate user
      final credential = EmailAuthProvider.credential(
        email: _originalEmail!,
        password: password,
      );
      await currentUser.reauthenticateWithCredential(credential);

      // Step 3: Verify new email before updating
      await _verifyNewEmail(currentUser, newEmail);

    } catch (e) {
      if (e.toString().contains('wrong-password')) {
        throw Exception('Incorrect password. Please try again.');
      } else if (e.toString().contains('email-already-in-use')) {
        throw Exception('This email is already registered to another account.');
      } else {
        throw Exception('Failed to change email: ${e.toString()}');
      }
    }
  }

  Future<bool?> _showEmailChangeConfirmation(String newEmail) async {
    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.email, color: Colors.orange),
            SizedBox(width: 8),
            Text('Change Email Address'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('You are about to change your email address:'),
            const SizedBox(height: 12),
            Text('From: $_originalEmail', style: const TextStyle(fontWeight: FontWeight.bold)),
            Text('To: $newEmail', style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.green)),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.orange.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.orange.withOpacity(0.3)),
              ),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Security Steps:',
                    style: TextStyle(fontWeight: FontWeight.bold, color: Colors.orange),
                  ),
                  SizedBox(height: 4),
                  Text('1. Enter your current password\n2. Verify the new email address\n3. Sign in with new email'),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
            child: const Text('Continue'),
          ),
        ],
      ),
    );
  }

  Future<String?> _requestCurrentPassword() async {
    final TextEditingController passwordController = TextEditingController();
    bool obscureText = true;

    return showDialog<String>(
      context: context,
      barrierDismissible: false,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Row(
            children: [
              Icon(Icons.security, color: Colors.blue),
              SizedBox(width: 8),
              Text('Confirm Password'),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Please enter your current password to verify your identity:'),
              const SizedBox(height: 16),
              TextField(
                controller: passwordController,
                obscureText: obscureText,
                decoration: InputDecoration(
                  labelText: 'Current Password',
                  prefixIcon: const Icon(Icons.lock_outline),
                  suffixIcon: IconButton(
                    icon: Icon(obscureText ? Icons.visibility : Icons.visibility_off),
                    onPressed: () {
                      setState(() {
                        obscureText = !obscureText;
                      });
                    },
                  ),
                  border: const OutlineInputBorder(),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, null),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                final password = passwordController.text.trim();
                if (password.isNotEmpty) {
                  Navigator.pop(context, password);
                }
              },
              child: const Text('Verify'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _verifyNewEmail(User currentUser, String newEmail) async {
    // Show processing dialog
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const AlertDialog(
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('Sending verification email...'),
          ],
        ),
      ),
    );

    try {
      // Update email in Firebase Auth (this sends verification automatically)
      await currentUser.verifyBeforeUpdateEmail(newEmail);
      
      if (mounted) {
        Navigator.pop(context); // Close processing dialog
        
        // Show success dialog with instructions
        await _showEmailVerificationDialog(newEmail);
      }
    } catch (e) {
      if (mounted) {
        Navigator.pop(context); // Close processing dialog
      }
      throw e;
    }
  }

  // ✅ FIXED: This dialog now handles the email verification properly
  Future<void> _showEmailVerificationDialog(String newEmail) async {
    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.mark_email_read, color: Colors.green),
            SizedBox(width: 8),
            Text('Verification Email Sent'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('A verification email has been sent to:'),
            const SizedBox(height: 8),
            Text(
              newEmail,
              style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.green),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blue.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.blue.withOpacity(0.3)),
              ),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Next Steps:',
                    style: TextStyle(fontWeight: FontWeight.bold, color: Colors.blue),
                  ),
                  SizedBox(height: 4),
                  Text('1. Check your email inbox\n2. Click the verification link\n3. Your email will be updated automatically\n4. Sign in with your new email next time'),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.orange.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.orange.withOpacity(0.3)),
              ),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '⚠️ Important:',
                    style: TextStyle(fontWeight: FontWeight.bold, color: Colors.orange),
                  ),
                  SizedBox(height: 4),
                  Text('Continue using your current email to sign in until you click the verification link. Your profile will show the old email until verification is complete.'),
                ],
              ),
            ),
          ],
        ),
        actions: [
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              
              // 🔒 CRITICAL FIX: Update name and phone only, skip email update
              await _updateBasicInfo(_auth.currentUser!, skipEmailUpdate: true);
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
            child: const Text('Got it!'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    const washMooseColor = Color(0xFF00C2CB);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Profile'),
        backgroundColor: washMooseColor,
        actions: [
          TextButton(
            onPressed: _isLoading ? null : _saveChanges,
            child: _isLoading
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2,
                    ),
                  )
                : const Text(
                    'Save',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Personal Information',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: washMooseColor,
                ),
              ),
              
              const SizedBox(height: 20),
              
              // Full Name field
              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(
                  labelText: 'Full Name',
                  prefixIcon: const Icon(Icons.person_outline),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(color: washMooseColor),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter your full name';
                  }
                  if (value.trim().length < 2) {
                    return 'Name must be at least 2 characters';
                  }
                  return null;
                },
              ),
              
              const SizedBox(height: 20),
              
              // Email field (now editable!)
              TextFormField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: InputDecoration(
                  labelText: 'Email Address',
                  prefixIcon: const Icon(Icons.email_outlined),
                  suffixIcon: _emailChanged 
                      ? const Icon(Icons.warning, color: Colors.orange)
                      : null,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(
                      color: _emailChanged ? Colors.orange : washMooseColor,
                    ),
                  ),
                  helperText: _emailChanged 
                      ? 'Email change requires verification'
                      : null,
                  helperStyle: const TextStyle(color: Colors.orange),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter your email';
                  }
                  if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value.trim())) {
                    return 'Please enter a valid email';
                  }
                  return null;
                },
              ),
              
              const SizedBox(height: 20),
              
              // ✅ UPDATED: Phone field with verification UI
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextFormField(
                    controller: _phoneController,
                    keyboardType: TextInputType.phone,
                    enabled: !(_phoneChanged && _isPhoneVerified), // ✅ NEW: Disable after verification
                    decoration: InputDecoration(
                      labelText: 'Phone Number (e.g., 0412 345 678)',
                      prefixIcon: const Icon(Icons.phone_outlined),
                      suffixIcon: (_phoneChanged && _isPhoneVerified) 
                          ? const Icon(Icons.verified, color: Colors.green) // ✅ NEW: Show verified icon
                          : (_phoneChanged ? const Icon(Icons.warning, color: Colors.orange) : null),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide(
                          color: _phoneChanged ? Colors.orange : washMooseColor,
                        ),
                      ),
                      helperText: _phoneChanged && !_isPhoneVerified
                          ? 'Phone change requires verification'
                          : (_phoneChanged && _isPhoneVerified ? 'Phone verified successfully' : null),
                      helperStyle: TextStyle(
                        color: _phoneChanged && _isPhoneVerified ? Colors.green : Colors.orange,
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Please enter your phone number';
                      }
                      if (!_phoneService.isValidAustralianPhone(value.trim())) {
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
                  
                  // ✅ NEW: Send OTP button (shows when phone is changed but not verified)
                  if (_phoneChanged && !_isPhoneVerified && !_isOtpSent) ...[
                    const SizedBox(height: 8),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _isSendingOtp ? null : _sendOtp,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: washMooseColor.withOpacity(0.1),
                          foregroundColor: washMooseColor,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                            side: BorderSide(color: washMooseColor),
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
                TextFormField(
                  controller: otpController,
                  keyboardType: TextInputType.number,
                  maxLength: 6,
                  decoration: InputDecoration(
                    labelText: 'Enter 6-digit OTP',
                    prefixIcon: const Icon(Icons.sms_outlined),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: const BorderSide(color: washMooseColor),
                    ),
                    counterText: "", // Hide counter
                  ),
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
                
                const SizedBox(height: 8),
                
                // Verify OTP and Resend buttons
                Row(
                  children: [
                    Expanded(
                      flex: 2,
                      child: ElevatedButton(
                        onPressed: _isVerifyingOtp ? null : _verifyOtp,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: washMooseColor,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: _isVerifyingOtp
                            ? const SizedBox(
                                height: 16,
                                width: 16,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2,
                                ),
                              )
                            : const Text('Verify OTP', style: TextStyle(color: Colors.white)),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: TextButton(
                        onPressed: _isSendingOtp ? null : _resendOtp,
                        child: const Text('Resend'),
                      ),
                    ),
                  ],
                ),
              ],
              
              const SizedBox(height: 30),
              
              // Info card
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: (_emailChanged || (_phoneChanged && !_isPhoneVerified))
                      ? Colors.orange.withOpacity(0.1)
                      : washMooseColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: (_emailChanged || (_phoneChanged && !_isPhoneVerified))
                        ? Colors.orange.withOpacity(0.3)
                        : washMooseColor.withOpacity(0.3),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      (_emailChanged || (_phoneChanged && !_isPhoneVerified)) ? Icons.security : Icons.info_outline,
                      color: (_emailChanged || (_phoneChanged && !_isPhoneVerified)) ? Colors.orange : washMooseColor,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        _getInfoCardText(),
                        style: TextStyle(
                          color: (_emailChanged || (_phoneChanged && !_isPhoneVerified)) ? Colors.orange : washMooseColor,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  // ✅ NEW: Get appropriate info card text based on current state
  String _getInfoCardText() {
    if (_emailChanged && (_phoneChanged && !_isPhoneVerified)) {
      return 'Both email and phone changes require verification for security. Complete phone verification first, then email verification will be handled.';
    } else if (_emailChanged) {
      return 'Email changes require verification for security. You\'ll receive a verification email and must click the link before the email is updated.';
    } else if (_phoneChanged && !_isPhoneVerified) {
      return 'Phone number changes require verification for security. You\'ll receive an SMS with a verification code.';
    } else if (_phoneChanged && _isPhoneVerified) {
      return 'Phone number verified successfully! Changes will be saved when you press Save.';
    } else {
      return 'Changes will be saved to your account and reflected across the app.';
    }
  }
}