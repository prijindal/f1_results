import 'dart:math';

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../components/lapsslider.dart';
import '../models/current_lap.dart';
import '../models/result.dart';

class DriverLapsView extends StatelessWidget {
  const DriverLapsView({
    super.key,
    required this.season,
    required this.race,
    required this.qualifyingResult,
    required this.driverPitStops,
    required this.driverTimings,
  });

  final String season;
  final Race race;
  final QualifyingResult qualifyingResult;
  final List<PitStop> driverPitStops;
  final List<Timing> driverTimings;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              "${race.season} - ${race.raceName}",
            ),
            Visibility(
              visible: true,
              child: Text(
                "${qualifyingResult.driver.givenName} ${qualifyingResult.driver.familyName}",
                style: const TextStyle(
                  fontSize: 12.0,
                ),
              ),
            ),
          ],
        ),
      ),
      body: _buildBody(context),
    );
  }

  List<FlSpot> getSpots(int currentLap) {
    List<FlSpot> spots = [];
    for (var i = 0; i < driverTimings.length; i++) {
      if (i < currentLap) {
        final time = driverTimings[i].time;
        if (time != null) {
          final diff = stringToTime(time)
              .copyWith(
                year: int.parse(season),
                month: 1,
                day: 1,
                hour: 0,
              )
              .difference(DateTime(int.parse(season)));
          spots.add(FlSpot(
            (i + 1).toDouble(),
            diff.inMilliseconds.toDouble(),
          ));
        }
      }
    }
    return spots;
  }

  Widget _buildBody(BuildContext context) {
    final currentLapNotifier = Provider.of<CurrentLapNotifier>(context);
    final currentLap = currentLapNotifier.getCurrentLap(season, race.round);
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        if (driverTimings.isEmpty)
          const Center(
            child: Text("No lap data for this driver"),
          ),
        Expanded(
          child: SingleChildScrollView(
            child: ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: min(driverTimings.length, currentLap),
              itemBuilder: (context, index) {
                return ListTile(
                  leading: Text(
                    (index + 1).toString(),
                    style: const TextStyle(fontSize: 30),
                  ),
                  title: Text(driverTimings[index].time ?? "No lap data found"),
                  trailing: driverPitStops
                          .where((element) => element.lap == (index + 1))
                          .isEmpty
                      ? null
                      : const Text("Pit"),
                );
              },
            ),
          ),
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
                          driverTimings[index - 1].time ?? "NA",
                          textStyle,
                        );
                      }).toList();
                    },
                  ),
                ),
                lineBarsData: [
                  LineChartBarData(
                    spots: getSpots(currentLap),
                  )
                ],
              ),
            ),
          ),
        ),
        if (driverTimings.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(bottom: 20),
            child: LapSlider(
              season: season,
              round: race.round,
              totalLaps: driverTimings.length,
            ),
          ),
      ],
    );
  }
}
