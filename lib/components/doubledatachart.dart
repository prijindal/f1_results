import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class DoubleChartData {
  DoubleChartData({
    required this.data,
    Color? color,
  }) : color = color ?? Colors.green;

  final List<double> data;
  final Color color;
}

class DoubleDataLineChart extends StatelessWidget {
  const DoubleDataLineChart({super.key, required this.data});

  final Map<String, DoubleChartData> data;

  List<FlSpot> _getSpots(List<double> driverStandings) {
    List<FlSpot> spots = [];
    for (var i = 0; i < driverStandings.length; i++) {
      final point = driverStandings[i];
      spots.add(FlSpot(
        (i + 1).toDouble(),
        point,
      ));
    }
    return spots;
  }

  @override
  Widget build(BuildContext context) {
    return LineChart(
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
                  (data.values.toList())[touchedSpot.barIndex]
                      .data[index - 1]
                      .toString(),
                  textStyle,
                );
              }).toList();
            },
          ),
        ),
        lineBarsData: data.values
            .map(
              (e) => LineChartBarData(
                spots: _getSpots(e.data),
                color: e.color,
              ),
            )
            .toList(),
      ),
    );
  }
}
