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
  // cumulativeLapTimes will store in format {"lap3": {"driver1": "3.33.333"}}
  // this means that driver1 has taken 3:33 minutes to complete from lap 0 to lap 3
  Map<String, Map<String, DateTime>> cumulativeLapTimes = {};
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
    _calculateLapTimes();
  }

  Future<void> _calculateLapTimes() async {
    Map<String, Map<String, DateTime>> cumulativeLapTimes = {};
    for (var k = 0; k < laps.length; k++) {
      Map<String, DateTime> cumulativeDriverTime = {};
      for (var i = 0; i < laps[k].timings.length; i++) {
        final driverId = laps[k].timings[i].driverId;
        // calculate time of all drivers
        DateTime totalTime = DateTime(int.parse(widget.season));
        for (var j = 0; j < k; j++) {
          final time = laps[j]
              .timings
              .singleWhere((element) => element.driverId == driverId)
              .time;
          if (time != null) {
            final diff = stringToTime(time)
                .copyWith(
                  year: int.parse(widget.season),
                  month: 1,
                  day: 1,
                  hour: 0,
                )
                .difference(DateTime(int.parse(widget.season)));
            totalTime = totalTime.add(diff);
          }
        }
        print(totalTime);
        if (driverId != null) {
          cumulativeDriverTime[driverId] = totalTime;
        }
      }
      cumulativeLapTimes[laps[k].number!] = cumulativeDriverTime;
    }
    setState(() {
      this.cumulativeLapTimes = cumulativeLapTimes;
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
                            " ${milliseconds > 0 ? '+' : '-'}${(milliseconds / 1000).floor()}.${(milliseconds % 1000)}";
                      }
                    }
                  }
                  final diffToLeader = cumulativeLapTimes[
                          laps[lap - 1].number]![timing.driverId]!
                      .difference(
                    (cumulativeLapTimes[laps[lap - 1].number]!.values.toList()
                          ..sort())
                        .first,
                  );
                  final milliseconds = diffToLeader.inMilliseconds;
                  timingText +=
                      " +${(milliseconds / 1000).floor()}.${(milliseconds % 1000)}";
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
