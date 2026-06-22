import 'package:flutter/material.dart';

class ResumeBuilderScreen
    extends StatelessWidget {

  const ResumeBuilderScreen({
    super.key,
  });

  @override
  Widget build(BuildContext context) {

    return Scaffold(

      appBar: AppBar(
        title: const Text(
          "Resume Builder",
        ),
      ),

      body: const Center(

        child: Text(
          "Resume Builder Screen",
        ),
      ),
    );
  }
}