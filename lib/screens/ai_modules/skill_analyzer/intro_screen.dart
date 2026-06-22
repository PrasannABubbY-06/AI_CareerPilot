import 'package:flutter/material.dart';

class IntroScreen extends StatefulWidget {
  final Function(String skill) onStart;

  const IntroScreen({super.key, required this.onStart});

  @override
  State<IntroScreen> createState() => _IntroScreenState();
}

class _IntroScreenState extends State<IntroScreen> {
  final TextEditingController controller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [

          const Text(
            "Skill Analyzer 🚀",
            style: TextStyle(
              color: Colors.white,
              fontSize: 28,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 10),

          const Text(
            "Enter your skill to start test",
            style: TextStyle(color: Colors.white70),
          ),

          const SizedBox(height: 30),

          TextField(
            controller: controller,
            style: const TextStyle(color: Colors.white),
            decoration: InputDecoration(
              hintText: "e.g. Python, Flutter, Java",
              hintStyle: const TextStyle(color: Colors.white54),
              filled: true,
              fillColor: const Color(0xff151922),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
          ),

          const SizedBox(height: 25),

          ElevatedButton(
            onPressed: () {
              widget.onStart(controller.text.trim());
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xff5D8CFF),
              padding: const EdgeInsets.symmetric(
                horizontal: 40,
                vertical: 15,
              ),
            ),
            child: const Text("Start Test"),
          ),
        ],
      ),
    );
  }
}
