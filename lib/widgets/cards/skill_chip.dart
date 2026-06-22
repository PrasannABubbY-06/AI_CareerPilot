import 'package:flutter/material.dart';

class SkillChip extends StatelessWidget {

  final String title;

  const SkillChip({
    super.key,
    required this.title,
  });

  @override
  Widget build(BuildContext context) {

    return Container(
      margin: const EdgeInsets.only(
        right: 8,
        bottom: 8,
      ),

      padding: const EdgeInsets.symmetric(
        horizontal: 14,
        vertical: 8,
      ),

      decoration: BoxDecoration(
        color: Colors.blue.shade50,

        borderRadius:
            BorderRadius.circular(20),
      ),

      child: Text(title),
    );
  }
}