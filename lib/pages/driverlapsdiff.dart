import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../components/driverlapchart.dart';
import '../components/lapsslider.dart';
import '../models/current_lap.dart';
import '../models/result.dart';

class DriverLapsDifference extends StatelessWidget {
  const DriverLapsDifference({
    super.key,
    required this.season,
    required this.race,
    required this.driverTimingsArray,
  });

  final String season;
  final Race race;
  final Map<String, TimingGraphData> driverTimingsArray;

  @override
  Widget build(BuildContext context) {
    final currentLapNotifier = Provider.of<CurrentLapNotifier>(context);
    final currentLap = currentLapNotifier.getCurrentLap(season, race.round);
    return Scaffold(
      appBar: AppBar(
        title: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              "${race.season} - ${race.raceName}",
            ),
            const Text(
              "Difference",
              style: TextStyle(
                fontSize: 12.0,
              ),
            ),
          ],
        ),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          // SizedBox(
          //   height: 100,
          //   child: SingleChildScrollView(
          //     child: ListView.builder(
          //       shrinkWrap: true,
          //       physics: const NeverScrollableScrollPhysics(),
          //       itemCount: driverTimingsArray.length,
          //       itemBuilder: (context, index) {
          //         final driverId = driverTimingsArray.keys.elementAt(index);
          //         final value = driverTimingsArray[driverId];
          //         return ListTile(
          //           leading: Container(
          //             height: 20,
          //             width: 20,
          //             decoration: BoxDecoration(
          //                 color: value?.color ?? Colors.green,
          //                 borderRadius: BorderRadius.circular(20)),
          //           ),
          //           title: Text(driverId),
          //         );
          //       },
          //     ),
          //   ),
          // ),
          Row(
            children: driverTimingsArray.entries
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
            child: DriverTimingsChart(
              currentLap: currentLap,
              driverTimingsArray: driverTimingsArray,
            ),
          ),
          if (driverTimingsArray.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(bottom: 20),
              child: LapSlider(
                season: season,
                round: race.round,
                totalLaps: driverTimingsArray.values.first.timing.length,
              ),
            ),
        ],
      ),
    );
  }
}
