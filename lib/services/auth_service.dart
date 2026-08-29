import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // =========================
  // SIGN UP
  // =========================
  Future<User?> signUp(String email, String password) async {
    try {
      final UserCredential result =
          await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      return result.user;
    } on FirebaseAuthException {
      // مهم جدًا:
      // نعيد نفس FirebaseAuthException
      // حتى SignupScreen يقدر يعرف نوع الخطأ
      rethrow;
    } catch (e) {
      throw Exception('Sign up failed: $e');
    }
  }

  // =========================
  // LOGIN
  // =========================
  Future<User?> login(String email, String password) async {
    try {
      final UserCredential result =
          await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      return result.user;
    } on FirebaseAuthException {
      rethrow;
    } catch (e) {
      throw Exception('Login failed: $e');
    }
  }

  // =========================
  // LOGOUT
  // =========================
  Future<void> logout() async {
    try {
      await _auth.signOut();
    } on FirebaseAuthException {
      rethrow;
    } catch (e) {
      throw Exception('Sign out failed: $e');
    }
  }

  // =========================
  // CURRENT USER
  // =========================
  User? get currentUser {
    return _auth.currentUser;
  }

  // =========================
  // CHECK LOGIN
  // =========================
  bool get isLoggedIn {
    return _auth.currentUser != null;
  }
}