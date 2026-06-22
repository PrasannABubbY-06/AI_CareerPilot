import 'package:flutter/material.dart';

class RoadmapCard extends StatelessWidget {
  final String goal;
  final int streak;

  const RoadmapCard({
    super.key,
    required this.goal,
    required this.streak,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        leading: const Icon(Icons.route, color: Colors.green),
        title: Text(goal, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text("🔥 Streak: $streak days"),
        trailing: const Icon(Icons.arrow_forward),
        onTap: () {
          Navigator.pushNamed(context, "/roadmap");
        },
      ),
    );
  }
}
