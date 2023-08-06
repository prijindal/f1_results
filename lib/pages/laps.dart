import 'package:flutter/material.dart';

import '../api/ergast.dart';
import '../components/drivername.dart';
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
  List<QualifyingResult> qualifyingResults = [];
  List<RaceLap> laps = [];
  List<PitStop> pitstops = [];
  // cumulativeLapTimes will store in format {"lap3": {"driver1": "3.33.333"}}
  // this means that driver1 has taken 3:33 minutes to complete from lap 0 to lap 3
  Map<String, Map<String, DateTime>> cumulativeLapTimes = {};
  int currentLap = 0;
  bool _isLoading = true;

  @override
  initState() {
    super.initState();
    _fetchAll();
  }

  Future<void> _fetchAll() async {
    setState(() {
      _isLoading = true;
    });
    await Future.wait([
      _fetchQualifyingResults(),
      _fetchLaps(),
      _fetchPitStops(),
    ]);
    setState(() {
      _isLoading = false;
    });
  }

  Future<void> _fetchQualifyingResults() async {
    final qualifyingResults =
        await fetchQualifyingResults(widget.season, widget.race.round);
    setState(() {
      this.qualifyingResults = qualifyingResults;
    });
  }

  Future<void> _fetchLaps() async {
    final laps = await fetchLaps(widget.season, widget.race.round);
    setState(() {
      this.laps = laps;
    });
    _calculateLapTimes();
  }

  Future<void> _fetchPitStops() async {
    final pitstops = await fetchPitStops(widget.season, widget.race.round);
    setState(() {
      this.pitstops = pitstops;
    });
  }

  Future<void> _calculateLapTimes() async {
    Map<String, Map<String, DateTime>> cumulativeLapTimes = {};
    for (var k = 0; k < laps.length; k++) {
      Map<String, DateTime> cumulativeDriverTime = {};
      for (var i = 0; i < laps[k].timings.length; i++) {
        final driverId = laps[k].timings[i].driverId;
        // calculate time of all drivers
        DateTime totalTime = DateTime(int.parse(widget.season));
        for (var j = 0; j <= k; j++) {
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
    return Column(
      children: [
        if (_isLoading) const LinearProgressIndicator(),
        if (laps.isEmpty && !_isLoading)
          const Center(
            child: Text("No laps data found"),
          ),
        if (laps.length >= currentLap &&
            currentLap >= 0 &&
            qualifyingResults.isNotEmpty)
          Flexible(
            child: SingleChildScrollView(
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: currentLap == 0
                    ? qualifyingResults.length
                    : laps[currentLap - 1].timings.length,
                itemBuilder: (context, index) {
                  if (currentLap == 0) {
                    final qResult = qualifyingResults[index];
                    return ListTile(
                      title: DriverName(
                        constructor: qResult.constructor,
                        driver: qResult.driver,
                      ),
                    );
                  }
                  final timing = laps[currentLap - 1].timings[index];
                  QualifyingResult qResult = qualifyingResults
                      .singleWhere((a) => a.driver.driverId == timing.driverId);
                  String timingText = "";
                  if (timing.time != null) {
                    timingText = timing.time!;
                    if (index > 0) {
                      final aheadTiming = laps[currentLap - 1].timings[0].time;
                      if (aheadTiming != null) {
                        final diff = stringToTime(timing.time!)
                            .difference(stringToTime(aheadTiming));
                        final milliseconds = diff.inMilliseconds;
                        timingText +=
                            " ${milliseconds > 0 ? '+' : ''}${(milliseconds / 1000).floor()}.${(milliseconds % 1000)}";
                      }
                    }
                  }
                  final diffToLeader = cumulativeLapTimes[
                          laps[currentLap - 1].number]![timing.driverId]!
                      .difference(
                    (cumulativeLapTimes[laps[currentLap - 1].number]!
                            .values
                            .toList()
                          ..sort())
                        .first,
                  );
                  final milliseconds = diffToLeader.inMilliseconds;
                  timingText +=
                      " +${(milliseconds / 1000).floor()}.${(milliseconds % 1000)}";
                  final driverPitstops = pitstops
                      .where((a) =>
                          (a.driverId == timing.driverId) &&
                          int.parse(a.lap) < currentLap)
                      .map((e) => e.lap)
                      .join(",");
                  final startPosition = qResult.position;
                  int diffPositionFromStart =
                      int.parse(startPosition) - int.parse(timing.position!);
                  return ListTile(
                    title: DriverName(
                      constructor: qResult.constructor,
                      driver: qResult.driver,
                    ),
                    subtitle: Row(
                      children: [
                        Text(timingText),
                        Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 10),
                            child: Text("Pitstops: $driverPitstops")),
                      ],
                    ),
                    trailing: Text(
                      diffPositionFromStart > 0
                          ? "+$diffPositionFromStart"
                          : "$diffPositionFromStart",
                      style: TextStyle(
                        color: diffPositionFromStart > 0
                            ? Colors.green
                            : Colors.red,
                        fontSize: 30,
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        if (laps.isNotEmpty)
          Row(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                ),
                child: Text(
                  currentLap.toString(),
                  style: const TextStyle(fontSize: 24),
                ),
              ),
              IconButton(
                onPressed: () {
                  if (currentLap <= 0) {
                    return;
                  }
                  setState(() {
                    currentLap = currentLap - 1;
                  });
                },
                icon: const Icon(Icons.remove),
              ),
              Flexible(
                child: Slider(
                  min: 0,
                  max: laps.length.toDouble(),
                  divisions: laps.length,
                  value: currentLap.toDouble(),
                  label: currentLap.toString(),
                  onChanged: (newValue) {
                    setState(() {
                      currentLap = newValue.toInt();
                    });
                  },
                ),
              ),
              IconButton(
                onPressed: () {
                  if (currentLap >= laps.length) {
                    return;
                  }
                  setState(() {
                    currentLap = currentLap + 1;
                  });
                },
                icon: const Icon(Icons.add),
              ),
            ],
          )
      ],
    );
  }
}
