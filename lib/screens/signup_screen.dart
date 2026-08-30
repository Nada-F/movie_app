import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../controllers/auth_controller.dart';
import 'home_screen.dart';
import 'login_screen.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  bool _obscurePassword = true;
  bool _obscureConfirm = true;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  Future<void> _signup() async {
    if (!_formKey.currentState!.validate()) return;

    final auth = context.read<AuthController>();
    final success = await auth.signUp(
      _nameController.text.trim(),
      _emailController.text.trim(),
      _passwordController.text.trim(),
    );

    if (!mounted) return;

    if (success) {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const HomeScreen()),
        (_) => false,
      );
    } else {
      _showMessage(auth.errorMessage ?? 'Sign up failed.');
    }
  }

  void _showMessage(String text) {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          text,
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w500),
        ),
        behavior: SnackBarBehavior.floating,
        backgroundColor: const Color(0xFF222222),
        duration: const Duration(seconds: 4),
      ),
    );
  }

  InputDecoration _input(String hint, IconData icon, {Widget? suffix}) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(color: Color(0x4DFFFFFF), fontSize: 13),
      prefixIcon: Icon(icon, color: const Color(0x73FFFFFF), size: 21),
      suffixIcon: suffix,
      filled: true,
      fillColor: const Color(0xFF151515),
      contentPadding: const EdgeInsets.symmetric(vertical: 17),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: Color(0x12FFFFFF)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: Color(0x55FFFFFF)),
      ),
    );
  }

  Widget _logo() {
    return Center(
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
    );
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthController>();
    final loading = auth.isLoading;

    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset(
            'assets/images/sign_up_background.jpeg',
            fit: BoxFit.cover,
          ),
          Container(color: Colors.black.withOpacity(0.60)),
          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 30),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 550),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        _logo(),
                        const SizedBox(height: 25),
                        const Text(
                          'CREATE YOUR ACCOUNT',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 26,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 1.5,
                          ),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'Your next favorite movie is waiting.',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Color(0x73FFFFFF),
                            fontSize: 13,
                          ),
                        ),
                        const SizedBox(height: 30),
                        TextFormField(
                          controller: _nameController,
                          style: const TextStyle(color: Colors.white),
                          decoration: _input('Full name', Icons.person_outline_rounded),
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Enter your name';
                            }
                            if (value.trim().length < 2) {
                              return 'Enter a valid name';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 13),
                        TextFormField(
                          controller: _emailController,
                          keyboardType: TextInputType.emailAddress,
                          style: const TextStyle(color: Colors.white),
                          decoration: _input('Email address', Icons.mail_outline_rounded),
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Enter your email';
                            }
                            final email = value.trim();
                            if (!email.contains('@') || !email.contains('.')) {
                              return 'Enter a valid email';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 13),
                        TextFormField(
                          controller: _passwordController,
                          obscureText: _obscurePassword,
                          style: const TextStyle(color: Colors.white),
                          decoration: _input(
                            'Password',
                            Icons.lock_outline_rounded,
                            suffix: IconButton(
                              onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                              icon: Icon(
                                _obscurePassword
                                    ? Icons.visibility_outlined
                                    : Icons.visibility_off_outlined,
                                color: const Color(0x73FFFFFF),
                              ),
                            ),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Enter a password';
                            }
                            if (value.length < 6) {
                              return 'Minimum 6 characters';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 13),
                        TextFormField(
                          controller: _confirmController,
                          obscureText: _obscureConfirm,
                          style: const TextStyle(color: Colors.white),
                          decoration: _input(
                            'Confirm password',
                            Icons.verified_user_outlined,
                            suffix: IconButton(
                              onPressed: () => setState(() => _obscureConfirm = !_obscureConfirm),
                              icon: Icon(
                                _obscureConfirm
                                    ? Icons.visibility_outlined
                                    : Icons.visibility_off_outlined,
                                color: const Color(0x73FFFFFF),
                              ),
                            ),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Confirm your password';
                            }
                            if (value != _passwordController.text) {
                              return 'Passwords do not match';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 22),
                        SizedBox(
                          height: 54,
                          child: ElevatedButton(
                            onPressed: loading ? null : _signup,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.white,
                              foregroundColor: Colors.black,
                              disabledBackgroundColor: const Color(0x4DFFFFFF),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            child: loading
                                ? const SizedBox(
                                    width: 22,
                                    height: 22,
                                    child: CircularProgressIndicator(
                                      color: Colors.black,
                                      strokeWidth: 2,
                                    ),
                                  )
                                : const Text(
                                    'CREATE ACCOUNT',
                                    style: TextStyle(
                                      fontWeight: FontWeight.w900,
                                      letterSpacing: 0.8,
                                    ),
                                  ),
                          ),
                        ),
                        const SizedBox(height: 22),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text(
                              'Already a member? ',
                              style: TextStyle(color: Color(0x73FFFFFF), fontSize: 13),
                            ),
                            TextButton(
                              onPressed: loading
                                  ? null
                                  : () {
                                      Navigator.pushReplacement(
                                        context,
                                        MaterialPageRoute(
                                          builder: (_) => const LoginScreen(),
                                        ),
                                      );
                                    },
                              child: const Text(
                                'Sign In',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w800,
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
        ],
      ),
    );
  }
}