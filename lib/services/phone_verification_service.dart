import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

class PhoneVerificationService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  
  // Verification states
  String? _verificationId;
  int? _resendToken;
  PhoneAuthCredential? _phoneCredential;
  
  // Getters
  String? get verificationId => _verificationId;
  PhoneAuthCredential? get phoneCredential => _phoneCredential;
  
  // Format Australian phone number to international format
  String formatAustralianPhone(String phoneNumber) {
    // Remove all spaces, dashes, and other characters
    String cleaned = phoneNumber.replaceAll(RegExp(r'[^\d]'), '');
    
    // Handle different Australian phone number formats
    if (cleaned.startsWith('61')) {
      // Already has country code
      return '+$cleaned';
    } else if (cleaned.startsWith('0')) {
      // Remove leading 0 and add +61
      return '+61${cleaned.substring(1)}';
    } else if (cleaned.length >= 9) {
      // Assume it's a mobile number without 0
      return '+61$cleaned';
    }
    
    throw Exception('Invalid Australian phone number format');
  }
  
  // Validate Australian phone number
  bool isValidAustralianPhone(String phoneNumber) {
    try {
      String formatted = formatAustralianPhone(phoneNumber);
      // Australian mobile numbers: +61 4XX XXX XXX (10 digits after +61)
      // Australian landline: +61 2/3/7/8 XXXX XXXX (9-10 digits after +61)
      return formatted.startsWith('+61') && 
             formatted.length >= 12 && 
             formatted.length <= 13;
    } catch (e) {
      return false;
    }
  }
  
  // Send OTP to phone number
  Future<void> sendOTP({
    required String phoneNumber,
    required Function(String verificationId) onCodeSent,
    required Function(String error) onError,
    Function()? onAutoVerification,
    int timeoutSeconds = 60,
  }) async {
    try {
      // Format phone number
      String formattedPhone = formatAustralianPhone(phoneNumber);
      
      if (kDebugMode) {
        print('📱 Sending OTP to: $formattedPhone');
      }
      
      await _auth.verifyPhoneNumber(
        phoneNumber: formattedPhone,
        timeout: Duration(seconds: timeoutSeconds),
        
        // Called when verification is completed automatically
        verificationCompleted: (PhoneAuthCredential credential) async {
          if (kDebugMode) {
            print('✅ Phone verification completed automatically');
          }
          _phoneCredential = credential;
          onAutoVerification?.call();
        },
        
        // Called when verification fails
        verificationFailed: (FirebaseAuthException e) {
          if (kDebugMode) {
            print('❌ Phone verification failed: ${e.message}');
          }
          
          String errorMessage;
          switch (e.code) {
            case 'invalid-phone-number':
              errorMessage = 'Invalid phone number format';
              break;
            case 'too-many-requests':
              errorMessage = 'Too many requests. Please try again later';
              break;
            case 'quota-exceeded':
              errorMessage = 'SMS quota exceeded. Please try again tomorrow';
              break;
            default:
              errorMessage = e.message ?? 'Phone verification failed';
          }
          onError(errorMessage);
        },
        
        // Called when OTP is sent
        codeSent: (String verificationId, int? resendToken) {
          if (kDebugMode) {
            print('📤 OTP sent successfully. Verification ID: $verificationId');
          }
          _verificationId = verificationId;
          _resendToken = resendToken;
          onCodeSent(verificationId);
        },
        
        // Called when auto-retrieval timeout
        codeAutoRetrievalTimeout: (String verificationId) {
          if (kDebugMode) {
            print('⏰ Auto-retrieval timeout for: $verificationId');
          }
          _verificationId = verificationId;
        },
        
        // Use resend token for subsequent requests
        forceResendingToken: _resendToken,
      );
      
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error sending OTP: $e');
      }
      onError('Failed to send OTP: ${e.toString()}');
    }
  }
  
  // Verify OTP code
  Future<PhoneAuthCredential?> verifyOTP({
    required String otpCode,
    String? customVerificationId,
  }) async {
    try {
      String verificationIdToUse = customVerificationId ?? _verificationId ?? '';
      
      if (verificationIdToUse.isEmpty) {
        throw Exception('No verification ID available');
      }
      
      if (kDebugMode) {
        print('🔍 Verifying OTP: $otpCode with ID: $verificationIdToUse');
      }
      
      // Create credential
      PhoneAuthCredential credential = PhoneAuthProvider.credential(
        verificationId: verificationIdToUse,
        smsCode: otpCode,
      );
      
      _phoneCredential = credential;
      
      if (kDebugMode) {
        print('✅ OTP verified successfully');
      }
      
      return credential;
      
    } catch (e) {
      if (kDebugMode) {
        print('❌ OTP verification failed: $e');
      }
      rethrow;
    }
  }
  
  // Link phone credential to existing user
  Future<void> linkPhoneToCurrentUser(PhoneAuthCredential credential) async {
    try {
      User? currentUser = _auth.currentUser;
      if (currentUser == null) {
        throw Exception('No user logged in');
      }
      
      if (kDebugMode) {
        print('🔗 Linking phone credential to current user');
      }
      
      await currentUser.linkWithCredential(credential);
      
      if (kDebugMode) {
        print('✅ Phone credential linked successfully');
      }
      
    } catch (e) {
      if (kDebugMode) {
        print('❌ Failed to link phone credential: $e');
      }
      
      // Handle specific linking errors
      if (e is FirebaseAuthException) {
        switch (e.code) {
          case 'provider-already-linked':
            throw Exception('Phone number is already linked to this account');
          case 'credential-already-in-use':
            throw Exception('This phone number is already used by another account');
          case 'invalid-credential':
            throw Exception('Invalid verification code');
          default:
            throw Exception(e.message ?? 'Failed to link phone number');
        }
      }
      
      throw Exception('Failed to link phone number: ${e.toString()}');
    }
  }
  
  // Sign in with phone credential (for phone-only login)
  Future<UserCredential> signInWithPhone(PhoneAuthCredential credential) async {
    try {
      if (kDebugMode) {
        print('📱 Signing in with phone credential');
      }
      
      UserCredential result = await _auth.signInWithCredential(credential);
      
      if (kDebugMode) {
        print('✅ Phone sign-in successful');
      }
      
      return result;
      
    } catch (e) {
      if (kDebugMode) {
        print('❌ Phone sign-in failed: $e');
      }
      
      if (e is FirebaseAuthException) {
        switch (e.code) {
          case 'invalid-verification-code':
            throw Exception('Invalid verification code');
          case 'invalid-verification-id':
            throw Exception('Invalid verification ID');
          case 'session-expired':
            throw Exception('Verification session expired. Please try again');
          default:
            throw Exception(e.message ?? 'Phone sign-in failed');
        }
      }
      
      throw Exception('Phone sign-in failed: ${e.toString()}');
    }
  }
  
  // Resend OTP
  Future<void> resendOTP({
    required String phoneNumber,
    required Function(String verificationId) onCodeSent,
    required Function(String error) onError,
    Function()? onAutoVerification,
  }) async {
    if (kDebugMode) {
      print('🔄 Resending OTP...');
    }
    
    await sendOTP(
      phoneNumber: phoneNumber,
      onCodeSent: onCodeSent,
      onError: onError,
      onAutoVerification: onAutoVerification,
      timeoutSeconds: 60,
    );
  }
  
  // Clear verification data
  void clearVerificationData() {
    _verificationId = null;
    _resendToken = null;
    _phoneCredential = null;
    
    if (kDebugMode) {
      print('🧹 Verification data cleared');
    }
  }
  
  // Check if phone number is already verified for current user
  bool isPhoneVerified() {
    User? currentUser = _auth.currentUser;
    if (currentUser == null) return false;
    
    // Check if any of the user's providers is phone
    for (UserInfo userInfo in currentUser.providerData) {
      if (userInfo.providerId == 'phone') {
        return true;
      }
    }
    
    return false;
  }
  
  // Get current user's verified phone number
  String? getVerifiedPhoneNumber() {
    User? currentUser = _auth.currentUser;
    if (currentUser == null) return null;
    
    for (UserInfo userInfo in currentUser.providerData) {
      if (userInfo.providerId == 'phone') {
        return userInfo.phoneNumber;
      }
    }
    
    return null;
  }
}