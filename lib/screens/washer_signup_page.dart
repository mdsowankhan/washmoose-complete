import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../services/phone_verification_service.dart'; // ✅ NEW: Import phone service

class WasherSignupPage extends StatefulWidget {
  final String initialWasherType;
  const WasherSignupPage({super.key, required this.initialWasherType});

  @override
  State<WasherSignupPage> createState() => _WasherSignupPageState();
}

class _WasherSignupPageState extends State<WasherSignupPage> {
  final _formKey = GlobalKey<FormState>();
  final _fullNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final otpController = TextEditingController(); // ✅ NEW: OTP input controller
  
  late String washerType;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool isLoading = false;

  // ✅ NEW: Phone verification state variables
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
    washerType = widget.initialWasherType;
  }

  @override
  void dispose() {
    _fullNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    otpController.dispose(); // ✅ NEW: Dispose OTP controller
    super.dispose();
  }

  // ✅ NEW: Send OTP to phone number
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

  // ✅ SIMPLIFIED: Quick Signup (No Documents Required)
  Future<void> _submitSignup() async {
    if (!_formKey.currentState!.validate()) return;

    // ✅ NEW: Check phone verification before proceeding
    if (!_isPhoneVerified) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please verify your phone number before creating account'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    setState(() => isLoading = true);

    try {
      // Create Firebase Auth user
      final UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );

      if (userCredential.user != null) {
        // ✅ NEW: Link phone credential to the user
        if (_phoneService.phoneCredential != null) {
          try {
            await _phoneService.linkPhoneToCurrentUser(_phoneService.phoneCredential!);
          } catch (e) {
            print('Warning: Could not link phone credential: $e');
            // Continue with signup even if phone linking fails
          }
        }

        // Send email verification
        await userCredential.user!.sendEmailVerification();

        // ✅ NEW: Create user in Firestore with verification status
        await _firestore.collection('users').doc(userCredential.user!.uid).set({
          'fullName': _fullNameController.text.trim(),
          'email': _emailController.text.trim(),
          'phone': _phoneService.formatAustralianPhone(_phoneController.text.trim()), // ✅ NEW: Store formatted phone
          'phoneVerified': true, // ✅ NEW: Mark phone as verified
          'userType': 'washer',
          'washerType': washerType,
          
          // ✅ NEW: Verification & Online Status Fields
          'isVerified': false,           // Admin sets to true after document review
          'isOnline': false,             // Washer can toggle only if verified
          'documentsStatus': 'pending',  // pending/submitted/approved/rejected
          'canReceiveOrders': false,     // Can only receive orders when verified & online
          
          // ✅ NEW: Document tracking (empty initially)
          'documents': {
            'driverLicence': null,
            'visa': null,
            'policeCheck': null,
            'profilePhoto': null,
          },
          
          'createdAt': FieldValue.serverTimestamp(),
          'updatedAt': FieldValue.serverTimestamp(),
        });

        if (mounted) {
          // Show success message and navigate
          showDialog(
            context: context,
            barrierDismissible: false,
            builder: (context) => AlertDialog(
              title: const Row(
                children: [
                  Icon(Icons.check_circle, color: Colors.green, size: 28),
                  SizedBox(width: 8),
                  Text('Account Created!'),
                ],
              ),
              content: const Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('✅ Your washer account has been created successfully!'),
                  SizedBox(height: 12),
                  Text('📧 Please check your email and verify your account.'),
                  SizedBox(height: 12),
                  Text('📱 Your phone number has been verified.'),
                  SizedBox(height: 12),
                  Text('📋 After verification, upload your documents in the profile section to start receiving orders.'),
                  SizedBox(height: 12),
                  Text(
                    '⚠️ You can login but cannot go online until admin approves your documents.',
                    style: TextStyle(
                      fontWeight: FontWeight.w500,
                      color: Colors.orange,
                    ),
                  ),
                ],
              ),
              actions: [
                ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context); // Close dialog
                    Navigator.pop(context); // Go back to choose role or login
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF00C2CB),
                  ),
                  child: const Text('Got it!'),
                ),
              ],
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        String errorMessage = 'Signup failed. Please try again.';
        
        // Handle specific errors
        if (e.toString().contains('email-already-in-use')) {
          errorMessage = 'This email is already registered. Please login instead.';
        } else if (e.toString().contains('weak-password')) {
          errorMessage = 'Password is too weak. Please use a stronger password.';
        } else if (e.toString().contains('invalid-email')) {
          errorMessage = 'Please enter a valid email address.';
        }
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errorMessage),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 4),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    const washMooseColor = Color(0xFF00C2CB);

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text('Join as Washer'),
        backgroundColor: washMooseColor,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Header Section
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      washMooseColor.withOpacity(0.1),
                      washMooseColor.withOpacity(0.05),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: washMooseColor.withOpacity(0.3)),
                ),
                child: Column(
                  children: [
                    Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        color: washMooseColor.withOpacity(0.2),
                        shape: BoxShape.circle,
                        border: Border.all(color: washMooseColor, width: 2),
                      ),
                      child: const Icon(
                        Icons.local_car_wash,
                        size: 40,
                        color: washMooseColor,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      '${washerType == 'everyday' ? 'Everyday' : 'Expert'} Moose',
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: washMooseColor,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Start earning by washing cars!\nQuick signup - documents upload later.',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.white70,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 32),

              // Washer Type Display (Non-editable)
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: washMooseColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: washMooseColor),
                ),
                child: Row(
                  children: [
                    Icon(
                      washerType == 'everyday' ? Icons.person : Icons.star,
                      color: washMooseColor,
                    ),
                    const SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${washerType == 'everyday' ? 'Everyday' : 'Expert'} Moose',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: washMooseColor,
                          ),
                        ),
                        Text(
                          washerType == 'everyday' 
                              ? 'Basic car washing services'
                              : 'Advanced detailing & premium services',
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.white70,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Form Fields
              _buildInputField(
                controller: _fullNameController,
                hintText: 'Full Name',
                icon: Icons.person_outline,
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

              const SizedBox(height: 16),

              _buildInputField(
                controller: _emailController,
                hintText: 'Email Address',
                icon: Icons.email_outlined,
                keyboardType: TextInputType.emailAddress,
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

              const SizedBox(height: 16),

              // ✅ UPDATED: Phone input with verification UI (Dark Theme)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildInputField(
                    controller: _phoneController,
                    hintText: 'Phone Number (e.g., 0412 345 678)',
                    icon: Icons.phone_outlined,
                    keyboardType: TextInputType.phone,
                    enabled: !_isPhoneVerified, // ✅ NEW: Disable after verification
                    suffixIcon: _isPhoneVerified 
                        ? const Icon(Icons.verified, color: Colors.green) // ✅ NEW: Show verified icon
                        : null,
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
                  
                  // ✅ NEW: Send OTP button (shows when phone is entered but not verified)
                  if (!_isPhoneVerified && !_isOtpSent) ...[
                    const SizedBox(height: 8),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _isSendingOtp ? null : _sendOtp,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: washMooseColor.withOpacity(0.2),
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
                                child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                              )
                            : const Text('Send OTP'),
                      ),
                    ),
                  ],
                ],
              ),
              
              // ✅ NEW: OTP verification section (shows after OTP is sent) - Dark Theme
              if (_isOtpSent && !_isPhoneVerified) ...[
                const SizedBox(height: 16),
                
                // OTP input field
                _buildInputField(
                  controller: otpController,
                  hintText: 'Enter 6-digit OTP',
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
                
                const SizedBox(height: 8),
                
                // Verify OTP and Resend buttons (Dark Theme)
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
                        style: TextButton.styleFrom(
                          foregroundColor: washMooseColor,
                        ),
                        child: const Text('Resend'),
                      ),
                    ),
                  ],
                ),
              ],

              const SizedBox(height: 16),

              _buildInputField(
                controller: _passwordController,
                hintText: 'Password',
                icon: Icons.lock_outline,
                obscureText: _obscurePassword,
                suffixIcon: IconButton(
                  icon: Icon(
                    _obscurePassword ? Icons.visibility : Icons.visibility_off,
                    color: Colors.white54,
                  ),
                  onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a password';
                  }
                  if (value.length < 6) {
                    return 'Password must be at least 6 characters';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 16),

              _buildInputField(
                controller: _confirmPasswordController,
                hintText: 'Confirm Password',
                icon: Icons.lock_outline,
                obscureText: _obscureConfirmPassword,
                suffixIcon: IconButton(
                  icon: Icon(
                    _obscureConfirmPassword ? Icons.visibility : Icons.visibility_off,
                    color: Colors.white54,
                  ),
                  onPressed: () => setState(() => _obscureConfirmPassword = !_obscureConfirmPassword),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please confirm your password';
                  }
                  if (value != _passwordController.text) {
                    return 'Passwords do not match';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 32),

              // ✅ NEW: Info Box about Document Upload
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.blue.shade900.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.blue.shade700),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.info_outline, color: Colors.blue.shade300, size: 20),
                        const SizedBox(width: 8),
                        Text(
                          'What happens next?',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.blue.shade300,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      '1. Create account and verify email\n'
                      '2. Upload documents in profile section\n'
                      '3. Wait for admin approval\n'
                      '4. Start receiving wash orders!',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.white70,
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // ✅ UPDATED: Submit Button (disabled until phone is verified)
              SizedBox(
                height: 56,
                child: ElevatedButton(
                  onPressed: (isLoading || !_isPhoneVerified) ? null : _submitSignup,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _isPhoneVerified ? washMooseColor : Colors.grey,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
                  ),
                  child: isLoading
                      ? const SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : Text(
                          _isPhoneVerified ? 'Create Washer Account' : 'Verify Phone First',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                ),
              ),

              const SizedBox(height: 16),

              // Login Link
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    'Already have an account? ',
                    style: TextStyle(color: Colors.white70),
                  ),
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: const Text(
                      'Sign In',
                      style: TextStyle(
                        color: washMooseColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInputField({
    required TextEditingController controller,
    required String hintText,
    required IconData icon,
    String? Function(String?)? validator,
    TextInputType? keyboardType,
    bool obscureText = false,
    Widget? suffixIcon,
    bool enabled = true, // ✅ NEW: Enable/disable field
    int? maxLength, // ✅ NEW: Max length for OTP
  }) {
    return TextFormField(
      controller: controller,
      validator: validator,
      keyboardType: keyboardType,
      obscureText: obscureText,
      enabled: enabled, // ✅ NEW: Enable/disable functionality
      maxLength: maxLength, // ✅ NEW: Max length support
      style: TextStyle(
        color: enabled ? Colors.white : Colors.grey, // ✅ NEW: Grey out disabled text
      ),
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: const TextStyle(color: Colors.white54),
        prefixIcon: Icon(icon, color: Colors.white54),
        suffixIcon: suffixIcon,
        filled: true,
        fillColor: enabled 
            ? Colors.white.withOpacity(0.1) 
            : Colors.white.withOpacity(0.05), // ✅ NEW: Different background for disabled
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.white24),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFF00C2CB), width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.red, width: 2),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.red, width: 2),
        ),
        counterText: maxLength != null ? "" : null, // ✅ NEW: Hide counter for OTP
      ),
    );
  }
}