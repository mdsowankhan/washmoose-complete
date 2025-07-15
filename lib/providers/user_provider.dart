// lib/providers/user_provider.dart

import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../services/auth_service.dart';

class UserProvider with ChangeNotifier {
  // Services
  final AuthService _authService = AuthService();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  
  // User information
  User? _user;
  Map<String, dynamic>? _userData;
  bool _isLoading = true;
  String _errorMessage = '';
  
  // Test mode flag
  bool _isTestMode = false;

  // Getters
  User? get user => _user;
  Map<String, dynamic>? get userData => _userData;
  bool get isLoading => _isLoading;
  String get errorMessage => _errorMessage;
  bool get isAuthenticated => _user != null || _isTestMode;
  bool get isCustomer => (_userData != null && _userData!['userType'] == 'customer') || 
                         (_isTestMode && _userData != null && _userData!['userType'] == 'customer');
  bool get isWasher => (_userData != null && _userData!['userType'] == 'washer') || 
                       (_isTestMode && _userData != null && _userData!['userType'] == 'washer');
  String get washerType => _userData != null && _userData!['washerType'] != null 
      ? _userData!['washerType'] 
      : 'everyday';
  bool get isTestMode => _isTestMode;

  // Constructor - initialize with current user state
  UserProvider() {
    _init();
  }

  // Initialize the provider with current auth state
  Future<void> _init() async {
    _isLoading = true;
    notifyListeners();
    
    try {
      // Get current user
      _user = _authService.currentUser;
      
      if (_user != null) {
        // Load user data from Firestore
        await _loadUserData();
      }
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
    
    // Listen for auth state changes
    FirebaseAuth.instance.authStateChanges().listen((User? user) {
      if (!_isTestMode) {
        _user = user;
        if (user != null) {
          _loadUserData();
        } else {
          _userData = null;
          notifyListeners();
        }
      }
    });
  }

  // Load user data from Firestore
  Future<void> _loadUserData() async {
    if (_user == null && !_isTestMode) return;
    
    try {
      if (_isTestMode) {
        // Test mode user data is already loaded
        return;
      }
      
      DocumentSnapshot doc = await _firestore.collection('users').doc(_user!.uid).get();
      if (doc.exists) {
        _userData = doc.data() as Map<String, dynamic>?;
        notifyListeners();
      }
    } catch (e) {
      _errorMessage = 'Failed to load user data: $e';
      notifyListeners();
    }
  }

  // Sign in with email and password
  Future<bool> signIn(String email, String password) async {
    _isLoading = true;
    _errorMessage = '';
    notifyListeners();
    
    try {
      // Test accounts for development
      if (email == 'customer@test.com' && password == 'password') {
        _isTestMode = true;
        _userData = {
          'fullName': 'Test Customer',
          'email': 'customer@test.com',
          'phone': '+1234567890',
          'userType': 'customer',
        };
        _isLoading = false;
        notifyListeners();
        return true;
      } else if (email == 'washer@test.com' && password == 'password') {
        _isTestMode = true;
        _userData = {
          'fullName': 'Test Washer',
          'email': 'washer@test.com',
          'phone': '+1234567890',
          'userType': 'washer',
          'washerType': 'everyday',
        };
        _isLoading = false;
        notifyListeners();
        return true;
      } else if (email == 'expert@test.com' && password == 'password') {
        _isTestMode = true;
        _userData = {
          'fullName': 'Test Expert',
          'email': 'expert@test.com',
          'phone': '+1234567890',
          'userType': 'washer',
          'washerType': 'expert',
        };
        _isLoading = false;
        notifyListeners();
        return true;
      }
      
      // Real Firebase authentication
      await _authService.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      _user = _authService.currentUser;
      
      if (_user != null) {
        await _loadUserData();
      }
      
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _isLoading = false;
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }

  // Sign up with email and password
  Future<bool> signUp({
    required String email,
    required String password,
    required String fullName,
    required String phone,
    required String userType,
  }) async {
    _isLoading = true;
    _errorMessage = '';
    notifyListeners();
    
    try {
      // Test mode signup
      if (kDebugMode) {
        _isTestMode = true;
        _userData = {
          'fullName': fullName,
          'email': email,
          'phone': phone,
          'userType': userType,
          'washerType': userType == 'washer' ? 'everyday' : null,
        };
        _isLoading = false;
        notifyListeners();
        return true;
      }
      
      // Real Firebase signup
      await _authService.signUpWithEmailAndPassword(
        email: email,
        password: password,
        fullName: fullName,
        phone: phone,
        userType: userType,
      );
      
      _user = _authService.currentUser;
      
      if (_user != null) {
        await _loadUserData();
      }
      
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _isLoading = false;
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }

  // Sign out
  Future<void> signOut() async {
    _isLoading = true;
    notifyListeners();
    
    try {
      if (_isTestMode) {
        _isTestMode = false;
        _userData = null;
      } else {
        await _authService.signOut();
      }
      _user = null;
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Update user profile
  Future<bool> updateProfile({
    String? fullName,
    String? phone,
    String? washerType,
  }) async {
    if (_user == null && !_isTestMode) return false;
    
    _isLoading = true;
    notifyListeners();
    
    try {
      if (_isTestMode) {
        // Update test mode user data
        if (fullName != null) _userData!['fullName'] = fullName;
        if (phone != null) _userData!['phone'] = phone;
        if (washerType != null) _userData!['washerType'] = washerType;
      } else {
        // Update real user data
        await _authService.updateUserProfile(
          uid: _user!.uid,
          fullName: fullName,
          phone: phone,
          washerType: washerType,
        );
        
        // Refresh user data
        await _loadUserData();
      }
      
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _isLoading = false;
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }

  // Refresh user data from Firestore
  Future<void> refreshUserData() async {
    if (!_isTestMode) {
      await _loadUserData();
    }
  }
}