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
import 'package:ai_careerpilot/config/app_theme_extension.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final nameController = TextEditingController();
  final phoneController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();

  final authService = AuthService();
  final firestoreService = FirestoreService();

  bool isLoading = false;
  bool isPasswordVisible = false;
  bool isConfirmPasswordVisible = false;

  Future<void> register() async {
    final name = nameController.text.trim();
    final phone = phoneController.text.trim();
    final email = emailController.text.trim();
    final password = passwordController.text.trim();
    final confirmPassword = confirmPasswordController.text.trim();

    if (name.isEmpty ||
        phone.isEmpty ||
        email.isEmpty ||
        password.isEmpty ||
        confirmPassword.isEmpty) {
      _showMsg("Please fill all fields");
      return;
    }

    if (!email.contains("@") || !email.contains(".")) {
      _showMsg("Enter a valid email address");
      return;
    }

    if (phone.length < 10) {
      _showMsg("Enter a valid 10-digit phone number");
      return;
    }

    if (password.length < 6) {
      _showMsg("Password must be minimum 6 characters");
      return;
    }

    if (password != confirmPassword) {
      _showMsg("Passwords do not match");
      return;
    }

    try {
      setState(() => isLoading = true);

      await authService.signUp(
        email: email,
        password: password,
        role: "user",
      );

      await firestoreService.saveUserProfile(
        name: name,
        email: email,
        phone: phone,
      );

      if (!mounted) return;

      _showMsg("Account Created Successfully", isError: false);

      Navigator.pushReplacementNamed(context, "/dashboard");
    } on FirebaseAuthException catch (e) {
      String errorMessage = "Registration Failed";

      if (e.code == 'email-already-in-use') {
        errorMessage = "Account already exists";
      } else if (e.code == 'invalid-email') {
        errorMessage = "Invalid email";
      } else if (e.code == 'weak-password') {
        errorMessage = "Weak password";
      }

      _showMsg(errorMessage);
    } catch (e) {
      _showMsg("Something went wrong");
    } finally {
      setState(() => isLoading = false);
    }
  }

  void _showMsg(String msg, {bool isError = true}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg, style: GoogleFonts.poppins()),
        backgroundColor: isError ? Theme.of(context).colorScheme.error : Theme.of(context).extension<AppThemeExtension>()!.success,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Stack(
        children: [
          // Background Glows
          Positioned(
            top: -100,
            left: -100,
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Theme.of(context).primaryColor.withOpacity(0.12),
                    blurRadius: 110,
                  ),
                ],
              ),
            ),
          ),
          Positioned(
            bottom: -80,
            right: -80,
            child: Container(
              width: 320,
              height: 320,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Theme.of(context).colorScheme.secondary.withOpacity(0.08),
                    blurRadius: 125,
                  ),
                ],
              ),
            ),
          ),

          // Content
          Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
              child: Hero(
                tag: 'auth_card',
                child: GlassContainer(
                  width: 420,
                  opacity: 0.04,
                  borderRadius: BorderRadius.circular(28),
                  padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 32),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Glowing Icon setup
                      Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.secondary.withOpacity(0.08),
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: Theme.of(context).colorScheme.secondary.withOpacity(0.15),
                            width: 1.5,
                          ),
                        ),
                        child: Icon(
                          Icons.person_add_rounded,
                          color: Theme.of(context).colorScheme.secondary,
                          size: 40,
                        ),
                      ).animate()
                       .fade(duration: 500.ms)
                       .scale(begin: const Offset(0.8, 0.8), end: const Offset(1.0, 1.0), curve: Curves.easeOutBack),

                      const SizedBox(height: 16),

                      Text(
                        "Create Account",
                        style: GoogleFonts.poppins(
                          color: Colors.white,
                          fontSize: 26,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.5,
                        ),
                      ).animate()
                       .fade(delay: 100.ms, duration: 400.ms)
                       .slideY(begin: 0.15, end: 0, curve: Curves.easeOutQuad),

                      const SizedBox(height: 6),

                      Text(
                        "Start your AI-guided career journey",
                        textAlign: TextAlign.center,
                        style: GoogleFonts.poppins(
                          color: (Theme.of(context).textTheme.bodyMedium?.color ?? Colors.grey),
                          fontSize: 13,
                        ),
                      ).animate()
                       .fade(delay: 150.ms, duration: 400.ms)
                       .slideY(begin: 0.15, end: 0, curve: Curves.easeOutQuad),

                      const SizedBox(height: 28),

                      // Fields
                      CustomTextField(
                        controller: nameController,
                        hintText: "Full Name",
                        prefixIcon: Icons.person_outline_rounded,
                      ).animate()
                       .fade(delay: 200.ms, duration: 400.ms)
                       .slideX(begin: -0.04, end: 0, curve: Curves.easeOutQuad),

                      const SizedBox(height: 14),

                      CustomTextField(
                        controller: phoneController,
                        hintText: "Phone Number",
                        prefixIcon: Icons.phone_outlined,
                        keyboardType: TextInputType.phone,
                      ).animate()
                       .fade(delay: 250.ms, duration: 400.ms)
                       .slideX(begin: 0.04, end: 0, curve: Curves.easeOutQuad),

                      const SizedBox(height: 14),

                      CustomTextField(
                        controller: emailController,
                        hintText: "Email",
                        prefixIcon: Icons.email_outlined,
                        keyboardType: TextInputType.emailAddress,
                      ).animate()
                       .fade(delay: 300.ms, duration: 400.ms)
                       .slideX(begin: -0.04, end: 0, curve: Curves.easeOutQuad),

                      const SizedBox(height: 14),

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
                            color: (Theme.of(context).textTheme.bodyMedium?.color ?? Colors.grey),
                            size: 20,
                          ),
                        ),
                      ).animate()
                       .fade(delay: 350.ms, duration: 400.ms)
                       .slideX(begin: 0.04, end: 0, curve: Curves.easeOutQuad),

                      const SizedBox(height: 14),

                      CustomTextField(
                        controller: confirmPasswordController,
                        hintText: "Confirm Password",
                        prefixIcon: Icons.lock_clock_outlined,
                        obscureText: !isConfirmPasswordVisible,
                        suffixIcon: IconButton(
                          onPressed: () {
                            setState(() {
                              isConfirmPasswordVisible = !isConfirmPasswordVisible;
                            });
                          },
                          icon: Icon(
                            isConfirmPasswordVisible ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                            color: (Theme.of(context).textTheme.bodyMedium?.color ?? Colors.grey),
                            size: 20,
                          ),
                        ),
                      ).animate()
                       .fade(delay: 400.ms, duration: 400.ms)
                       .slideX(begin: -0.04, end: 0, curve: Curves.easeOutQuad),

                      const SizedBox(height: 28),

                      PrimaryButton(
                        text: "Create Account",
                        isLoading: isLoading,
                        onPressed: register,
                      ).animate()
                       .fade(delay: 450.ms, duration: 400.ms)
                       .slideY(begin: 0.15, end: 0, curve: Curves.easeOutQuad),

                      const SizedBox(height: 20),

                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            "Already have an account?",
                            style: GoogleFonts.poppins(
                              color: (Theme.of(context).textTheme.bodyMedium?.color ?? Colors.grey),
                              fontSize: 14,
                            ),
                          ),
                          TextButton(
                            onPressed: () {
                              Navigator.pushReplacementNamed(context, "/login");
                            },
                            child: Text(
                              "Login",
                              style: GoogleFonts.poppins(
                                color: Theme.of(context).primaryColor,
                                fontWeight: FontWeight.w600,
                                fontSize: 14,
                              ),
                            ),
                          ),
                        ],
                      ).animate()
                       .fade(delay: 500.ms, duration: 450.ms),
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
