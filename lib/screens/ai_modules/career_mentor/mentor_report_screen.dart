import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../widgets/common/glass_container.dart';
import '../../../config/app_theme_extension.dart';

class MentorReportScreen extends StatelessWidget {
  final String reportMarkdown;

  const MentorReportScreen({super.key, required this.reportMarkdown});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          "Your Career Report",
          style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: Stack(
        children: [
          // Background Glows
          Positioned(
            top: -100,
            right: -100,
            child: Container(
              width: 250,
              height: 250,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Theme.of(context).primaryColor.withValues(alpha: 0.12),
                    blurRadius: 120,
                  ),
                ],
              ),
            ),
          ),
          Positioned(
            bottom: 0,
            left: -100,
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Theme.of(context).extension<AppThemeExtension>()!.success.withValues(alpha: 0.08),
                    blurRadius: 150,
                  ),
                ],
              ),
            ),
          ),

          SafeArea(
            child: Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(20),
                    child: GlassContainer(
                      padding: const EdgeInsets.all(20),
                      child: MarkdownBody(
                        data: reportMarkdown,
                        styleSheet: MarkdownStyleSheet(
                          h1: GoogleFonts.poppins(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).primaryColor,
                          ),
                          h2: GoogleFonts.poppins(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).textTheme.bodyLarge?.color,
                          ),
                          h3: GoogleFonts.poppins(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Theme.of(context).extension<AppThemeExtension>()!.warning,
                          ),
                          p: GoogleFonts.poppins(
                            fontSize: 14,
                            color: Theme.of(context).textTheme.bodyMedium?.color?.withValues(alpha: 0.9),
                            height: 1.6,
                          ),
                          listBullet: TextStyle(
                            color: Theme.of(context).primaryColor,
                            fontSize: 18,
                          ),
                          a: GoogleFonts.poppins(
                            color: Theme.of(context).colorScheme.secondary,
                            fontWeight: FontWeight.w600,
                            decoration: TextDecoration.underline,
                          ),
                          blockquote: GoogleFonts.poppins(
                            fontStyle: FontStyle.italic,
                            color: Colors.grey,
                          ),
                          blockquoteDecoration: BoxDecoration(
                            border: Border(
                              left: BorderSide(color: Theme.of(context).primaryColor, width: 4),
                            ),
                          ),
                        ),
                        onTapLink: (text, href, title) async {
                          if (href != null) {
                            final url = Uri.parse(href);
                            if (await canLaunchUrl(url)) {
                              await launchUrl(url, mode: LaunchMode.externalApplication);
                            }
                          }
                        },
                      ),
                    ).animate().fade(duration: 600.ms).slideY(begin: 0.1, end: 0, curve: Curves.easeOutQuad),
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
