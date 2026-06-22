import 'package:flutter/material.dart';

class ProfileButton extends StatelessWidget {
  final String text;
  final IconData icon;
  final VoidCallback onTap;

  const ProfileButton({
    super.key,
    required this.text,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 8),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xff151922),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            Icon(icon, color: Colors.white),
            const SizedBox(width: 15),
            Text(text,
                style: const TextStyle(
                    color: Colors.white, fontSize: 16)),
          ],
        ),
      ),
    );
  }
}