import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:share_plus/share_plus.dart';
import 'package:cached_network_image/cached_network_image.dart';

import '../../constants/app_colors.dart';
import 'edit_profile_screen.dart';
import 'module_detail_screen.dart';
import '../../widgets/common/glass_container.dart';
import '../../widgets/common/primary_button.dart';
import '../../widgets/common/premium_detail_modal.dart';
import '../../services/theme_service.dart';
import 'package:ai_careerpilot/config/app_theme_extension.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final user = FirebaseAuth.instance.currentUser;
  Map<String, dynamic>? userData;
  bool loading = true;

  @override
  void initState() {
    super.initState();
    fetchUser();
  }

  Future<void> fetchUser() async {
    try {
      if (user == null) {
        setState(() => loading = false);
        return;
      }
      final doc = await FirebaseFirestore.instance
          .collection("users")
          .doc(user!.uid)
          .get();

      setState(() {
        userData = doc.data();
        loading = false;
      });
    } catch (e) {
      setState(() => loading = false);
    }
  }

  // ================= ACTION HANDLERS =================

  void _showResumeScoreStats() {
    PremiumDetailModal.show(
      context: context,
      title: "Resume Score Analytics",
      icon: Icons.description_outlined,
      color: const Color(0xFF10B981),
      subtitle: "Detailed breakdown of your resume.",
      children: [
        FutureBuilder<QuerySnapshot>(
          future: FirebaseFirestore.instance
              .collection('resume_reports')
              .where('userId', isEqualTo: user?.uid)
              .orderBy('timestamp', descending: true)
              .limit(1)
              .get(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            if (snapshot.hasError || !snapshot.hasData || snapshot.data!.docs.isEmpty) {
              return const Center(
                child: Text("No resume analysis found. Run a scan!"),
              );
            }
            final data = snapshot.data!.docs.first.data() as Map<String, dynamic>;
            final overallScore = data['overallScore'] ?? '0';
            
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                PremiumDetailModal.statRow(context, "Overall Score", "$overallScore/100", valueColor: const Color(0xFF10B981)),
                const Divider(color: Colors.white12),
                PremiumDetailModal.statRow(context, "Formatting", "Excellent"),
                PremiumDetailModal.statRow(context, "Keywords", "Good"),
                PremiumDetailModal.statRow(context, "Action Verbs", "Needs Improvement", valueColor: Colors.orange),
              ],
            );
          },
        ),
      ],
      primaryActionText: "Analyze New Resume",
      onPrimaryAction: () {
        Navigator.pop(context);
        Navigator.pushNamed(context, "/resume-review");
      },
    );
  }

  void _showATSScoreStats() {
    PremiumDetailModal.show(
      context: context,
      title: "ATS Compatibility",
      icon: Icons.verified_user_outlined,
      color: const Color(0xFF3B82F6),
      subtitle: "How well bots read your resume.",
      children: [
                PremiumDetailModal.statRow(context, "ATS Passthrough Rate", "92%", valueColor: const Color(0xFF3B82F6)),
        const Divider(color: Colors.white12),
        PremiumDetailModal.listItem(context, Icons.check_circle_outline, "File Format", "PDF detected, standard fonts used.", Colors.green),
        PremiumDetailModal.listItem(context, Icons.warning_amber_rounded, "Complex Tables", "Avoid using nested tables for layout.", Colors.orange),
      ],
    );
  }

  void _showSkillsList() {
    final skills = (userData?["skills"] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? [];
    PremiumDetailModal.show(
      context: context,
      title: "Detected Skills",
      icon: Icons.code_rounded,
      color: const Color(0xFFF59E0B),
      subtitle: "Skills parsed from your profile & resume.",
      children: [
        if (skills.isEmpty)
          const Text("No skills detected. Please update your profile.", style: TextStyle(color: Colors.white54))
        else
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: skills.map((s) => Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: const Color(0xFFF59E0B).withOpacity(0.1),
                border: Border.all(color: const Color(0xFFF59E0B).withOpacity(0.3)),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(s, style: const TextStyle(color: Colors.white, fontSize: 13)),
            )).toList(),
          ),
      ],
      primaryActionText: "Add More Skills",
      onPrimaryAction: () {
        Navigator.pop(context);
        Navigator.push(context, MaterialPageRoute(builder: (_) => const EditProfileScreen())).then((_) => fetchUser());
      },
    );
  }

  void _showRoadmapsCompleted() {
    PremiumDetailModal.show(
      context: context,
      title: "Learning Paths",
      icon: Icons.map_outlined,
      color: const Color(0xFF8B5CF6),
      subtitle: "Your generated roadmaps.",
      children: [
        FutureBuilder<QuerySnapshot>(
          future: FirebaseFirestore.instance
              .collection('roadmaps')
              .where('userId', isEqualTo: user?.uid)
              .get(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            if (snapshot.hasError || !snapshot.hasData || snapshot.data!.docs.isEmpty) {
              return const Center(child: Text("No roadmaps generated yet."));
            }
            return Column(
              children: snapshot.data!.docs.map((doc) {
                final data = doc.data() as Map<String, dynamic>;
                return PremiumDetailModal.listItem(
                  context,
                  Icons.route_outlined,
                  data['role'] ?? 'Role specific roadmap',
                  "Generated on: ${DateTime.parse(data['timestamp'] ?? DateTime.now().toIso8601String()).toString().split(' ')[0]}",
                  const Color(0xFF8B5CF6),
                );
              }).toList(),
            );
          },
        ),
      ],
    );
  }

  void _openModuleDetail(String title, String desc, IconData icon, Color color, List<String> features, List<String> workflow, String benefit) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ModuleDetailScreen(
          title: title,
          description: desc,
          icon: icon,
          color: color,
          features: features,
          workflow: workflow,
          benefit: benefit,
        ),
      ),
    );
  }

  // ================= WIDGET BUILDERS =================

  Widget _sectionTitle(String title, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16, left: 4),
      child: Row(
        children: [
          Icon(icon, color: Theme.of(context).primaryColor, size: 20),
          const SizedBox(width: 8),
          Text(
            title,
            style: GoogleFonts.poppins(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCareerStats() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionTitle("Career Stats", Icons.bar_chart_rounded),
        GridView(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            mainAxisExtent: 120, // Fixes RenderFlex overflow
          ),
          children: [
            _statCard("Resume Score", "85%", Icons.description_outlined, const Color(0xFF10B981), _showResumeScoreStats),
            _statCard("ATS Score", "92%", Icons.verified_user_outlined, const Color(0xFF3B82F6), _showATSScoreStats),
            _statCard("Skills Detected", "${(userData?["skills"] as List?)?.length ?? 0}", Icons.code_rounded, const Color(0xFFF59E0B), _showSkillsList),
            _statCard("Roadmaps", "3", Icons.map_outlined, const Color(0xFF8B5CF6), _showRoadmapsCompleted),
            _statCard("Mock Interviews", "2", Icons.mic_none_rounded, const Color(0xFFEC4899), () {
              PremiumDetailModal.show(
                context: context,
                title: "Mock Interviews",
                icon: Icons.mic,
                color: const Color(0xFFEC4899),
                subtitle: "Your AI interview history.",
                children: [
                  FutureBuilder<QuerySnapshot>(
                    future: FirebaseFirestore.instance.collection('mock_interviews').where('userId', isEqualTo: user?.uid).get(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());
                      if (!snapshot.hasData || snapshot.data!.docs.isEmpty) return Center(child: Text("No interviews found.", style: TextStyle(color: Theme.of(context).textTheme.bodyLarge?.color)));
                      return Column(
                        children: snapshot.data!.docs.map((doc) {
                          final data = doc.data() as Map<String, dynamic>;
                          return PremiumDetailModal.listItem(
                            context,
                            Icons.mic,
                            data['topic'] ?? 'General Interview',
                            "Score: ${data['score'] ?? 'N/A'}/10",
                            const Color(0xFFEC4899),
                          );
                        }).toList(),
                      );
                    },
                  ),
                ],
              );
            }),
          ],
        ),
      ],
    ).animate().fade(duration: 400.ms).slideY(begin: 0.1, duration: 400.ms);
  }

  Widget _statCard(String title, String value, IconData icon, Color color, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: GlassContainer(
        padding: const EdgeInsets.all(16),
        opacity: Theme.of(context).brightness == Brightness.light ? 0.08 : 0.04,
        borderRadius: BorderRadius.circular(20),
        child: Material(
          color: Colors.transparent,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Icon(icon, color: color, size: 24),
                  Text(
                    value,
                    style: GoogleFonts.poppins(
                      color: color,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const Spacer(),
              Text(
                title,
                style: GoogleFonts.poppins(
                  color: Theme.of(context).textTheme.bodyMedium?.color,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAboutSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionTitle("About AI_CareerPilot", Icons.info_outline_rounded),
        GlassContainer(
          padding: const EdgeInsets.all(20),
          opacity: Theme.of(context).brightness == Brightness.light ? 0.08 : 0.04,
          borderRadius: BorderRadius.circular(24),
          child: Column(
            children: [
              _aboutItem(
                Icons.document_scanner_rounded, 
                "AI Resume Reviewer", 
                "Analyzes your resume to detect missing skills and ATS compatibility.",
                () => _openModuleDetail("AI Resume Reviewer", "Our flagship AI tool that reads your PDF and grades it.", Icons.document_scanner, const Color(0xFF10B981), ["ATS Parsing", "Keyword matching", "Formatting check"], ["Upload PDF", "AI Scans text", "Generates report"], "Boost interview chances by 40%"),
              ),
              const SizedBox(height: 16),
              _aboutItem(
                Icons.radar_rounded, 
                "Smart JD Match", 
                "Calculates compatibility against targeted Job Descriptions.",
                () => _openModuleDetail("Smart JD Match", "Compare your resume directly against a job posting.", Icons.radar, const Color(0xFF3B82F6), ["Semantic matching", "Gap analysis"], ["Paste JD", "AI compares", "Identifies missing skills"], "Stop guessing what recruiters want"),
              ),
              const SizedBox(height: 16),
              _aboutItem(
                Icons.route_rounded, 
                "AI Learning Path", 
                "Creates highly personalized learning roadmaps with curated resources.",
                () => _openModuleDetail("AI Learning Path", "Auto-generates day-by-day learning schedules.", Icons.route, const Color(0xFF8B5CF6), ["Custom milestones", "YouTube video links"], ["Input goal", "AI plans", "You execute"], "Learn exactly what matters"),
              ),
              const SizedBox(height: 16),
              _aboutItem(
                Icons.record_voice_over_rounded, 
                "AI Mock Interview", 
                "Provides realistic interview questions to help you practice and improve.",
                () => _openModuleDetail("AI Mock Interview", "Voice-enabled real-time interview simulator.", Icons.mic, const Color(0xFFF59E0B), ["Voice recognition", "Real-time grading"], ["Select topic", "Answer via mic", "Get feedback"], "Eliminate interview anxiety"),
              ),
            ],
          ),
        ),
      ],
    ).animate().fade(delay: 300.ms, duration: 400.ms).slideY(begin: 0.1, duration: 400.ms);
  }

  Widget _aboutItem(IconData icon, String title, String desc, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        color: Colors.transparent,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: Theme.of(context).primaryColor, size: 24),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.poppins(
                      color: Theme.of(context).textTheme.bodyLarge?.color,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    desc,
                    style: GoogleFonts.poppins(
                      color: Theme.of(context).textTheme.bodyMedium?.color,
                      fontSize: 12,
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),
            Icon(Icons.arrow_forward_ios_rounded, color: Theme.of(context).iconTheme.color?.withOpacity(0.3), size: 14),
          ],
        ),
      ),
    );
  }

  Widget _buildSettingsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionTitle("Settings & Help", Icons.settings_outlined),
        GlassContainer(
          padding: const EdgeInsets.symmetric(vertical: 8),
          opacity: Theme.of(context).brightness == Brightness.light ? 0.08 : 0.04,
          borderRadius: BorderRadius.circular(24),
          child: Material(
            color: Colors.transparent,
            child: Column(
              children: [
              _settingsTile(
                Theme.of(context).brightness == Brightness.light ? Icons.light_mode_outlined : Icons.dark_mode_outlined, 
                "Theme Settings", 
                () {
                  PremiumDetailModal.show(context: context, title: "Theme", icon: Icons.palette, color: Colors.blueAccent, subtitle: "Change app appearance.", children: [
                    Text("Toggle between Light and Dark mode globally.", style: TextStyle(color: Theme.of(context).textTheme.bodyMedium?.color)),
                  ], primaryActionText: "Toggle Theme", onPrimaryAction: () {
                    ThemeService().toggleTheme();
                    Navigator.pop(context);
                  });
                }
              ),
              const Divider(color: Colors.white12, height: 1),
              _settingsTile(Icons.notifications_active_outlined, "Notification Settings", () {
                PremiumDetailModal.show(context: context, title: "Notifications", icon: Icons.notifications, color: Colors.redAccent, subtitle: "Manage alerts.", children: [
                  PremiumDetailModal.listItem(context, Icons.check_circle, "Push Notifications", "Enabled", Colors.green),
                  PremiumDetailModal.listItem(context, Icons.check_circle, "Email Summaries", "Enabled", Colors.green),
                ]);
              }),
              const Divider(color: Colors.white12, height: 1),
              _settingsTile(Icons.privacy_tip_outlined, "Privacy Policy", () async {
                 await launchUrl(Uri.parse('https://policies.google.com/privacy'));
              }),
              const Divider(color: Colors.white12, height: 1),
              _settingsTile(Icons.support_agent_rounded, "Contact Support & Help", () {
                 PremiumDetailModal.show(context: context, title: "Support", icon: Icons.support_agent, color: Colors.cyan, subtitle: "We're here to help.", children: [
                  PremiumDetailModal.listItem(context, Icons.email, "Email Us", "support@careerpilot.ai", Colors.cyan),
                  PremiumDetailModal.listItem(context, Icons.bug_report, "Report Bug", "Found an issue? Let us know.", Colors.red),
                ]);
              }),
              const Divider(color: Colors.white12, height: 1),
              _settingsTile(Icons.share_outlined, "Share App", () {
                 Share.share("Check out AI_CareerPilot! An AI powered intelligent career mentor platform.");
              }),
              const Divider(color: Colors.white12, height: 1),
              ListTile(
                leading: Icon(Icons.info_outline_rounded, color: (Theme.of(context).textTheme.bodyMedium?.color ?? Colors.grey), size: 22),
                title: Text(
                  "App Version",
                  style: GoogleFonts.poppins(color: Theme.of(context).textTheme.bodyLarge?.color, fontSize: 14),
                ),
                trailing: Text(
                  "v1.0.0 (Production)",
                  style: GoogleFonts.poppins(color: (Theme.of(context).textTheme.bodyMedium?.color ?? Colors.grey), fontSize: 13),
                ),
              ),
            ],
          ),
        ),
      ),
      ],
    ).animate().fade(delay: 400.ms, duration: 400.ms).slideY(begin: 0.1, duration: 400.ms);
  }

  Widget _settingsTile(IconData icon, String title, VoidCallback onTap) {
    return ListTile(
      leading: Icon(icon, color: (Theme.of(context).textTheme.bodyMedium?.color ?? Colors.grey), size: 22),
      title: Text(
        title,
        style: GoogleFonts.poppins(color: Theme.of(context).textTheme.bodyLarge?.color, fontSize: 14, fontWeight: FontWeight.w500),
      ),
      trailing: Icon(Icons.chevron_right_rounded, color: Theme.of(context).iconTheme.color?.withOpacity(0.3), size: 20),
      onTap: onTap,
    );
  }

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        body: Center(
          child: CircularProgressIndicator(color: Theme.of(context).primaryColor),
        ),
      );
    }

    final name = userData?["name"] ?? "User";
    final email = userData?["email"] ?? "";
    final photo = userData?["profileImage"] ?? "";
    final careerGoal = userData?["careerGoal"] ?? "Not Set";

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        title: Text(
          "My Profile",
          style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_outlined, color: Colors.white70),
            onPressed: () async {
              await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const EditProfileScreen(),
                ),
              );
              fetchUser();
            },
          )
        ],
      ),
      body: Stack(
        children: [
          Positioned(
            top: 40,
            left: -100,
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(color: Theme.of(context).primaryColor.withOpacity(0.06), blurRadius: 110),
                ],
              ),
            ),
          ),
          
          SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ================= HEADER CARD =================
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    gradient: Theme.of(context).extension<AppThemeExtension>()!.primaryGradient,
                    borderRadius: BorderRadius.circular(28),
                    boxShadow: [
                      BoxShadow(color: Theme.of(context).primaryColor.withOpacity(0.25), blurRadius: 20, offset: const Offset(0, 8)),
                    ],
                  ),
                  child: Row(
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white.withOpacity(0.8), width: 2.5),
                        ),
                        child: CircleAvatar(
                          radius: 36,
                          backgroundColor: Colors.white12,
                          backgroundImage: photo.isNotEmpty ? CachedNetworkImageProvider(photo) : null,
                          child: photo.isEmpty ? const Icon(Icons.person_rounded, size: 38, color: Colors.white) : null,
                        ),
                      ),
                      const SizedBox(width: 20),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(name, style: GoogleFonts.poppins(fontSize: 22, color: Colors.white, fontWeight: FontWeight.bold)),
                            const SizedBox(height: 4),
                            Text(email, style: GoogleFonts.poppins(color: Colors.white.withOpacity(0.85), fontSize: 13)),
                            const SizedBox(height: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), borderRadius: BorderRadius.circular(12)),
                              child: Text(
                                "Goal: $careerGoal",
                                style: GoogleFonts.poppins(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w600),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ).animate().fade(duration: 400.ms).slideY(begin: -0.05, duration: 400.ms),

                const SizedBox(height: 32),
                _buildCareerStats(),
                const SizedBox(height: 32),

                _buildAboutSection(),
                const SizedBox(height: 32),
                _buildSettingsSection(),
                const SizedBox(height: 40),

                PrimaryButton(
                  text: "Logout",
                  gradient: const LinearGradient(colors: [Color(0xFFEF4444), Color(0xFFDC2626)]),
                  onPressed: () async {
                    await FirebaseAuth.instance.signOut();
                    if (!context.mounted) return;
                    Navigator.pushReplacementNamed(context, "/login");
                  },
                ).animate().fade(delay: 500.ms, duration: 400.ms),
                const SizedBox(height: 30),
              ],
            ),
          ),
        ],
      ),
    );
  }
}