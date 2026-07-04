import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../widgets/common/custom_textfield.dart';
import '../../widgets/common/glass_container.dart';
import '../../services/notification_service.dart';
import 'package:ai_careerpilot/config/app_theme_extension.dart';

class WeeklyGoalsScreen extends StatefulWidget {
  const WeeklyGoalsScreen({super.key});

  @override
  State<WeeklyGoalsScreen> createState() => _WeeklyGoalsScreenState();
}

class _WeeklyGoalsScreenState extends State<WeeklyGoalsScreen> {
  final TextEditingController taskController = TextEditingController();
  List<Map<String, dynamic>> goals = [];

  @override
  void initState() {
    super.initState();
    loadGoals();
  }

  Future<void> loadGoals() async {
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getString('weekly_goals');

    if (data != null) {
      setState(() {
        goals = List<Map<String, dynamic>>.from(jsonDecode(data));
      });
    }
  }

  Future<void> saveGoals() async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setString('weekly_goals', jsonEncode(goals));
  }

  void addTask() {
    if (taskController.text.trim().isEmpty) return;

    setState(() {
      goals.add({
        "title": taskController.text.trim(),
        "done": false,
      });
    });

    taskController.clear();
    saveGoals();
  }

  void toggleTask(int index) {
    setState(() {
      goals[index]["done"] = !goals[index]["done"];
    });
    saveGoals();
    
    if (goals[index]["done"] == true) {
      NotificationService().sendNotification(
        title: "Goal Completed! 🎉",
        message: 'You completed "${goals[index]["title"]}". Keep it up!',
        category: NotificationCategory.goalProgress,
      );
    }
  }

  void deleteTask(int index) {
    setState(() {
      goals.removeAt(index);
    });
    saveGoals();
  }

  @override
  Widget build(BuildContext context) {
    int completedGoals = goals.where((g) => g["done"]).length;
    double progress = goals.isEmpty ? 0 : completedGoals / goals.length;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          "Weekly Goals",
          style: GoogleFonts.poppins(fontWeight: FontWeight.bold, color: Theme.of(context).textTheme.bodyLarge?.color),
        ),
        iconTheme: Theme.of(context).iconTheme,
      ),
      body: Stack(
        children: [
          // Background Glows
          Positioned(
            top: 20,
            right: -100,
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Theme.of(context).primaryColor.withValues(alpha: 0.06),
                    blurRadius: 110,
                  ),
                ],
              ),
            ),
          ),

          Padding(
            padding: const EdgeInsets.all(18),
            child: Column(
              children: [
                // ================= TOP CARD =================
                ThreeDTiltWrapper(
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      gradient: Theme.of(context).extension<AppThemeExtension>()!.primaryGradient,
                      borderRadius: BorderRadius.circular(28),
                      boxShadow: [
                        BoxShadow(
                          color: Theme.of(context).primaryColor.withValues(alpha: 0.2),
                          blurRadius: 16,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "$completedGoals of ${goals.length} Completed",
                          style: GoogleFonts.poppins(
                            color: Colors.white,
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 16),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(20),
                          child: LinearProgressIndicator(
                            value: progress,
                            minHeight: 10,
                            backgroundColor: Colors.white24,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              Theme.of(context).extension<AppThemeExtension>()!.success,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ).animate().fade(duration: 450.ms),

                const SizedBox(height: 24),

                // ================= ADD TASK FIELD =================
                Row(
                  children: [
                    Expanded(
                      child: CustomTextField(
                        controller: taskController,
                        hintText: "Add a new weekly goal...",
                        prefixIcon: Icons.flag_outlined,
                      ),
                    ),
                    const SizedBox(width: 12),
                    GestureDetector(
                      onTap: addTask,
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          gradient: Theme.of(context).extension<AppThemeExtension>()!.primaryGradient,
                          borderRadius: BorderRadius.circular(18),
                          boxShadow: [
                            BoxShadow(
                              color: Theme.of(context).primaryColor.withValues(alpha: 0.3),
                              blurRadius: 12,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.add_rounded,
                          color: Colors.white,
                          size: 24,
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 24),

                // ================= TASK LIST =================
                Expanded(
                  child: goals.isEmpty
                      ? Center(
                          child: Text(
                            "No goals added for this week yet.",
                            style: GoogleFonts.poppins(
                              color: (Theme.of(context).textTheme.bodyMedium?.color ?? Colors.grey),
                              fontSize: 15,
                            ),
                          ),
                        )
                      : ListView.builder(
                          physics: const BouncingScrollPhysics(),
                          itemCount: goals.length,
                          itemBuilder: (context, index) {
                            final goal = goals[index];
                            final bool isDone = goal["done"];
                            return Container(
                              margin: const EdgeInsets.only(bottom: 14),
                              child: GlassContainer(
                                padding: const EdgeInsets.all(16),
                                opacity: isDone ? 0.02 : 0.05,
                                borderRadius: BorderRadius.circular(22),
                                border: Border.all(
                                  color: isDone
                                      ? Theme.of(context).extension<AppThemeExtension>()!.success.withValues(alpha: 0.2)
                                      : Colors.white.withValues(alpha: 0.08),
                                ),
                                child: Row(
                                  children: [
                                    GestureDetector(
                                      onTap: () => toggleTask(index),
                                      child: AnimatedContainer(
                                        duration: const Duration(milliseconds: 200),
                                        padding: const EdgeInsets.all(4),
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          color: isDone
                                              ? Theme.of(context).extension<AppThemeExtension>()!.success.withValues(alpha: 0.12)
                                              : Colors.white.withValues(alpha: 0.04),
                                          border: Border.all(
                                            color: isDone
                                                ? Theme.of(context).extension<AppThemeExtension>()!.success
                                                : Colors.white24,
                                            width: 1.5,
                                          ),
                                        ),
                                        child: Icon(
                                          isDone
                                              ? Icons.check_rounded
                                              : Icons.circle,
                                          color: isDone
                                              ? Theme.of(context).extension<AppThemeExtension>()!.success
                                              : Colors.transparent,
                                          size: 20,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 16),
                                    Expanded(
                                      child: Text(
                                        goal["title"],
                                        style: GoogleFonts.poppins(
                                          color: isDone
                                              ? Theme.of(context).textTheme.bodyMedium?.color?.withValues(alpha: 0.5)
                                              : Theme.of(context).textTheme.bodyLarge?.color,
                                          fontSize: 15,
                                          fontWeight: isDone ? FontWeight.w400 : FontWeight.w600,
                                          decoration: isDone
                                              ? TextDecoration.lineThrough
                                              : null,
                                        ),
                                      ),
                                    ),
                                    GestureDetector(
                                      onTap: () => deleteTask(index),
                                      child: Container(
                                        padding: const EdgeInsets.all(8),
                                        decoration: BoxDecoration(
                                          color: Theme.of(context).colorScheme.error.withValues(alpha: 0.08),
                                          shape: BoxShape.circle,
                                        ),
                                        child: Icon(
                                          Icons.delete_outline_rounded,
                                          color: Theme.of(context).colorScheme.error,
                                          size: 18,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ).animate().fade(duration: 350.ms).slideY(begin: 0.05, end: 0);
                          },
                        ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// Simple wrapper class definition inline if not imported
class ThreeDTiltWrapper extends StatelessWidget {
  final Widget child;
  const ThreeDTiltWrapper({super.key, required this.child});
  @override
  Widget build(BuildContext context) => child;
}
