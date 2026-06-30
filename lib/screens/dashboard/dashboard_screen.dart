import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../constants/app_colors.dart';
import '../../widgets/cards/dashboard_card.dart';
import '../../widgets/navigation/bottom_navbar.dart';
import '../../widgets/animations/three_d_tilt_wrapper.dart';
import '../../widgets/common/glass_container.dart';
import '../../services/notification_service.dart';
import 'package:ai_careerpilot/config/app_theme_extension.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int currentIndex = 0;

  @override
  void initState() {
    super.initState();
    NotificationService().initialize();
  }

  void openNotifications() {
    Navigator.pushNamed(context, "/notifications");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,

      // ================= APPBAR =================
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          "Welcome Back 👋",
          style: GoogleFonts.poppins(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        actions: [
          // 🔔 BELL ICON with Badge
          ValueListenableBuilder<int>(
            valueListenable: NotificationService().unreadCountNotifier,
            builder: (context, unreadCount, child) {
              return Stack(
                alignment: Alignment.center,
                children: [
                  IconButton(
                    icon: const Icon(Icons.notifications_rounded, color: Colors.white),
                    onPressed: openNotifications,
                  ),
                  if (unreadCount > 0)
                    Positioned(
                      right: 8,
                      top: 8,
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: const BoxDecoration(
                          color: Colors.redAccent,
                          shape: BoxShape.circle,
                        ),
                        constraints: const BoxConstraints(
                          minWidth: 16,
                          minHeight: 16,
                        ),
                        child: Text(
                          unreadCount > 9 ? '9+' : '$unreadCount',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                ],
              );
            },
          ),

          // 👤 PROFILE BUTTON
          Padding(
            padding: const EdgeInsets.only(right: 14),
            child: GestureDetector(
              onTap: () {
                Navigator.pushNamed(
                  context,
                  "/profile",
                );
              },
              child: Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: Theme.of(context).extension<AppThemeExtension>()!.primaryGradient,
                  boxShadow: [
                    BoxShadow(
                      color: Theme.of(context).primaryColor.withOpacity(0.3),
                      blurRadius: 8,
                      spreadRadius: 1,
                    )
                  ]
                ),
                child: const CircleAvatar(
                  backgroundColor: Colors.transparent,
                  radius: 18,
                  child: Text(
                    "P",
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),

      // ================= BODY =================
      body: Stack(
        children: [
          // Mesh Glow backgrounds
          Positioned(
            top: 40,
            left: -120,
            child: Container(
              width: 320,
              height: 320,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Theme.of(context).primaryColor.withOpacity(0.08),
                    blurRadius: 120,
                  ),
                ],
              ),
            ),
          ),
          Positioned(
            bottom: 150,
            right: -100,
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Theme.of(context).colorScheme.secondary.withOpacity(0.06),
                    blurRadius: 110,
                  ),
                ],
              ),
            ),
          ),

          SingleChildScrollView(
            padding: const EdgeInsets.all(18),
            child: Column(
              children: [
                // HERO SECTION
                ThreeDTiltWrapper(
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      gradient: Theme.of(context).extension<AppThemeExtension>()!.primaryGradient,
                      borderRadius: BorderRadius.circular(28),
                      boxShadow: [
                        BoxShadow(
                          color: Theme.of(context).primaryColor.withOpacity(0.25),
                          blurRadius: 20,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(100),
                          ),
                          child: Text(
                            "SYSTEM ACTIVE ⚡",
                            style: GoogleFonts.poppins(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1.0,
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          "Pilot Your Career Future 🚀",
                          style: GoogleFonts.poppins(
                            color: Colors.white,
                            fontSize: 26,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 0.5,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          "AI-powered intelligent career mentor platform.",
                          style: GoogleFonts.poppins(
                            color: Colors.white.withOpacity(0.85),
                            fontSize: 14,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ],
                    ),
                  ),
                ).animate().fade(duration: 600.ms).slideY(begin: 0.1, end: 0, curve: Curves.easeOutQuad),

                const SizedBox(height: 22),

                // ================= GRID =================
                GridView.count(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisCount: 2,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  childAspectRatio: 0.88,
                  children: [
                    DashboardCard(
                      icon: Icons.analytics_rounded,
                      title: "Skill Analyzer",
                      subtitle: "Track your skills",
                      value: "78%",
                      color: Theme.of(context).primaryColor,
                      onTap: () {
                        Navigator.pushNamed(
                          context,
                          "/skill-analyzer",
                        );
                      },
                    ).animate().fade(delay: 100.ms, duration: 400.ms).slideY(begin: 0.1, end: 0, curve: Curves.easeOutQuad),

                    DashboardCard(
                      icon: Icons.description_rounded,
                      title: "Resume ATS",
                      subtitle: "Resume analysis",
                      value: "85%",
                      color: Theme.of(context).extension<AppThemeExtension>()!.success,
                      onTap: () {
                        Navigator.pushNamed(
                          context,
                          "/resume-review",
                        );
                      },
                    ).animate().fade(delay: 200.ms, duration: 400.ms).slideY(begin: 0.1, end: 0, curve: Curves.easeOutQuad),

                    DashboardCard(
                      icon: Icons.mic_rounded,
                      title: "AI Interview",
                      subtitle: "Mock interview",
                      value: "12 Qs",
                      color: Theme.of(context).extension<AppThemeExtension>()!.warning,
                      onTap: () {
                        Navigator.pushNamed(
                          context,
                          "/mock-interview",
                        );
                      },
                    ).animate().fade(delay: 300.ms, duration: 400.ms).slideY(begin: 0.1, end: 0, curve: Curves.easeOutQuad),

                    DashboardCard(
                      icon: Icons.map_rounded,
                      title: "Roadmap",
                      subtitle: "Track progress",
                      value: "Daily",
                      color: Theme.of(context).colorScheme.secondary,
                      onTap: () {
                        Navigator.pushNamed(
                          context,
                          "/roadmap",
                        );
                      },
                    ).animate().fade(delay: 400.ms, duration: 400.ms).slideY(begin: 0.1, end: 0, curve: Curves.easeOutQuad),
                  ],
                ),

                const SizedBox(height: 22),

                // ================= WEEKLY GOALS =================
                ThreeDTiltWrapper(
                  child: GestureDetector(
                    onTap: () {
                      Navigator.pushNamed(
                        context,
                        "/weekly-goals",
                      );
                    },
                    child: GlassContainer(
                      width: double.infinity,
                      padding: const EdgeInsets.all(22),
                      opacity: 0.04,
                      borderRadius: BorderRadius.circular(28),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: Theme.of(context).extension<AppThemeExtension>()!.warning.withOpacity(0.12),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Icon(
                                  Icons.flag_rounded,
                                  color: Theme.of(context).extension<AppThemeExtension>()!.warning,
                                  size: 24,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Text(
                                "Weekly Goals",
                                style: GoogleFonts.poppins(
                                  color: Colors.white,
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 18),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                "2 of 4 goals completed",
                                style: GoogleFonts.poppins(
                                  color: (Theme.of(context).textTheme.bodyMedium?.color ?? Colors.grey),
                                  fontSize: 14,
                                ),
                              ),
                              Text(
                                "50%",
                                style: GoogleFonts.poppins(
                                  color: Theme.of(context).extension<AppThemeExtension>()!.success,
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(20),
                            child: LinearProgressIndicator(
                              value: 0.5,
                              minHeight: 8,
                              backgroundColor: Colors.white12,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                Theme.of(context).extension<AppThemeExtension>()!.success,
                              ),
                            ),
                          ),
                          const SizedBox(height: 18),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                "Tap to view full plan",
                                style: GoogleFonts.poppins(
                                  color: (Theme.of(context).textTheme.bodyMedium?.color ?? Colors.grey).withOpacity(0.7),
                                  fontSize: 13,
                                ),
                              ),
                              const Icon(
                                Icons.arrow_forward_ios_rounded,
                                color: Colors.white38,
                                size: 14,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ).animate().fade(delay: 500.ms, duration: 500.ms).slideY(begin: 0.1, end: 0, curve: Curves.easeOutQuad),
                const SizedBox(height: 120),
              ],
            ),
          ),
        ],
      ),

      // ================= BOTTOM NAV =================
      bottomNavigationBar: BottomNavbar(
        currentIndex: currentIndex,
        onTap: (index) {
          setState(() {
            currentIndex = index;
          });

          if (index == 0) {
            Navigator.pushNamed(
              context,
              "/dashboard",
            );
          } else if (index == 1) {
            Navigator.pushNamed(
              context,
              "/skill-analyzer",
            );
          } else if (index == 2) {
            Navigator.pushNamed(
              context,
              "/resume-review",
            );
          } else if (index == 3) {
            Navigator.pushNamed(
              context,
              "/mock-interview",
            );
          } else if (index == 4) {
            Navigator.pushNamed(
              context,
              "/jd-match",
            );
          }
        },
      ),
    );
  }
}
