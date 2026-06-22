import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../constants/app_colors.dart';
import '../../services/auth_service.dart';
import '../../services/firestore_service.dart';
import '../../widgets/common/custom_textfield.dart';
import '../../widgets/common/primary_button.dart';
import '../../widgets/common/glass_container.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  final AuthService authService = AuthService();
  final FirestoreService firestoreService = FirestoreService();

  bool isLoading = false;
  bool isPasswordVisible = false;

  Future<void> login() async {
    final email = emailController.text.trim();
    final password = passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      _showMsg("Please fill all fields");
      return;
    }

    try {
      setState(() => isLoading = true);

      final UserCredential result = await authService.login(
        email: email,
        password: password,
      );

      final User? user = result.user;

      if (user != null) {
        await firestoreService.saveUserAfterLogin(user);

        if (!mounted) return;

        Navigator.pushReplacementNamed(context, "/dashboard");
      }
    } on FirebaseAuthException catch (e) {
      String message = "Login Failed";

      if (e.code == 'user-not-found') {
        message = "User not found";
      } else if (e.code == 'wrong-password') {
        message = "Wrong password";
      } else if (e.code == 'invalid-email') {
        message = "Invalid email";
      } else if (e.code == 'invalid-credential') {
        message = "Invalid email or password";
      }

      _showMsg(message);
    } catch (e) {
      _showMsg("Something went wrong");
    } finally {
      setState(() => isLoading = false);
    }
  }

  void _showMsg(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg, style: GoogleFonts.poppins()),
        backgroundColor: AppColors.error,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffoldBg,
      body: Stack(
        children: [
          // Background Glows
          Positioned(
            top: -80,
            right: -80,
            child: Container(
              width: 280,
              height: 280,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withOpacity(0.12),
                    blurRadius: 100,
                  ),
                ],
              ),
            ),
          ),
          Positioned(
            bottom: -100,
            left: -100,
            child: Container(
              width: 320,
              height: 320,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: AppColors.secondary.withOpacity(0.08),
                    blurRadius: 120,
                  ),
                ],
              ),
            ),
          ),

          // Content
          Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Hero(
                tag: 'auth_card',
                child: GlassContainer(
                  width: 420,
                  opacity: 0.04,
                  borderRadius: BorderRadius.circular(28),
                  padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 36),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Brand Logo Icon with glowing background tint
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withOpacity(0.08),
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: AppColors.primary.withOpacity(0.15),
                            width: 1.5,
                          ),
                        ),
                        child: const Icon(
                          Icons.radar_rounded, // Futuristic branding icon
                          color: AppColors.primary,
                          size: 50,
                        ),
                      ).animate()
                       .fade(duration: 500.ms)
                       .scale(begin: const Offset(0.8, 0.8), end: const Offset(1.0, 1.0), curve: Curves.easeOutBack),

                      const SizedBox(height: 24),

                      // Brand Title
                      Text(
                        "AI_CareerPilot",
                        style: GoogleFonts.poppins(
                          color: Colors.white,
                          fontSize: 30,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.5,
                        ),
                      ).animate()
                       .fade(delay: 100.ms, duration: 400.ms)
                       .slideY(begin: 0.15, end: 0, curve: Curves.easeOutQuad),

                      const SizedBox(height: 8),

                      // Tagline
                      Text(
                        "Professional Career Intelligence",
                        style: GoogleFonts.poppins(
                          color: AppColors.textSecondary,
                          fontSize: 14,
                        ),
                      ).animate()
                       .fade(delay: 150.ms, duration: 400.ms)
                       .slideY(begin: 0.15, end: 0, curve: Curves.easeOutQuad),

                      const SizedBox(height: 36),

                      // Email Field
                      CustomTextField(
                        controller: emailController,
                        hintText: "Email Address",
                        prefixIcon: Icons.email_outlined,
                        keyboardType: TextInputType.emailAddress,
                      ).animate()
                       .fade(delay: 200.ms, duration: 400.ms)
                       .slideX(begin: -0.04, end: 0, curve: Curves.easeOutQuad),

                      const SizedBox(height: 18),

                      // Password Field
                      CustomTextField(
                        controller: passwordController,
                        hintText: "Password",
                        prefixIcon: Icons.lock_outline_rounded,
                        obscureText: !isPasswordVisible,
                        suffixIcon: IconButton(
                          onPressed: () {
                            setState(() {
                              isPasswordVisible = !isPasswordVisible;
                            });
                          },
                          icon: Icon(
                            isPasswordVisible ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                            color: AppColors.textSecondary,
                            size: 20,
                          ),
                        ),
                      ).animate()
                       .fade(delay: 250.ms, duration: 400.ms)
                       .slideX(begin: 0.04, end: 0, curve: Curves.easeOutQuad),

                      const SizedBox(height: 32),

                      // Login Button
                      PrimaryButton(
                        text: "Login",
                        isLoading: isLoading,
                        onPressed: login,
                      ).animate()
                       .fade(delay: 300.ms, duration: 400.ms)
                       .slideY(begin: 0.15, end: 0, curve: Curves.easeOutQuad),

                      const SizedBox(height: 24),

                      // New User Row
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            "New user?",
                            style: GoogleFonts.poppins(
                              color: AppColors.textSecondary,
                              fontSize: 14,
                            ),
                          ),
                          TextButton(
                            onPressed: () {
                              Navigator.pushNamed(context, "/register");
                            },
                            child: Text(
                              "Create Account",
                              style: GoogleFonts.poppins(
                                color: AppColors.primary,
                                fontWeight: FontWeight.w600,
                                fontSize: 14,
                              ),
                            ),
                          ),
                        ],
                      ).animate()
                       .fade(delay: 350.ms, duration: 450.ms),
                    ],
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
