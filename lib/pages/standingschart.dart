import 'package:flutter/material.dart';

import '../components/doubledatachart.dart';

class DriverStandingGraphData {
  DriverStandingGraphData({
    required this.cumulativePoints,
    required this.points,
    Color? color,
  }) : color = color ?? Colors.green;

  final List<double> cumulativePoints;
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
              child: DoubleDataLineChart(
                data: driverStandingsChartData.map(
                  (key, value) => MapEntry(
                    key,
                    DoubleChartData(
                      data: value.cumulativePoints,
                      color: value.color,
                    ),
                  ),
                ),
              ),
            ),
          ),
          Flexible(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 48),
              child: DoubleDataLineChart(
                data: driverStandingsChartData.map(
                  (key, value) => MapEntry(
                    key,
                    DoubleChartData(
                      data: value.points,
                      color: value.color,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
