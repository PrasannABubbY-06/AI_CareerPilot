import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:syncfusion_flutter_pdf/pdf.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../constants/app_colors.dart';
import '../../services/groq_service.dart';
import '../../widgets/common/custom_textfield.dart';
import '../../widgets/common/primary_button.dart';
import '../../widgets/common/glass_container.dart';
import 'package:ai_careerpilot/config/app_theme_extension.dart';

class ResumeReviewerScreen extends StatefulWidget {
  const ResumeReviewerScreen({super.key});

  @override
  State<ResumeReviewerScreen> createState() => _ResumeReviewerScreenState();
}

class _ResumeReviewerScreenState extends State<ResumeReviewerScreen> {
  // ================= CONTROLLERS =================
  final TextEditingController roleController = TextEditingController();
  final TextEditingController interestController = TextEditingController();

  final GroqService groqAPI = GroqService();

  String aiRoadmap = "";
  String aiResumeSuggestions = "";

  // ================= STATES =================
  bool isLoading = false;
  String uploadedFileName = "";
  String resumeText = "";
  List<String> detectedSkills = [];
  List<String> missingSkills = [];
  List<String> recommendedJobs = [];
  bool atsFriendly = false;
  int resumeScore = 0;

  // ================= MASTER SKILLS =================
  final List<String> allSkills = [
    "Flutter",
    "Dart",
    "Firebase",
    "REST API",
    "Node.js",
    "React",
    "Python",
    "Java",
    "C",
    "JavaScript",
    "C++",
    "UI/UX",
    "Figma",
    "Git",
    "SQL",
    "MongoDB",
    "Machine Learning",
    "Data Structures",
    "full stack",
    "Problem Solving",
    "Communication",
    "Leadership",
    "Team Work",
  ];

