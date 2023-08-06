import 'package:flutter/material.dart';

import '../api/ergast.dart';
import '../models/result.dart';

class RaceLapsView extends StatefulWidget {
  const RaceLapsView({
    super.key,
    required this.season,
    required this.race,
  });

  final String season;
  final Race race;

  @override
  State<RaceLapsView> createState() => RaceLapsViewState();
}

class RaceLapsViewState extends State<RaceLapsView> {
  List<RaceLap> laps = [];
  int lap = 1;

  @override
  initState() {
    super.initState();
    _fetchLaps();
  }

  Future<void> _fetchLaps() async {
    final laps = await fetchLaps(widget.season, widget.race.round);
    setState(() {
      this.laps = laps;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (laps.isEmpty) {
      return const Center(
        child: Text("No laps data found"),
      );
    }
    return Column(
      children: [
        if (laps.length > lap)
          Flexible(
            child: SingleChildScrollView(
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: laps[lap - 1].timings.length,
                itemBuilder: (context, index) {
                  final timing = laps[lap - 1].timings[index];
                  String timingText = "";
                  if (timing.time != null) {
                    timingText = timing.time!;
                    if (index > 0) {
                      final aheadTiming = laps[lap - 1].timings[0].time;
                      if (aheadTiming != null) {
                        final diff = stringToTime(timing.time!)
                            .difference(stringToTime(aheadTiming));
                        final milliseconds = diff.inMilliseconds;
                        timingText +=
                            " +${(milliseconds / 1000).floor()}.${(milliseconds % 1000)}";
                      }
                    }
                  }
                  return ListTile(
                    title: Text(timing.driverId ?? "NA"),
                    subtitle: Text(timingText),
                  );
                },
              ),
            ),
          ),
        Slider(
          min: 1,
          max: laps.length.toDouble(),
          divisions: laps.length,
          value: lap.toDouble(),
          label: lap.toString(),
          onChanged: (newValue) {
            setState(() {
              lap = newValue.toInt();
            });
          },
        )
      ],
    );
  }
}
