import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../services/auth_service.dart';
import 'home_screen.dart';
import 'signup_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final AuthService _authService = AuthService();

  final TextEditingController _emailController =
      TextEditingController();

  final TextEditingController _passwordController =
      TextEditingController();

  final GlobalKey<FormState> _formKey =
      GlobalKey<FormState>();

  bool _loading = false;
  bool _obscure = true;

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _loading = true;
    });

    try {
      await _authService.login(
        _emailController.text.trim(),
        _passwordController.text.trim(),
      );

      if (!mounted) return;

      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(
          builder: (_) => const HomeScreen(),
        ),
        (_) => false,
      );
    } on FirebaseAuthException catch (e) {
      if (!mounted) return;

      String message;

      switch (e.code) {
        case 'invalid-credential':
        case 'wrong-password':
        case 'user-not-found':
          message = 'Email or password is incorrect.';
          break;

        case 'invalid-email':
          message = 'Please enter a valid email.';
          break;

        case 'user-disabled':
          message = 'This account has been disabled.';
          break;

        case 'too-many-requests':
          message = 'Too many attempts. Try again later.';
          break;

        default:
          message = e.message ?? 'Login failed.';
      }

      _showMessage(message);
    } catch (_) {
      if (mounted) {
        _showMessage(
          'Something went wrong. Please try again.',
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _loading = false;
        });
      }
    }
  }

  void _showMessage(String text) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(text),
        behavior: SnackBarBehavior.floating,
        backgroundColor: const Color(0xFF222222),
      ),
    );
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  InputDecoration _decoration(
    String hint,
    IconData icon,
    Widget? suffix,
  ) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(
        color: Colors.white38,
        fontSize: 14,
      ),
      prefixIcon: Icon(
        icon,
        color: Colors.white60,
        size: 21,
      ),
      suffixIcon: suffix,
      filled: true,
      fillColor: const Color(0xCC111111),
      contentPadding: const EdgeInsets.symmetric(
        horizontal: 18,
        vertical: 17,
      ),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(
          color: Colors.white12,
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(
          color: Colors.white54,
          width: 1.2,
        ),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(
          color: Colors.redAccent,
        ),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(
          color: Colors.redAccent,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF050505),
      body: Stack(
        fit: StackFit.expand,
        children: [
         

          Image.asset(
            'assets/images/login_background.jpeg',
            fit: BoxFit.cover,
          ),

         

          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Color(0x99000000),
                  Color(0xCC000000),
                  Color(0xF5050505),
                ],
                stops: [
                  0.0,
                  0.45,
                  1.0,
                ],
              ),
            ),
          ),


          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 30,
                ),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(
                    maxWidth: 450,
                  ),
                  child: Form(
                    key: _formKey,
                    child: Container(
                      padding: const EdgeInsets.all(32),
                      decoration: BoxDecoration(
                        color: const Color(0xD90B0B0B),
                        borderRadius:
                            BorderRadius.circular(24),
                        border: Border.all(
                          color: Colors.white12,
                        ),
                        boxShadow: const [
                          BoxShadow(
                            color: Colors.black54,
                            blurRadius: 35,
                            spreadRadius: 5,
                            offset: Offset(0, 15),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment:
                            CrossAxisAlignment.stretch,
                        children: [
Center(
  child: Column(
    children: [
     
      ClipRRect(
        borderRadius: BorderRadius.circular(14),
        child: Image.asset(
           'assets/images/movie_app_banner.png',
          width: 180,
          height: 114,
          fit: BoxFit.cover,
        ),
      ),

      const SizedBox(height: 18),

     
      RichText(
        textAlign: TextAlign.center,
        text: const TextSpan(
          children: [
            TextSpan(
              text: 'MOVIE ',
              style: TextStyle(
                color: Colors.white,
                fontSize: 30,
                fontWeight: FontWeight.w900,
                letterSpacing: 3,
              ),
            ),
            TextSpan(
              text: 'APP',
              style: TextStyle(
                color: Color(0xFFE53935),
                fontSize: 30,
                fontWeight: FontWeight.w900,
                letterSpacing: 3,
              ),
            ),
          ],
        ),
      ),

      const SizedBox(height: 7),

      const Text(
        'DISCOVER • WATCH • ENJOY',
        textAlign: TextAlign.center,
        style: TextStyle(
          color: Colors.white60,
          fontSize: 11,
          fontWeight: FontWeight.w500,
          letterSpacing: 2,
        ),
      ),
    ],
  ),
),

                        
                          const Text(
                            'Email',
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                            ),
                          ),

                          const SizedBox(height: 8),

                          TextFormField(
                            controller: _emailController,
                            keyboardType:
                                TextInputType.emailAddress,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                            ),
                            decoration: _decoration(
                              'Enter your email',
                              Icons.email_outlined,
                              null,
                            ),
                            validator: (value) {
                              if (value == null ||
                                  value.trim().isEmpty) {
                                return 'Please enter your email.';
                              }

                              if (!value.contains('@')) {
                                return 'Please enter a valid email.';
                              }

                              return null;
                            },
                          ),

                          const SizedBox(height: 18),


                          const Text(
                            'Password',
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                            ),
                          ),

                          const SizedBox(height: 8),

                          TextFormField(
                            controller: _passwordController,
                            obscureText: _obscure,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                            ),
                            decoration: _decoration(
                              'Enter your password',
                              Icons.lock_outline_rounded,
                              IconButton(
                                onPressed: () {
                                  setState(() {
                                    _obscure = !_obscure;
                                  });
                                },
                                icon: Icon(
                                  _obscure
                                      ? Icons.visibility_outlined
                                      : Icons.visibility_off_outlined,
                                  color: Colors.white54,
                                  size: 21,
                                ),
                              ),
                            ),
                            validator: (value) {
                              if (value == null ||
                                  value.isEmpty) {
                                return 'Please enter your password.';
                              }

                              return null;
                            },
                          ),

                          const SizedBox(height: 28),

                          SizedBox(
                            height: 54,
                            child: ElevatedButton(
                              onPressed:
                                  _loading ? null : _login,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.white,
                                foregroundColor: Colors.black,
                                disabledBackgroundColor:
                                    Colors.white70,
                                elevation: 5,
                                shadowColor: Colors.black54,
                                shape:
                                    RoundedRectangleBorder(
                                  borderRadius:
                                      BorderRadius.circular(12),
                                ),
                              ),
                              child: _loading
                                  ? const SizedBox(
                                      width: 22,
                                      height: 22,
                                      child:
                                          CircularProgressIndicator(
                                        color: Colors.black,
                                        strokeWidth: 2.5,
                                      ),
                                    )
                                  : const Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Text(
                                          'Sign In',
                                          style: TextStyle(
                                            fontSize: 16,
                                            fontWeight:
                                                FontWeight.w800,
                                          ),
                                        ),
                                        SizedBox(width: 9),
                                        Icon(
                                          Icons
                                              .arrow_forward_rounded,
                                          size: 20,
                                        ),
                                      ],
                                    ),
                            ),
                          ),

                          const SizedBox(height: 26),

                          Row(
                            mainAxisAlignment:
                                MainAxisAlignment.center,
                            children: [
                              const Text(
                                "Don't have an account? ",
                                style: TextStyle(
                                  color: Colors.white54,
                                  fontSize: 13,
                                ),
                              ),
                              TextButton(
                                onPressed: _loading
                                    ? null
                                    : () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (_) =>
                                                const SignupScreen(),
                                          ),
                                        );
                                      },
                                style: TextButton.styleFrom(
                                  padding:
                                      const EdgeInsets.symmetric(
                                    horizontal: 4,
                                  ),
                                ),
                                child: const Text(
                                  'Sign Up',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 13,
                                    fontWeight:
                                        FontWeight.w800,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
