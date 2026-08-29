import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

 
  Future<User?> signUp(String email, String password) async {
    try {
      final UserCredential result =
          await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      return result.user;
    } on FirebaseAuthException {
           rethrow;
    } catch (e) {
      throw Exception('Sign up failed: $e');
    }
  }

  
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

  
  Future<void> logout() async {
    try {
      await _auth.signOut();
    } on FirebaseAuthException {
      rethrow;
    } catch (e) {
      throw Exception('Sign out failed: $e');
    }
  }

  
  User? get currentUser {
    return _auth.currentUser;
  }

  
  bool get isLoggedIn {
    return _auth.currentUser != null;
  }
}
