import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import '../../../widgets/common/glass_container.dart';
import '../../../services/groq_service.dart';
import 'package:url_launcher/url_launcher.dart';
import 'stage_quiz_screen.dart';

class SkillStageDetailScreen extends StatefulWidget {
  final String skillName;
  final int levelIndex;
  final String stageName;
  final bool isCompleted;

  const SkillStageDetailScreen({
    super.key, 
    required this.skillName, 
    required this.levelIndex,
    required this.stageName,
    required this.isCompleted,
  });

  @override
  State<SkillStageDetailScreen> createState() => _SkillStageDetailScreenState();
}

class _SkillStageDetailScreenState extends State<SkillStageDetailScreen> {
  bool _isLoading = true;
  String _resourcesMarkdown = "";

  @override
  void initState() {
    super.initState();
    _loadResources();
  }

  Future<void> _loadResources() async {
    final response = await GroqService().generateStageResources(widget.skillName, widget.levelIndex);
    if (mounted) {
      setState(() {
        _resourcesMarkdown = response;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        title: Text(
          "🌟 ${widget.skillName} | ${widget.stageName}",
          style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: Colors.white))
          : Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  Expanded(
                    child: GlassContainer(
                      padding: const EdgeInsets.all(20),
                      borderRadius: BorderRadius.circular(20),
                      child: Markdown(
                        data: _resourcesMarkdown,
                        onTapLink: (text, href, title) async {
                          if (href != null) {
                            final url = Uri.parse(href);
                            if (await canLaunchUrl(url)) {
                              await launchUrl(url, mode: LaunchMode.externalApplication);
                            }
                          }
                        },
                        styleSheet: MarkdownStyleSheet(
                          p: GoogleFonts.poppins(color: Colors.white70, fontSize: 14),
                          h1: GoogleFonts.poppins(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold),
                          h2: GoogleFonts.poppins(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                          h3: GoogleFonts.poppins(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                          listBullet: const TextStyle(color: Colors.white),
                        ),
                      ),
                    ),
                  ).animate().fade().slideY(begin: 0.1),
                  
                  const SizedBox(height: 20),

                  if (!widget.isCompleted)
                    SizedBox(
                      width: double.infinity,
                      height: 55,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Theme.of(context).primaryColor,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        ),
                        onPressed: () {
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              builder: (_) => StageQuizScreen(
                                skillName: widget.skillName,
                                levelIndex: widget.levelIndex,
                                stageName: widget.stageName,
                              ),
                            ),
                          );
                        },
                        child: Text(
                          "Take Knowledge Quiz",
                          style: GoogleFonts.poppins(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ).animate().scale(delay: 500.ms)
                  else
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(15),
                      decoration: BoxDecoration(
                        color: Colors.greenAccent.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: Colors.greenAccent),
                      ),
                      child: Center(
                        child: Text(
                          "Stage Completed 🎉",
                          style: GoogleFonts.poppins(color: Colors.greenAccent, fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                      ),
                    ),
                ],
              ),
            ),
    );
  }
}
