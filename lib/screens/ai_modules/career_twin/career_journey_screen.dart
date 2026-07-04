import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';

import '../../../widgets/animations/three_d_tilt_wrapper.dart';
import '../../../widgets/common/glass_container.dart';
import '../../../services/career_journey_service.dart';
import 'skill_stage_detail_screen.dart';
import 'skill_history_screen.dart';

class JourneyStageDef {
  final String title;
  final String subtitle;
  final int levelIndex;
  final IconData icon;
  final Color color;

  JourneyStageDef(this.title, this.subtitle, this.levelIndex, this.icon, this.color);
}

class CareerJourneyScreen extends StatefulWidget {
  const CareerJourneyScreen({super.key});

  @override
  State<CareerJourneyScreen> createState() => _CareerJourneyScreenState();
}

class _CareerJourneyScreenState extends State<CareerJourneyScreen> {
  final TextEditingController _skillController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  final List<JourneyStageDef> stages = [
    JourneyStageDef("Beginner", "Grasping the basics", 0, Icons.school_rounded, Colors.greenAccent),
    JourneyStageDef("Intermediate", "Learning core concepts", 1, Icons.trending_up_rounded, Colors.orangeAccent),
    JourneyStageDef("Advanced", "Building projects", 2, Icons.business_center_rounded, Colors.amber),
    JourneyStageDef("Expert", "Master of domain", 3, Icons.psychology_rounded, Colors.redAccent),
    JourneyStageDef("Job Ready", "Interview prep", 4, Icons.handshake_rounded, Colors.tealAccent),
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollToCurrentStage();
      // Update last active
      Provider.of<CareerJourneyService>(context, listen: false).updateLastActive();
    });
  }

  void _scrollToCurrentStage() {
    final service = Provider.of<CareerJourneyService>(context, listen: false);
    if (service.activeSkill != null && _scrollController.hasClients) {
      double offset = service.activeSkill!.currentLevelIndex * 120.0;
      _scrollController.animateTo(
        offset,
        duration: const Duration(milliseconds: 1000),
        curve: Curves.easeInOut,
      );
    }
  }

  void _startNewSkillDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1E1E2C),
        title: Text("Start New Skill", style: GoogleFonts.poppins(color: Colors.white)),
        content: TextField(
          controller: _skillController,
          style: const TextStyle(color: Colors.white),
          decoration: InputDecoration(
            hintText: "e.g., Python, Flutter, UX Design",
            hintStyle: TextStyle(color: Colors.white.withOpacity(0.5)),
            filled: true,
            fillColor: Colors.black26,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel", style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Theme.of(context).primaryColor),
            onPressed: () {
              if (_skillController.text.trim().isNotEmpty) {
                Provider.of<CareerJourneyService>(context, listen: false).startNewSkill(_skillController.text.trim());
                _skillController.clear();
                Navigator.pop(context);
              }
            },
            child: const Text("Start", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<CareerJourneyService>(
      builder: (context, journeyService, child) {
        final activeSkill = journeyService.activeSkill;

        return Scaffold(
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            iconTheme: const IconThemeData(color: Colors.white),
            title: Text(
              "Skill Journey",
              style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 20),
            ),
            centerTitle: true,
            actions: [
              IconButton(
                icon: const Icon(Icons.history_rounded),
                onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const SkillHistoryScreen())),
              ),
            ],
          ),
          body: Stack(
            alignment: Alignment.center,
            children: [
              Positioned(
                top: 100,
                child: Container(
                  width: 400,
                  height: 600,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Theme.of(context).primaryColor.withOpacity(0.05),
                        blurRadius: 150,
                      ),
                    ],
                  ),
                ),
              ),

              if (activeSkill == null)
                Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.route_rounded, size: 80, color: Colors.white24),
                      const SizedBox(height: 20),
                      Text(
                        "No Active Journey",
                        style: GoogleFonts.poppins(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        "Pick a skill to start mastering it step-by-step.",
                        style: GoogleFonts.poppins(color: Colors.white60, fontSize: 14),
                      ),
                      const SizedBox(height: 30),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                          backgroundColor: Theme.of(context).primaryColor,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                        ),
                        onPressed: _startNewSkillDialog,
                        child: Text("Start a Skill", style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.bold)),
                      ).animate().shimmer(duration: 2.seconds, curve: Curves.easeInOut),
                    ],
                  ),
                )
              else
                Column(
                  children: [
                    // Active Skill Header
                    Padding(
                      padding: const EdgeInsets.all(20),
                      child: GlassContainer(
                        padding: const EdgeInsets.all(20),
                        borderRadius: BorderRadius.circular(24),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "Learning",
                                  style: GoogleFonts.poppins(color: Colors.white54, fontSize: 12),
                                ),
                                Text(
                                  activeSkill.skillName,
                                  style: GoogleFonts.poppins(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
                                ),
                              ],
                            ),
                            IconButton(
                              icon: const Icon(Icons.swap_horiz_rounded, color: Colors.white70),
                              onPressed: _startNewSkillDialog,
                              tooltip: "Switch Skill",
                            ),
                          ],
                        ),
                      ),
                    ).animate().slideY(begin: -0.2),

                    // Timeline
                    Expanded(
                      child: ListView.builder(
                        controller: _scrollController,
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                        itemCount: stages.length,
                        itemBuilder: (context, index) {
                          final stage = stages[index];
                          final isUnlocked = activeSkill.currentLevelIndex >= stage.levelIndex;
                          final isCurrent = activeSkill.currentLevelIndex == stage.levelIndex;
                          final isLast = index == stages.length - 1;

                          return GestureDetector(
                            onTap: () {
                              if (isUnlocked) {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => SkillStageDetailScreen(
                                      skillName: activeSkill.skillName,
                                      levelIndex: stage.levelIndex,
                                      stageName: stage.title,
                                      isCompleted: activeSkill.currentLevelIndex > stage.levelIndex,
                                    ),
                                  ),
                                );
                              } else {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text("Complete previous stages to unlock!")),
                                );
                              }
                            },
                            child: Column(
                              children: [
                                Row(
                                  children: [
                                    // Node
                                    Container(
                                      width: 50,
                                      height: 50,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: isUnlocked ? stage.color.withOpacity(0.2) : Colors.white.withOpacity(0.05),
                                        border: Border.all(
                                          color: isUnlocked ? stage.color : Colors.white24,
                                          width: isCurrent ? 3 : 1,
                                        ),
                                        boxShadow: isCurrent ? [
                                          BoxShadow(color: stage.color.withOpacity(0.5), blurRadius: 10, spreadRadius: 2)
                                        ] : [],
                                      ),
                                      child: Icon(
                                        isUnlocked ? stage.icon : Icons.lock_rounded,
                                        color: isUnlocked ? stage.color : Colors.white38,
                                        size: 24,
                                      ),
                                    ),
                                    const SizedBox(width: 20),
                                    
                                    // Card
                                    Expanded(
                                      child: ThreeDTiltWrapper(
                                        child: GlassContainer(
                                          padding: const EdgeInsets.all(16),
                                          borderRadius: BorderRadius.circular(20),
                                          opacity: isUnlocked ? 0.1 : 0.02,
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Row(
                                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                children: [
                                                  Text(
                                                    stage.title,
                                                    style: GoogleFonts.poppins(
                                                      color: isUnlocked ? Colors.white : Colors.white38,
                                                      fontSize: 18,
                                                      fontWeight: FontWeight.bold,
                                                    ),
                                                  ),
                                                  if (isCurrent)
                                                    Container(
                                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                                      decoration: BoxDecoration(
                                                        color: stage.color.withOpacity(0.2),
                                                        borderRadius: BorderRadius.circular(10),
                                                      ),
                                                      child: Text(
                                                        "Active",
                                                        style: GoogleFonts.poppins(color: stage.color, fontSize: 12, fontWeight: FontWeight.bold),
                                                      ),
                                                    ),
                                                  if (activeSkill.currentLevelIndex > stage.levelIndex)
                                                    const Icon(Icons.check_circle_rounded, color: Colors.greenAccent, size: 20)
                                                ],
                                              ),
                                              const SizedBox(height: 4),
                                              Text(
                                                stage.subtitle,
                                                style: GoogleFonts.poppins(
                                                  color: isUnlocked ? Colors.white70 : Colors.white24,
                                                  fontSize: 13,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ).animate().fade(delay: (index * 100).ms).slideX(begin: 0.1),
                                  ],
                                ),
                                if (!isLast)
                                  Container(
                                    width: 4,
                                    height: 40,
                                    margin: const EdgeInsets.only(right: 280),
                                    decoration: BoxDecoration(
                                      color: isUnlocked && activeSkill.currentLevelIndex > index 
                                          ? stage.color 
                                          : Colors.white12,
                                    ),
                                  ),
                              ],
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
            ],
          ),
        );
      },
    );
  }
}
