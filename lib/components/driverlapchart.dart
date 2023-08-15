import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../models/result.dart';

class TimingGraphData {
  TimingGraphData({
    required this.timing,
    Color? color,
  }) : color = color ?? Colors.green;

  final List<Timing> timing;
  final Color color;
}

class DriverTimingsChart extends StatelessWidget {
  const DriverTimingsChart({
    super.key,
    required this.driverTimingsArray,
    required this.currentLap,
  });
  final Map<String, TimingGraphData> driverTimingsArray;
  final int currentLap;

  List<FlSpot> _getSpots(List<Timing> driverTimings) {
    List<FlSpot> spots = [];
    for (var i = 0; i < driverTimings.length; i++) {
      if (i < currentLap) {
        final time = driverTimings[i].time;
        if (time != null) {
          final diff = stringToTime(time)
              .copyWith(
                year: 1,
                month: 1,
                day: 1,
                hour: 0,
              )
              .difference(DateTime(1));
          spots.add(FlSpot(
            (i + 1).toDouble(),
            diff.inMilliseconds.toDouble(),
          ));
        }
      }
    }
    return spots;
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 48),
      child: LineChart(
        LineChartData(
          titlesData: const FlTitlesData(
            show: true,
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: false,
              ),
            ),
            topTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: false,
              ),
            ),
            rightTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: false,
              ),
            ),
          ),
          lineTouchData: LineTouchData(
            touchTooltipData: LineTouchTooltipData(
              getTooltipItems: (List<LineBarSpot> touchedSpots) {
                return touchedSpots.map((LineBarSpot touchedSpot) {
                  final textStyle = TextStyle(
                    color: touchedSpot.bar.gradient?.colors.first ??
                        touchedSpot.bar.color ??
                        Colors.blueGrey,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  );
                  final index = touchedSpot.x.toInt();
                  return LineTooltipItem(
                    (driverTimingsArray.values.toList())[touchedSpot.barIndex]
                            .timing[index - 1]
                            .time ??
                        "NA",
                    textStyle,
                  );
                }).toList();
              },
            ),
          ),
          lineBarsData: driverTimingsArray.values
              .map(
                (e) => LineChartBarData(
                  spots: _getSpots(e.timing),
                  color: e.color,
                ),
              )
              .toList(),
        ),
      ),
    );
  }
}