  // ================= PICK RESUME =================
  Future<void> pickResume() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf', 'txt'],
        withData: true,
      );

      if (result == null) return;

      final pickedFile = result.files.first;
      final fileName = pickedFile.name;

      String extractedText = "";

      if (pickedFile.extension == "pdf") {
        extractedText = await extractPdfTextFromBytes(pickedFile.bytes!);
      } else if (pickedFile.extension == "txt") {
        extractedText = kIsWeb
            ? String.fromCharCodes(pickedFile.bytes!)
            : await File(pickedFile.path!).readAsString();
      }

      setState(() {
        uploadedFileName = fileName;
        resumeText = extractedText;
      });

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Resume uploaded successfully", style: GoogleFonts.poppins()),
          backgroundColor: Theme.of(context).extension<AppThemeExtension>()!.success,
          behavior: SnackBarBehavior.floating,
        ),
      );
    } catch (e) {
      debugPrint("UPLOAD ERROR: $e");
    }
  }

  // ================= PDF TEXT EXTRACT =================
  static String _extractPdfText(Uint8List bytes) {
    try {
      final document = PdfDocument(inputBytes: bytes);
      final text = PdfTextExtractor(document).extractText();
      document.dispose();
      return text;
    } catch (e) {
      return "";
    }
  }

  Future<String> extractPdfTextFromBytes(Uint8List bytes) async {
    return await compute(_extractPdfText, bytes);
  }

  // ================= ANALYZE =================
  Future<void> analyzeResume() async {
    if (resumeText.trim().isEmpty) {
      _showMsg("Please upload a valid resume file first");
      return;
    }

    if (roleController.text.trim().isEmpty) {
      _showMsg("Please enter target role");
      return;
    }

    setState(() {
      isLoading = true;
    });

    final resume = resumeText.toLowerCase();
    final targetRole = roleController.text.toLowerCase();
    final interests = interestController.text.toLowerCase().split(",");

    List<String> foundSkills = [];

    for (var skill in allSkills) {
      if (resume.contains(skill.toLowerCase())) {
        foundSkills.add(skill);
      }
    }

    Map<String, List<String>> roleSkills = {
      "flutter developer": ["Flutter", "Dart", "Firebase", "REST API", "Git", "UI/UX"],
      "frontend developer": ["React", "UI/UX", "Git", "Problem Solving"],
      "python developer": ["Python", "SQL", "Problem Solving"],
      "ml engineer": ["Python", "Machine Learning", "SQL", "Data Structures"],
      "backend developer": ["Node.js", "MongoDB", "REST API", "SQL"],
      "full stack": ["React", "UI/UX", "Git", "Problem Solving", "Node.js", "MongoDB", "REST API", "SQL"],
    };

    List<String> requiredSkills = [];

    roleSkills.forEach((role, skills) {
      if (targetRole.contains(role)) {
        requiredSkills = skills;
      }
    });

    if (requiredSkills.isEmpty) {
      requiredSkills = ["Communication", "Problem Solving", "Team Work"];
    }

    for (var item in interests) {
      String cleaned = item.trim().toLowerCase();
      for (var skill in allSkills) {
        if (skill.toLowerCase() == cleaned) {
          if (!requiredSkills.contains(skill)) {
            requiredSkills.add(skill);
          }
        }
      }
    }

    List<String> missing = [];
    for (var skill in requiredSkills) {
      if (!foundSkills.contains(skill)) {
        missing.add(skill);
      }
    }

    int matchedSkills = 0;
    for (var skill in requiredSkills) {
      if (foundSkills.contains(skill)) {
        matchedSkills++;
      }
    }

    int score = requiredSkills.isNotEmpty 
        ? ((matchedSkills / requiredSkills.length) * 100).toInt() 
        : 0;
        
    if (score > 100) score = 100;

    bool ats = resume.length > 100 && foundSkills.length >= 5;

    List<String> jobs = [];
    if (foundSkills.contains("Flutter") && foundSkills.contains("Firebase")) {
      jobs.add("Flutter Developer");
    }
    if (foundSkills.contains("React")) {
      jobs.add("Frontend Developer");
    }
    if (foundSkills.contains("React") && foundSkills.contains("Node.js")) {
      jobs.add("Full Stack Developer");
    }
    if (foundSkills.contains("Python")) {
      jobs.add("Python Developer");
    }
    if (foundSkills.contains("Machine Learning")) {
      jobs.add("ML Engineer");
    }
    if (foundSkills.contains("Node.js")) {
      jobs.add("Backend Developer");
    }
    if (jobs.isEmpty) {
      jobs.add("Improve skills to unlock jobs");
    }
    
    final results = await Future.wait([
      groqAPI.generateLearningRoadmap(missing),
      groqAPI.improveResume(
        resumeText,
        roleController.text,
      )
    ]);
    
    final roadmap = results[0];
    final resumeSuggestions = results[1];

    setState(() {
      detectedSkills = foundSkills;
      missingSkills = missing;
      atsFriendly = ats;
      recommendedJobs = jobs;
      aiRoadmap = roadmap;
      aiResumeSuggestions = resumeSuggestions;
      resumeScore = score;
      isLoading = false;
    });
  }

  void _showMsg(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg, style: GoogleFonts.poppins()),
        backgroundColor: Theme.of(context).colorScheme.error,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  Widget skillChip(String text, Color color) {
    return Container(
      margin: const EdgeInsets.only(right: 8, bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(30),
        border: Border.all(
          color: color.withOpacity(0.35),
          width: 1,
        ),
      ),
      child: Text(
        text,
        style: GoogleFonts.poppins(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          "AI Resume Reviewer",
          style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
        ),
      ),
      body: Stack(
        children: [
          // Background Glows
          Positioned(
            top: 40,
            right: -100,
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Theme.of(context).primaryColor.withOpacity(0.06),
                    blurRadius: 110,
                  ),
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
                // ================= HEADER =================
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(22),
                  decoration: BoxDecoration(
                    gradient: Theme.of(context).extension<AppThemeExtension>()!.primaryGradient,
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color: Theme.of(context).primaryColor.withOpacity(0.2),
                        blurRadius: 16,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Upload Resume & Analyze Career 🚀",
                        style: GoogleFonts.poppins(
                          color: Colors.white,
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        "AI analyzes your resume, target role, missing skills & job eligibility instantly.",
                        style: GoogleFonts.poppins(color: Colors.white.withOpacity(0.85), fontSize: 13),
                      ),
                    ],
                  ),
                ),
                
                const SizedBox(height: 25),

                // ================= DRAG & DROP DASHED CONTAINER =================
                GestureDetector(
                  onTap: pickResume,
                  child: Container(
                    width: double.infinity,
                    height: 120,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.02),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: Theme.of(context).primaryColor.withOpacity(0.4),
                        width: 1.5,
                        style: BorderStyle.solid, // Note: Flutter doesn't native dash easily without painter, solid is fine with lower opacity
                      ),
                    ),
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.cloud_upload_outlined,
                            color: Theme.of(context).primaryColor,
                            size: 32,
                          ).animate(onPlay: (controller) => controller.repeat(reverse: true))
                           .moveY(begin: -3, end: 3, duration: 1.seconds),
                          const SizedBox(height: 8),
                          Text(
                            uploadedFileName.isEmpty ? "Drag and drop or select resume file" : uploadedFileName,
                            style: GoogleFonts.poppins(
                              color: uploadedFileName.isEmpty ? (Theme.of(context).textTheme.bodyMedium?.color ?? Colors.grey) : Colors.white,
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                
                const SizedBox(height: 20),

                // ================= TARGET ROLE =================
                CustomTextField(
                  controller: roleController,
                  hintText: "Target Role (Ex: Frontend Developer, Flutter Developer)",
                  prefixIcon: Icons.work_outline_rounded,
                ),
                
                const SizedBox(height: 16),

                // ================= INTEREST =================
                CustomTextField(
                  controller: interestController,
                  hintText: "Interested Skills (Python, Flutter, Java...)",
                  prefixIcon: Icons.interests_outlined,
                ),
                
                const SizedBox(height: 16),

                // Paste UI section removed as per requirement

                // ================= ANALYZE BUTTON =================
                PrimaryButton(
                  text: "Analyze with AI",
                  isLoading: isLoading,
                  onPressed: analyzeResume,
                  gradient: Theme.of(context).extension<AppThemeExtension>()!.primaryGradient,
                ),
                
                const SizedBox(height: 25),

                // ================= RESULTS PANEL =================
                if (!isLoading && detectedSkills.isNotEmpty) ...[
                  // Score Panel GlassCard
                  GlassContainer(
                    width: double.infinity,
                    padding: const EdgeInsets.all(22),
                    opacity: 0.05,
                    borderRadius: BorderRadius.circular(24),
                    child: Column(
                      children: [
                        Container(
                          width: 80,
                          height: 80,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: (resumeScore >= 70 ? Theme.of(context).extension<AppThemeExtension>()!.success : Theme.of(context).extension<AppThemeExtension>()!.warning).withOpacity(0.1),
                            border: Border.all(
                              color: (resumeScore >= 70 ? Theme.of(context).extension<AppThemeExtension>()!.success : Theme.of(context).extension<AppThemeExtension>()!.warning),
                              width: 2.0,
                            ),
                          ),
                          child: Center(
                            child: Text(
                              "$resumeScore%",
                              style: GoogleFonts.poppins(
                                color: (resumeScore >= 70 ? Theme.of(context).extension<AppThemeExtension>()!.success : Theme.of(context).extension<AppThemeExtension>()!.warning),
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          atsFriendly ? "ATS Match Verified ✅" : "Needs Structural Improvements ❌",
                          style: GoogleFonts.poppins(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ).animate().fade(duration: 500.ms),
                  
                  const SizedBox(height: 24),

                  // Detected Skills
                  Text(
                    "Detected Skills",
                    style: GoogleFonts.poppins(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    children: detectedSkills.map((e) => skillChip(e, Theme.of(context).extension<AppThemeExtension>()!.success)).toList(),
                  ),
                  
                  const SizedBox(height: 24),

                  // Missing
                  Text(
                    "Missing Target Skills",
                    style: GoogleFonts.poppins(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    children: missingSkills.isEmpty 
                      ? <Widget>[skillChip("None! All matching" , Theme.of(context).primaryColor)] 
                      : missingSkills.map((e) => skillChip(e, AppColors.accentPink)).toList(),
                  ),
                  
                  const SizedBox(height: 24),

                  // Jobs Panel
                  Text(
                    "Eligible Job Roles Match",
                    style: GoogleFonts.poppins(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  Column(
                    children: recommendedJobs.map((job) {
                      return Container(
                        width: double.infinity,
                        margin: const EdgeInsets.only(bottom: 12),
                        padding: const EdgeInsets.all(18),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.03),
                          borderRadius: BorderRadius.circular(18),
                          border: Border.all(color: Colors.white.withOpacity(0.06)),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.work_rounded, color: Theme.of(context).primaryColor, size: 20),
                            const SizedBox(width: 14),
                            Text(
                              job, 
                              style: GoogleFonts.poppins(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w600)
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  ),
                  
                  const SizedBox(height: 24),

                  // AI Roadmap Content (Markdown Parsed)
                  Text(
                    "AI Learning Path",
                    style: GoogleFonts.poppins(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  GlassContainer(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    opacity: 0.04,
                    borderRadius: BorderRadius.circular(22),
                    child: MarkdownBody(
                      data: aiRoadmap,
                      onTapLink: (text, href, title) {
                        if (href != null) {
                          try {
                            final Uri url = Uri.parse(href);
                            launchUrl(url, mode: LaunchMode.externalApplication);
                          } catch (e) {
                            debugPrint("Could not launch $href");
                          }
                        }
                      },
                      styleSheet: MarkdownStyleSheet(
                        p: GoogleFonts.poppins(color: (Theme.of(context).textTheme.bodyMedium?.color ?? Colors.grey), height: 1.5, fontSize: 13.5),
                        h1: GoogleFonts.poppins(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
                        h2: GoogleFonts.poppins(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                        h3: GoogleFonts.poppins(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold),
                        listBullet: GoogleFonts.poppins(color: Theme.of(context).primaryColor),
                        a: GoogleFonts.poppins(color: Theme.of(context).primaryColor, decoration: TextDecoration.underline),
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 24),

                  // AI Suggestions Content (Markdown Parsed)
                  Text(
                    "AI Resume Suggestions",
                    style: GoogleFonts.poppins(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  GlassContainer(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    opacity: 0.04,
                    borderRadius: BorderRadius.circular(22),
                    child: MarkdownBody(
                      data: aiResumeSuggestions,
                      onTapLink: (text, href, title) {
                        if (href != null) {
                          try {
                            final Uri url = Uri.parse(href);
                            launchUrl(url, mode: LaunchMode.externalApplication);
                          } catch (e) {
                            debugPrint("Could not launch $href");
                          }
                        }
                      },
                      styleSheet: MarkdownStyleSheet(
                        p: GoogleFonts.poppins(color: (Theme.of(context).textTheme.bodyMedium?.color ?? Colors.grey), height: 1.5, fontSize: 13.5),
                        h1: GoogleFonts.poppins(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
                        h2: GoogleFonts.poppins(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                        listBullet: GoogleFonts.poppins(color: Theme.of(context).colorScheme.secondary),
                        a: GoogleFonts.poppins(color: Theme.of(context).primaryColor, decoration: TextDecoration.underline),
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 24),
                ]
              ],
            ),
          ),
        ],
      ),
    );
  }
}