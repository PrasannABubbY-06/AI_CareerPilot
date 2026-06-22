import 'package:flutter/material.dart';

class ResumeScoreCard extends StatelessWidget {

  final int score;

  const ResumeScoreCard({
    super.key,
    required this.score,
  });

  @override
  Widget build(BuildContext context) {

    return Container(

      width: double.infinity,

      padding: const EdgeInsets.all(22),

      decoration: BoxDecoration(

        gradient: const LinearGradient(

          colors: [
            Color(0xFF2563EB),
            Color(0xFF1D4ED8),
          ],
        ),

        borderRadius:
            BorderRadius.circular(24),
      ),

      child: Column(

        crossAxisAlignment:
            CrossAxisAlignment.start,

        children: [

          const Row(

            children: [

              Icon(
                Icons.description,
                color: Colors.white,
              ),

              SizedBox(width: 10),

              Text(
                "Resume ATS Score",

                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),

          const SizedBox(height: 20),

          Text(
            "$score / 100",

            style: const TextStyle(
              color: Colors.white,
              fontSize: 36,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 12),

          ClipRRect(

            borderRadius:
                BorderRadius.circular(20),

            child: LinearProgressIndicator(

              value: score / 100,

              minHeight: 10,

              backgroundColor:
                  Colors.white24,

              valueColor:
                  const AlwaysStoppedAnimation(
                Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }
}