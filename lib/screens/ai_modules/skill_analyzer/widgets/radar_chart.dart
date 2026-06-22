import 'package:flutter/material.dart';
import 'package:flutter_radar_chart/flutter_radar_chart.dart';

class RadarChartWidget extends StatelessWidget {
  final Map<String, double> data;

  const RadarChartWidget({
    super.key,
    required this.data,
  });

  @override
  Widget build(BuildContext context) {
    final titles = data.keys.toList();

    final values = data.values
        .map((e) => e.clamp(0, 100))
        .toList();

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color.fromARGB(216, 96, 110, 143),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          const Text(
            "Skill Radar",
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 20),

          SizedBox(
            height: 320,
            child: RadarChart(
              ticks: const [
                20,
                40,
                60,
                80,
                100,
              ],
              features: titles,
              data: [values],
              graphColors: const [
                Colors.blue,
              ],
              outlineColor: Colors.white54,
            ),
          ),

          const SizedBox(height: 20),

          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: data.entries.map((e) {
              return Chip(
                backgroundColor:
                    const Color(0xff252A36),
                label: Text(
                  "${e.key}: ${e.value.toInt()}%",
                  style: const TextStyle(
                    color: Colors.white,
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}