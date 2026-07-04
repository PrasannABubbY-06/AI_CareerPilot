import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../../widgets/common/custom_textfield.dart';
import '../../../widgets/common/primary_button.dart';
import '../../../widgets/common/glass_container.dart';
import '../../../services/career_mentor_service.dart';

class MentorInputScreen extends StatefulWidget {
  const MentorInputScreen({super.key});

  @override
  State<MentorInputScreen> createState() => _MentorInputScreenState();
}

class _MentorInputScreenState extends State<MentorInputScreen> {
  final _formKey = GlobalKey<FormState>();
  
  final TextEditingController _educationCtrl = TextEditingController();
  final TextEditingController _skillsCtrl = TextEditingController();
  final TextEditingController _interestsCtrl = TextEditingController();
  final TextEditingController _strengthsCtrl = TextEditingController();
  final TextEditingController _weaknessesCtrl = TextEditingController();
  final TextEditingController _dreamCareerCtrl = TextEditingController();
  final TextEditingController _industryCtrl = TextEditingController();
  
  String _sectorPreference = 'Private';
  final List<String> _sectors = ['Private', 'Government', 'Business/Freelance'];
  
  bool _isLoading = false;
  final CareerMentorService _mentorService = CareerMentorService();

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) return;
    
    setState(() => _isLoading = true);
    
    try {
      final report = await _mentorService.generateCareerReport(
        education: _educationCtrl.text.trim(),
        skills: _skillsCtrl.text.trim(),
        interests: _interestsCtrl.text.trim(),
        strengths: _strengthsCtrl.text.trim(),
        weaknesses: _weaknessesCtrl.text.trim(),
        dreamCareer: _dreamCareerCtrl.text.trim(),
        industry: _industryCtrl.text.trim(),
        sectorPreference: _sectorPreference,
      );
      
      if (!mounted) return;
      
      if (report.startsWith("Error:") || report.contains("AI Service Error:")) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(report), backgroundColor: Colors.redAccent),
        );
      } else {
        Navigator.pushNamed(
          context, 
          '/career-mentor-report',
          arguments: report,
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e"), backgroundColor: Colors.redAccent),
      );
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  void dispose() {
    _educationCtrl.dispose();
    _skillsCtrl.dispose();
    _interestsCtrl.dispose();
    _strengthsCtrl.dispose();
    _weaknessesCtrl.dispose();
    _dreamCareerCtrl.dispose();
    _industryCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          "AI Career Mentor",
          style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: Stack(
        children: [
          // Background Glows
          Positioned(
            top: -50,
            left: -50,
            child: Container(
              width: 200,
              height: 200,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Theme.of(context).primaryColor.withValues(alpha: 0.15),
                    blurRadius: 100,
                  ),
                ],
              ),
            ),
          ),
          Positioned(
            bottom: -50,
            right: -50,
            child: Container(
              width: 200,
              height: 200,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Theme.of(context).colorScheme.secondary.withValues(alpha: 0.1),
                    blurRadius: 100,
                  ),
                ],
              ),
            ),
          ),
          
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Tell us about yourself 🚀",
                      style: GoogleFonts.poppins(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).textTheme.bodyLarge?.color,
                      ),
                    ).animate().fade().slideY(),
                    
                    const SizedBox(height: 8),
                    
                    Text(
                      "The more details you provide, the more accurate and personalized your career roadmap will be.",
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        color: Theme.of(context).textTheme.bodyMedium?.color?.withValues(alpha: 0.7),
                      ),
                    ).animate().fade(delay: 100.ms).slideY(),
                    
                    const SizedBox(height: 30),
                    
                    // Fields
                    _buildSectionTitle("Core Information").animate().fade(delay: 200.ms).slideX(),
                    GlassContainer(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        children: [
                          CustomTextField(
                            controller: _educationCtrl,
                            hintText: "e.g., B.Tech in Computer Science",
                            prefixIcon: Icons.school_rounded,
                            validator: (val) => val == null || val.isEmpty ? "Required" : null,
                          ),
                          const SizedBox(height: 16),
                          CustomTextField(
                            controller: _skillsCtrl,
                            hintText: "e.g., Python, React, Public Speaking",
                            prefixIcon: Icons.psychology_rounded,
                            validator: (val) => val == null || val.isEmpty ? "Required" : null,
                          ),
                          const SizedBox(height: 16),
                          CustomTextField(
                            controller: _interestsCtrl,
                            hintText: "e.g., AI, Video Editing, Management",
                            prefixIcon: Icons.favorite_rounded,
                            validator: (val) => val == null || val.isEmpty ? "Required" : null,
                          ),
                        ],
                      ),
                    ).animate().fade(delay: 300.ms).slideY(),
                    
                    const SizedBox(height: 24),
                    
                    _buildSectionTitle("Preferences & Goals").animate().fade(delay: 400.ms).slideX(),
                    GlassContainer(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          CustomTextField(
                            controller: _industryCtrl,
                            hintText: "e.g., IT, Healthcare, Finance",
                            prefixIcon: Icons.business_center_rounded,
                            validator: (val) => val == null || val.isEmpty ? "Required" : null,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            "Sector Preference",
                            style: GoogleFonts.poppins(
                              color: Theme.of(context).textTheme.bodyMedium?.color?.withValues(alpha: 0.8),
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.05),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
                            ),
                            child: DropdownButtonHideUnderline(
                              child: DropdownButton<String>(
                                value: _sectorPreference,
                                isExpanded: true,
                                dropdownColor: Theme.of(context).scaffoldBackgroundColor,
                                icon: const Icon(Icons.arrow_drop_down_rounded, color: Colors.grey),
                                items: _sectors.map((sector) {
                                  return DropdownMenuItem(
                                    value: sector,
                                    child: Text(
                                      sector,
                                      style: GoogleFonts.poppins(
                                        color: Theme.of(context).textTheme.bodyLarge?.color,
                                      ),
                                    ),
                                  );
                                }).toList(),
                                onChanged: (val) {
                                  if (val != null) {
                                    setState(() => _sectorPreference = val);
                                  }
                                },
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                          CustomTextField(
                            controller: _dreamCareerCtrl,
                            hintText: "Dream Job (Optional)",
                            prefixIcon: Icons.star_rounded,
                          ),
                        ],
                      ),
                    ).animate().fade(delay: 500.ms).slideY(),

                    const SizedBox(height: 24),

                    _buildSectionTitle("Self Assessment (Optional)").animate().fade(delay: 600.ms).slideX(),
                    GlassContainer(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        children: [
                          CustomTextField(
                            controller: _strengthsCtrl,
                            hintText: "e.g., Problem solving, Fast learner",
                            prefixIcon: Icons.trending_up_rounded,
                          ),
                          const SizedBox(height: 16),
                          CustomTextField(
                            controller: _weaknessesCtrl,
                            hintText: "e.g., Time management, Procrastination",
                            prefixIcon: Icons.trending_down_rounded,
                          ),
                        ],
                      ),
                    ).animate().fade(delay: 700.ms).slideY(),

                    const SizedBox(height: 40),

                    _isLoading
                        ? const Center(child: CircularProgressIndicator())
                        : PrimaryButton(
                            text: "Generate Career Roadmap",
                            onPressed: _submitForm,
                          ).animate().fade(delay: 800.ms).scale(),
                          
                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12, left: 4),
      child: Text(
        title,
        style: GoogleFonts.poppins(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: Theme.of(context).primaryColor,
        ),
      ),
    );
  }
}
