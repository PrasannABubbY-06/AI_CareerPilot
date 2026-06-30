import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../constants/app_colors.dart';
import '../../widgets/animations/three_d_tilt_wrapper.dart';
import '../../widgets/common/primary_button.dart';
import '../../widgets/common/glass_container.dart';
import 'package:ai_careerpilot/config/app_theme_extension.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<_OnboardingData> _pages = [
    _OnboardingData(
      title: "Welcome to AI_CareerPilot",
      description:
          "Your futuristic AI-powered copilot for career mapping, skill tracking, and landing your dream job.",
      image: "assets/images/onboarding1.png",
    ),
    _OnboardingData(
      title: "Intelligent Guidance",
      description:
          "Receive customized roadmap suggestions and AI feedback tailored to your professional background.",
      image: "assets/images/onboarding2.png",
    ),
    _OnboardingData(
      title: "Elevate Your Career",
      description:
          "Track your skills, polish your resume with ATS optimization, and conquer mock interviews.",
      image: "assets/images/onboarding3.png",
    ),
  ];

  Future<void> _finishOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool("onboarding_completed", true);

    if (!mounted) return;
    Navigator.pushReplacementNamed(context, "/login");
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Stack(
        children: [
          // Background Glowing Mesh Circles
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
                    color: Theme.of(context).primaryColor.withOpacity(0.15),
                    blurRadius: 120,
                  ),
                ],
              ),
            ),
          ),
          Positioned(
            bottom: -50,
            right: -50,
            child: Container(
              width: 350,
              height: 350,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Theme.of(context).colorScheme.secondary.withOpacity(0.12),
                    blurRadius: 150,
                  ),
                ],
              ),
            ),
          ),

          // Main Layout
          SafeArea(
            child: Column(
              children: [
                // Top header actions
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Align(
                    alignment: Alignment.topRight,
                    child: TextButton(
                      onPressed: _finishOnboarding,
                      style: TextButton.styleFrom(
                        foregroundColor: Colors.white70,
                        backgroundColor: Colors.white.withOpacity(0.04),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                          side: BorderSide(
                            color: Colors.white.withOpacity(0.08),
                          ),
                        ),
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      ),
                      child: Text(
                        "Skip",
                        style: GoogleFonts.poppins(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                ),

                // PageView
                Expanded(
                  child: PageView.builder(
                    controller: _pageController,
                    itemCount: _pages.length,
                    onPageChanged: (index) {
                      setState(() => _currentPage = index);
                    },
                    itemBuilder: (context, index) {
                      final page = _pages[index];

                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            // 3D Tilt Image Wrapper with glass panel background
                            ThreeDTiltWrapper(
                              child: GlassContainer(
                                padding: const EdgeInsets.all(24),
                                opacity: 0.03,
                                borderRadius: BorderRadius.circular(36),
                                child: Image.asset(
                                  page.image,
                                  height: 240,
                                  fit: BoxFit.contain,
                                ),
                              ),
                            ).animate(key: ValueKey(page.image))
                             .fade(duration: 500.ms)
                             .scale(begin: const Offset(0.9, 0.9), end: const Offset(1.0, 1.0), curve: Curves.easeOutBack),

                            const SizedBox(height: 50),

                            // Glowing Gradient/White Title
                            ShaderMask(
                              shaderCallback: (bounds) => Theme.of(context).extension<AppThemeExtension>()!.primaryGradient.createShader(bounds),
                              child: Text(
                                page.title,
                                textAlign: TextAlign.center,
                                style: GoogleFonts.poppins(
                                  fontSize: 28,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                  letterSpacing: 0.5,
                                ),
                              ),
                            ).animate(key: ValueKey('${page.title}_title'))
                             .fade(delay: 100.ms, duration: 400.ms)
                             .slideY(begin: 0.15, end: 0, curve: Curves.easeOutQuad),

                            const SizedBox(height: 16),

                            // Description
                            Text(
                              page.description,
                              textAlign: TextAlign.center,
                              style: GoogleFonts.poppins(
                                fontSize: 14.5,
                                color: (Theme.of(context).textTheme.bodyMedium?.color ?? Colors.grey),
                                height: 1.6,
                              ),
                            ).animate(key: ValueKey('${page.description}_desc'))
                             .fade(delay: 200.ms, duration: 400.ms)
                             .slideY(begin: 0.15, end: 0, curve: Curves.easeOutQuad),
                          ],
                        ),
                      );
                    },
                  ),
                ),

                // Indicator
                SmoothPageIndicator(
                  controller: _pageController,
                  count: _pages.length,
                  effect: ExpandingDotsEffect(
                    dotHeight: 6,
                    dotWidth: 6,
                    activeDotColor: Theme.of(context).primaryColor,
                    dotColor: Colors.white24,
                    spacing: 8,
                  ),
                ),

                const SizedBox(height: 30),

                // Premium action button
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: PrimaryButton(
                    text: _currentPage == _pages.length - 1 ? "Get Started" : "Continue",
                    onPressed: () {
                      if (_currentPage == _pages.length - 1) {
                        _finishOnboarding();
                      } else {
                        _pageController.nextPage(
                          duration: const Duration(milliseconds: 350),
                          curve: Curves.easeInOut,
                        );
                      }
                    },
                  ),
                ),

                const SizedBox(height: 35),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _OnboardingData {
  final String title;
  final String description;
  final String image;

  _OnboardingData({
    required this.title,
    required this.description,
    required this.image,
  });
}
