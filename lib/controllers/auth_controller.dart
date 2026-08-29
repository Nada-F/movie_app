import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../services/auth_service.dart';

class AuthController extends ChangeNotifier {
  final AuthService _authService = AuthService();

  bool _isLoading = false;
  String? _errorMessage;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  User? get currentUser => _authService.currentUser;
  bool get isLoggedIn => _authService.isLoggedIn;

  Future<bool> login(String email, String password) async {
    _setLoading(true);
    _errorMessage = null;

    try {
      await _authService.login(email, password);
      _setLoading(false);
      return true;
    } on FirebaseAuthException catch (e) {
      _errorMessage = _getLoginErrorMessage(e);
      _setLoading(false);
      return false;
    } catch (e) {
      _errorMessage = 'Something went wrong. Please try again.';
      _setLoading(false);
      return false;
    }
  }

  Future<bool> signUp(String name, String email, String password) async {
    _setLoading(true);
    _errorMessage = null;

    try {
      final user = await _authService.signUp(email, password);
      if (user != null) {
        await user.updateDisplayName(name.trim());
      }
      _setLoading(false);
      return true;
    } on FirebaseAuthException catch (e) {
      _errorMessage = _getSignUpErrorMessage(e);
      _setLoading(false);
      return false;
    } catch (e) {
      _errorMessage = 'Something went wrong: $e';
      _setLoading(false);
      return false;
    }
  }

  Future<void> logout() async {
    _setLoading(true);
    try {
      await _authService.logout();
    } catch (e) {
      
    } finally {
      _setLoading(false);
    }
  }

  
  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  String _getLoginErrorMessage(FirebaseAuthException e) {
    switch (e.code) {
      case 'invalid-credential':
      case 'wrong-password':
      case 'user-not-found':
        return 'Email or password is incorrect.';
      case 'invalid-email':
        return 'Please enter a valid email.';
      case 'user-disabled':
        return 'This account has been disabled.';
      case 'too-many-requests':
        return 'Too many attempts. Try again later.';
      default:
        return e.message ?? 'Login failed.';
    }
  }

  String _getSignUpErrorMessage(FirebaseAuthException e) {
    switch (e.code) {
      case 'email-already-in-use':
        return 'This email is already registered.';
      case 'invalid-email':
        return 'Please enter a valid email address.';
      case 'weak-password':
        return 'Password is too weak. Use a stronger password.';
      case 'operation-not-allowed':
        return 'Email/password authentication is not enabled.';
      case 'network-request-failed':
        return 'No internet connection. Please try again.';
      case 'too-many-requests':
        return 'Too many attempts. Please try again later.';
      default:
        return e.message ?? 'Sign up failed. (${e.code})';
    }
  }
}