import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/current_lap.dart';

class LapSlider extends StatelessWidget {
  const LapSlider({
    super.key,
    required this.season,
    required this.round,
    required this.totalLaps,
  });

  final String season;
  final String round;
  final int totalLaps;

  Widget _buildBody(BuildContext context) {
    final currentLapNotifier = Provider.of<CurrentLapNotifier>(context);
    final currentLap = currentLapNotifier.getCurrentLap(season, round);
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
              round,
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
                round,
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
              round,
              currentLap + 1,
            );
          },
          icon: const Icon(Icons.add),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    if (kIsWeb) {
      return _buildBody(context);
    }
    return Hero(
      tag: "$season-$round-lapSlider",
      child: Material(
        color: Colors.transparent,
        child: _buildBody(context),
      ),
    );
  }
}
