import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class DriverStandingGraphData {
  DriverStandingGraphData({
    required this.points,
    Color? color,
  }) : color = color ?? Colors.green;

  final List<double> points;
  final Color color;
}

class DriverStandingsChart extends StatelessWidget {
  const DriverStandingsChart({
    super.key,
    required this.season,
    required this.driverStandingsChartData,
  });

  final String season;
  final Map<String, DriverStandingGraphData> driverStandingsChartData;

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
    return Scaffold(
      appBar: AppBar(
        title: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              "$season Standings",
            ),
          ],
        ),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Row(
            children: driverStandingsChartData.entries
                .map(
                  (e) => Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 10,
                    ),
                    child: Chip(
                      backgroundColor: e.value.color,
                      label: Text(e.key),
                    ),
                  ),
                )
                .toList(),
          ),
          Flexible(
            child: Padding(
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
                            (driverStandingsChartData.values
                                    .toList())[touchedSpot.barIndex]
                                .points[index - 1]
                                .toString(),
                            textStyle,
                          );
                        }).toList();
                      },
                    ),
                  ),
                  lineBarsData: driverStandingsChartData.values
                      .map(
                        (e) => LineChartBarData(
                          spots: _getSpots(e.points),
                          color: e.color,
                        ),
                      )
                      .toList(),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
