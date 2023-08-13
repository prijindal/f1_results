import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/current_lap.dart';

class LapSlider extends StatelessWidget {
  const LapSlider({
    super.key,
    required this.season,
    required this.totalLaps,
  });

  final String season;
  final int totalLaps;

  @override
  Widget build(BuildContext context) {
    final currentLapNotifier = Provider.of<CurrentLapNotifier>(context);
    final currentLap = currentLapNotifier.getCurrentLap(season);
    return Row(
      children: [
        SizedBox(
          width: 60,
          child: Center(
            child: Text(
              currentLap.toString(),
              style: const TextStyle(fontSize: 24),
            ),
          ),
        ),
        IconButton(
          onPressed: () {
            if (currentLap <= 0) {
              return;
            }
            currentLapNotifier.setCurrentLap(
              season,
              currentLap - 1,
            );
          },
          icon: const Icon(Icons.remove),
        ),
        Flexible(
          child: Slider(
            min: 0,
            max: totalLaps.toDouble(),
            divisions: totalLaps,
            value: currentLap.toDouble(),
            label: currentLap.toString(),
            onChanged: (newValue) {
              currentLapNotifier.setCurrentLap(
                season,
                newValue.toInt(),
              );
            },
          ),
        ),
        IconButton(
          onPressed: () {
            if (currentLap >= totalLaps) {
              return;
            }
            currentLapNotifier.setCurrentLap(
              season,
              currentLap + 1,
            );
          },
          icon: const Icon(Icons.add),
        ),
      ],
    );
  }
}
