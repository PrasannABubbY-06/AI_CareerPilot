import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../models/analysis_model.dart';

class AnalysisResultScreen extends StatelessWidget {

  final AnalysisModel analysis;

  const AnalysisResultScreen({
    super.key,
    required this.analysis,
  });

  @override
  Widget build(BuildContext context) {

    return Scaffold(

      backgroundColor: const Color(0xff0B0F17),

      appBar: AppBar(
        backgroundColor: const Color(0xff11151F),
        elevation: 0,

        title: Text(
          "Analysis Result",
          style: GoogleFonts.poppins(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),

      body: SingleChildScrollView(

        padding: const EdgeInsets.all(24),

        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,

          children: [

            // =====================================================
            // ATS SCORE CARD
            // =====================================================

            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),

              decoration: BoxDecoration(
                color: const Color(0xff151922),
                borderRadius: BorderRadius.circular(24),
              ),

              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start,

                children: [

                  Text(
                    "ATS Score",
                    style: GoogleFonts.poppins(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 20),

                  Center(
                    child: Text(
                      "${analysis.atsScore}%",
                      style: GoogleFonts.poppins(
                        color: const Color(0xff5D8CFF),
                        fontSize: 60,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  ClipRRect(
                    borderRadius:
                        BorderRadius.circular(20),

                    child: LinearProgressIndicator(
                      value:
                          analysis.atsScore / 100,

                      minHeight: 16,

                      backgroundColor:
                          Colors.white12,

                      valueColor:
                          const AlwaysStoppedAnimation(
                        Color(0xff5D8CFF),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 30),

            // =====================================================
            // SKILLS SECTION
            // =====================================================

            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),

              decoration: BoxDecoration(
                color: const Color(0xff151922),
                borderRadius: BorderRadius.circular(24),
              ),

              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start,

                children: [

                  Text(
                    "Detected Skills",
                    style: GoogleFonts.poppins(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 20),

                  Wrap(
                    spacing: 12,
                    runSpacing: 12,

                    children:
                        analysis.skills.map((skill) {

                      return Container(
                        padding:
                            const EdgeInsets.symmetric(
                          horizontal: 18,
                          vertical: 12,
                        ),

                        decoration: BoxDecoration(
                          color:
                              const Color(0xff5D8CFF)
                                  .withOpacity(0.2),

                          borderRadius:
                              BorderRadius.circular(30),

                          border: Border.all(
                            color:
                                const Color(0xff5D8CFF),
                          ),
                        ),

                        child: Text(
                          skill,
                          style:
                              GoogleFonts.poppins(
                            color: Colors.white,
                            fontWeight:
                                FontWeight.w500,
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 30),

            // =====================================================
            // MISSING SKILLS
            // =====================================================

            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),

              decoration: BoxDecoration(
                color: const Color(0xff151922),
                borderRadius: BorderRadius.circular(24),
              ),

              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start,

                children: [

                  Text(
                    "Missing Skills",
                    style: GoogleFonts.poppins(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 20),

                  ...analysis.missingSkills.map((skill) {

                    return Padding(
                      padding:
                          const EdgeInsets.only(
                        bottom: 12,
                      ),

                      child: Row(
                        children: [

                          const Icon(
                            Icons.close,
                            color: Colors.red,
                          ),

                          const SizedBox(width: 10),

                          Text(
                            skill,
                            style:
                                GoogleFonts.poppins(
                              color: Colors.white70,
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                    );
                  }),
                ],
              ),
            ),

            const SizedBox(height: 30),

            // =====================================================
            // SUGGESTIONS
            // =====================================================

            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),

              decoration: BoxDecoration(
                color: const Color(0xff151922),
                borderRadius: BorderRadius.circular(24),
              ),

              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start,

                children: [

                  Text(
                    "AI Suggestions",
                    style: GoogleFonts.poppins(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 20),

                  ...analysis.suggestions.map((item) {

                    return Padding(
                      padding:
                          const EdgeInsets.only(
                        bottom: 16,
                      ),

                      child: Row(
                        crossAxisAlignment:
                            CrossAxisAlignment.start,

                        children: [

                          const Icon(
                            Icons.check_circle,
                            color: Color(0xff5D8CFF),
                          ),

                          const SizedBox(width: 12),

                          Expanded(
                            child: Text(
                              item,
                              style:
                                  GoogleFonts.poppins(
                                color: Colors.white70,
                                fontSize: 16,
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  }),
                ],
              ),
            ),

            const SizedBox(height: 30),

            // =====================================================
            // FINAL STATUS CARD
            // =====================================================

            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),

              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [
                    Color(0xff5D8CFF),
                    Color(0xff7DFFAF),
                  ],
                ),

                borderRadius:
                    BorderRadius.circular(24),
              ),

              child: Column(
                children: [

                  const Icon(
                    Icons.workspace_premium,
                    size: 60,
                    color: Colors.white,
                  ),

                  const SizedBox(height: 20),

                  Text(
                    "Resume Analysis Complete",
                    style: GoogleFonts.poppins(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 10),

                  Text(
                    "Your resume is ready for improvement and optimization.",
                    textAlign: TextAlign.center,
                    style: GoogleFonts.poppins(
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}