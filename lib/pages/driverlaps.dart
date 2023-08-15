import 'dart:math';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../components/driverlapchart.dart';
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
            Text(
              "${qualifyingResult.driver.givenName} ${qualifyingResult.driver.familyName}",
              style: const TextStyle(
                fontSize: 12.0,
              ),
            ),
          ],
        ),
      ),
      body: _buildBody(context),
    );
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
          child: DriverTimingsChart(
            currentLap: currentLap,
            driverTimingsArray: {
              qualifyingResult.driver.driverId: TimingGraphData(
                timing: driverTimings,
              ),
            },
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
