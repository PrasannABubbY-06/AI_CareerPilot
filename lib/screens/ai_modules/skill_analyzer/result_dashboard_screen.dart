import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '/screens/ai_modules/skill_analyzer/models/result_model.dart';


class ResultDashboardScreen extends StatelessWidget {
  final ResultModel result;

  const ResultDashboardScreen({
    super.key,
    required this.result,
  });

  @override
  Widget build(BuildContext context) {
    final skills = result.skillScores;

    return Scaffold(
      backgroundColor: const Color(0xff0B1020),
      appBar: AppBar(
        backgroundColor: const Color(0xff0B1020),
        title: const Text("Skill Dashboard"),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // ================= SCORE CARD =================
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: const Color(0xff151922),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                children: [
                  Text(
                    "ATS Score: ${result.percentage.toStringAsFixed(1)}%",
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    "Strongest Skill: ${result.strongestSkill}",
                    style: const TextStyle(color: Colors.white70),
                  ),
                  Text(
                    "Weakest Skill: ${result.weakestSkill}",
                    style: const TextStyle(color: Colors.white70),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 30),

            // ================= RADAR CHART =================
            SizedBox(
              height: 320,
              child: RadarChart(
                RadarChartData(
                  radarBackgroundColor: Colors.transparent,
                  borderData: FlBorderData(show: false),
                  radarBorderData: const BorderSide(color: Colors.white24),

                  titlePositionPercentageOffset: 0.1,

                  getTitle: (index, angle) {
                    final labels = skills.keys.toList();
                    return RadarChartTitle(
                      text: labels[index],
                    );
                  },

                  dataSets: [
                    RadarDataSet(
                      fillColor: Colors.blue.withOpacity(0.3),
                      borderColor: Colors.blue,
                      entryRadius: 3,
                      dataEntries: skills.values
                          .map((e) => RadarEntry(value: e))
                          .toList(),
                    ),
                  ],

                  tickCount: 5,
                  ticksTextStyle: const TextStyle(
                    color: Colors.white24,
                    fontSize: 10,
                  ),

                  radarShape: RadarShape.polygon,
                ),
              ),
            ),

            const SizedBox(height: 30),

            // ================= SKILL LIST =================
            ...skills.entries.map(
              (e) => Container(
                margin: const EdgeInsets.only(bottom: 10),
                padding: const EdgeInsets.all(15),
                decoration: BoxDecoration(
                  color: const Color(0xff151922),
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      e.key,
                      style: const TextStyle(color: Colors.white),
                    ),
                    Text(
                      "${e.value.toStringAsFixed(1)}%",
                      style: const TextStyle(
                        color: Colors.greenAccent,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}