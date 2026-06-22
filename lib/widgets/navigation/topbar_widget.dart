import 'package:flutter/material.dart';

class TopbarWidget extends StatefulWidget implements PreferredSizeWidget {
  final String title;

  const TopbarWidget({super.key, required this.title});

  @override
  State<TopbarWidget> createState() => _TopbarWidgetState();

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}

class _TopbarWidgetState extends State<TopbarWidget> {
  bool isMuted = false;

  void toggleBell() {
    setState(() {
      isMuted = !isMuted;
    });
  }

  void openProfile() {
    Navigator.pushNamed(context, "/profile");
  }

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: Text(widget.title),
      backgroundColor: const Color(0xff0B1020),

      actions: [

        // 🔔 BELL TOGGLE
        IconButton(
          icon: Icon(
            isMuted ? Icons.notifications_off : Icons.notifications,
            color: isMuted ? Colors.redAccent : Colors.white,
          ),
          onPressed: toggleBell,
        ),

        // 👤 PROFILE OPEN
        IconButton(
          icon: const Icon(Icons.person_outline),
          onPressed: openProfile,
        ),
      ],
    );
  }
}