import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:syncfusion_flutter_pdf/pdf.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../services/jd_advanced_boolean_ats.dart';
import '../../widgets/common/primary_button.dart';
import '../../widgets/common/glass_container.dart';
import 'package:ai_careerpilot/config/app_theme_extension.dart';

class JDMatchScreen extends StatefulWidget {
  const JDMatchScreen({super.key});

  @override
  State<JDMatchScreen> createState() => _JDMatchScreenState();
}

class _JDMatchScreenState extends State<JDMatchScreen> {
  final TextEditingController jdController = TextEditingController();

  String uploadedResumeName = "";
  String resumeText = "";

  List<String> matchedSkills = [];
  List<String> missingSkills = [];

  int matchScore = 0;

  String resumeStrength = "";
  String suggestions = "";
  String eligibleRoles = "";
  String resumeSummary = "";
  String detectedRole = "";

  bool loading = false;

  // =====================================================
  // UPLOAD RESUME
  // =====================================================

  Future<void> uploadResume() async {
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
        extractedText =
            await extractPdfTextFromBytes(pickedFile.bytes!);
      } else if (pickedFile.extension == "txt") {
        extractedText = kIsWeb
            ? String.fromCharCodes(pickedFile.bytes!)
            : await File(pickedFile.path!).readAsString();
      }

      setState(() {
        uploadedResumeName = fileName;
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

  // =====================================================
  // PDF TEXT EXTRACT
  // =====================================================

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

  // =====================================================
  // ANALYZE (ADVANCED BOOLEAN ATS ONLY)
  // =====================================================

  void analyze() {
    if (resumeText.trim().isEmpty ||
        jdController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Upload resume & paste JD first", style: GoogleFonts.poppins()),
          backgroundColor: Theme.of(context).colorScheme.error,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    setState(() => loading = true);

    final advancedResult = JDAdvancedBooleanATS.analyze(
      resumeText: resumeText,
      jdText: jdController.text,
    );

    setState(() {
      matchScore = advancedResult["matchScore"];
      matchedSkills =
          List<String>.from(advancedResult["matchedSkills"]);
      missingSkills =
          List<String>.from(advancedResult["missingSkills"]);
      detectedRole = advancedResult["detectedRole"];
      resumeStrength = advancedResult["resumeStrength"];
      eligibleRoles =
          (advancedResult["eligibleRoles"] as List).join("\n• ");
      suggestions =
          (advancedResult["resumeOptimizationTips"] as List)
              .join("\n• ");
      resumeSummary = advancedResult["resumeSummary"];
      loading = false;
    });
  }

  // =====================================================
  // UI CARD
  // =====================================================

  Widget card(String title, String value) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      child: GlassContainer(
        width: double.infinity,
        padding: const EdgeInsets.all(18),
        opacity: 0.04,
        borderRadius: BorderRadius.circular(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: GoogleFonts.poppins(
                color: Theme.of(context).primaryColor,
                fontSize: 13,
                fontWeight: FontWeight.bold,
                letterSpacing: 0.5,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              value,
              style: GoogleFonts.poppins(
                color: Colors.white,
                fontSize: 14,
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // =====================================================
  // UI
  // =====================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          "Smart JD Matcher",
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
                    color: Theme.of(context).primaryColor.withValues(alpha: 0.06),
                    blurRadius: 110,
                  ),
                ],
              ),
            ),
          ),
          Positioned(
            bottom: -50,
            left: -100,
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Theme.of(context).colorScheme.secondary.withValues(alpha: 0.05),
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
                        "Smart JD Resume Matcher 🎯",
                        style: GoogleFonts.poppins(
                          color: Colors.white,
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        "Analyze how compatible your resume is with any target Job Description instantly using boolean ATS checks.",
                        style: GoogleFonts.poppins(
                          color: Colors.white.withValues(alpha: 0.85),
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 25),

                // ================= UPLOAD AREA =================
                GestureDetector(
                  onTap: uploadResume,
                  child: Container(
                    width: double.infinity,
                    height: 120,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.02),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: Theme.of(context).primaryColor.withValues(alpha: 0.4),
                        width: 1.5,
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
                            uploadedResumeName.isEmpty
                                ? "Upload Resume (PDF, TXT)"
                                : uploadedResumeName,
                            style: GoogleFonts.poppins(
                              color: uploadedResumeName.isEmpty ? (Theme.of(context).textTheme.bodyMedium?.color ?? Colors.grey) : Colors.white,
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

                // ================= JOB DESCRIPTION =================
                Text(
                  "Job Description",
                  style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 10),
                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(18),
                    color: const Color(0xFF0C101B),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.08),
                    ),
                  ),
                  child: TextField(
                    controller: jdController,
                    maxLines: 8,
                    style: GoogleFonts.poppins(color: Colors.white, fontSize: 14),
                    decoration: InputDecoration(
                      hintText: "Paste Job Description Here...",
                      hintStyle: GoogleFonts.poppins(color: Colors.white24, fontSize: 13),
                      contentPadding: const EdgeInsets.all(18),
                      border: InputBorder.none,
                    ),
                  ),
                ),

                const SizedBox(height: 24),

                // ================= ANALYZE BUTTON =================
                PrimaryButton(
                  text: "Analyze Match Score",
                  isLoading: loading,
                  onPressed: analyze,
                  gradient: Theme.of(context).extension<AppThemeExtension>()!.primaryGradient,
                ),

                const SizedBox(height: 30),

                // ================= RESULTS PANEL =================
                if (!loading && matchScore > 0) ...[
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
                            color: (matchScore >= 70 ? Theme.of(context).extension<AppThemeExtension>()!.success : Theme.of(context).extension<AppThemeExtension>()!.warning).withValues(alpha: 0.1),
                            border: Border.all(
                              color: (matchScore >= 70 ? Theme.of(context).extension<AppThemeExtension>()!.success : Theme.of(context).extension<AppThemeExtension>()!.warning),
                              width: 2.0,
                            ),
                          ),
                          child: Center(
                            child: Text(
                              "$matchScore%",
                              style: GoogleFonts.poppins(
                                color: (matchScore >= 70 ? Theme.of(context).extension<AppThemeExtension>()!.success : Theme.of(context).extension<AppThemeExtension>()!.warning),
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          matchScore >= 70 ? "Strong Fit Candidate ✅" : "Needs Optimization ❌",
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

                  card("Detected Role", detectedRole),
                  card("Resume Strength Summary", resumeStrength),
                  card("Matched Skills in JD", matchedSkills.isEmpty ? "None" : matchedSkills.join(", ")),
                  card("Missing Skills from JD", missingSkills.isEmpty ? "None" : missingSkills.join(", ")),
                  card("Alternative Eligible Roles", eligibleRoles),
                  card("Resume Optimization Suggestions", suggestions),
                  card("ATS Summary", resumeSummary),
                ]
              ],
            ),
          ),
        ],
      ),
    );
  }
}
