import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../widgets/common/glass_container.dart';
import '../../../models/resource_pack_model.dart';
import '../../../services/resource_library_service.dart';

class SkillResourceScreen extends StatefulWidget {
  final String skillName;

  const SkillResourceScreen({super.key, required this.skillName});

  @override
  State<SkillResourceScreen> createState() => _SkillResourceScreenState();
}

class _SkillResourceScreenState extends State<SkillResourceScreen> {
  final ResourceLibraryService _service = ResourceLibraryService();
  ResourcePackModel? _pack;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchResources();
  }

  Future<void> _fetchResources() async {
    final pack = await _service.getResourcePack(widget.skillName);
    if (mounted) {
      setState(() {
        _pack = pack;
        _isLoading = false;
      });
    }
  }

  Future<void> _launchURL(String urlString) async {
    final url = Uri.tryParse(urlString);
    if (url != null && await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Could not launch $urlString')),
        );
      }
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
          "Resource Library",
          style: GoogleFonts.poppins(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        centerTitle: true,
      ),
      body: Stack(
        children: [
          // Background Glows
          Positioned(
            top: -50,
            right: -50,
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.tealAccent.withValues(alpha: 0.08),
                    blurRadius: 100,
                  ),
                ],
              ),
            ),
          ),

          _isLoading 
            ? _buildSkeletonLoader()
            : _pack == null 
              ? _buildError()
              : _buildContent(),
        ],
      ),
    );
  }

  Widget _buildSkeletonLoader() {
    return ListView.builder(
      padding: const EdgeInsets.all(20),
      itemCount: 5,
      itemBuilder: (context, index) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: GlassContainer(
            padding: const EdgeInsets.all(20),
            borderRadius: BorderRadius.circular(20),
            child: Row(
              children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Container(
                  height: 20,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
              ],
            ),
          ),
        ).animate(onPlay: (controller) => controller.repeat(reverse: true))
         .fade(begin: 0.3, end: 0.7, duration: 800.ms);
      },
    );
  }

  Widget _buildError() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline_rounded, color: Colors.redAccent, size: 60),
          const SizedBox(height: 16),
          Text(
            "Failed to load resources.",
            style: GoogleFonts.poppins(color: Colors.white, fontSize: 18),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: _fetchResources,
            child: const Text("Retry"),
          ),
        ],
      ),
    );
  }

  Widget _buildContent() {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        Text(
          "Mastering ${widget.skillName}",
          style: GoogleFonts.poppins(
            color: Colors.white,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ).animate().fade().slideY(),
        const SizedBox(height: 8),
        Text(
          "Curated intelligent resource pack",
          style: GoogleFonts.poppins(
            color: Colors.white70,
            fontSize: 14,
          ),
        ).animate().fade(delay: 100.ms),
        
        const SizedBox(height: 32),

        _buildResourceSection("YouTube Tutorials", _pack!.youtubeVideos, Icons.play_circle_fill_rounded, Colors.redAccent, 0),
        _buildResourceSection("Official Documentation", _pack!.officialDocs, Icons.book_rounded, Colors.blueAccent, 1),
        _buildResourceSection("Free Learning Websites", _pack!.freeWebsites, Icons.language_rounded, Colors.greenAccent, 2),
        _buildResourceSection("Practice Platforms", _pack!.practicePlatforms, Icons.code_rounded, Colors.purpleAccent, 3),
        _buildResourceSection("GitHub Repositories", _pack!.githubRepos, Icons.folder_copy_rounded, Colors.white70, 4),
        _buildResourceSection("Mini Project Ideas", _pack!.miniProjects, Icons.lightbulb_rounded, Colors.amberAccent, 5),

        const SizedBox(height: 40),
      ],
    );
  }

  Widget _buildResourceSection(String title, List<ResourceLink> links, IconData icon, Color color, int index) {
    if (links.isEmpty) return const SizedBox.shrink();

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: GlassContainer(
        borderRadius: BorderRadius.circular(20),
        child: Theme(
          data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
          child: ExpansionTile(
            iconColor: Colors.white,
            collapsedIconColor: Colors.white70,
            leading: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.15),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 20),
            ),
            title: Text(
              title,
              style: GoogleFonts.poppins(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            children: links.map((link) {
              return ListTile(
                contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 4),
                leading: const Icon(Icons.link_rounded, color: Colors.white38, size: 20),
                title: Text(
                  link.title,
                  style: GoogleFonts.poppins(color: Colors.white.withValues(alpha: 0.9), fontSize: 14),
                ),
                trailing: const Icon(Icons.arrow_forward_ios_rounded, color: Colors.white24, size: 14),
                onTap: () => _launchURL(link.url),
              );
            }).toList(),
          ),
        ),
      ),
    ).animate().fade(delay: (200 + index * 100).ms).slideX(begin: 0.05);
  }
}
