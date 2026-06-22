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
    if (data.isEmpty) {
      return Container(
        height: 320,
        decoration: BoxDecoration(
          color: const Color(0xff151922),
          borderRadius: BorderRadius.circular(20),
        ),
        child: const Center(
          child: Text(
            "No Skill Data Available",
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
            ),
          ),
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xff151922),
        borderRadius: BorderRadius.circular(20),
      ),
      child: SizedBox(
        height: 320,
        child: RadarChart(
          features: data.keys.toList(),
          ticks: const [20, 40, 60, 80, 100],
          data: [
            data.values
                .map((e) => e.clamp(0, 100))
                .toList(),
          ],
          graphColors: const [
            Colors.blue,
          ],
          outlineColor: Colors.white,
        ),
      ),
    );
  }
}
