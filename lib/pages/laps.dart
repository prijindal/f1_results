import 'dart:math';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../api/ergast.dart';
import '../components/driverlapchart.dart';
import '../components/drivername.dart';
import '../components/lapsslider.dart';
import '../models/current_lap.dart';
import '../models/result.dart';
import 'driverlaps.dart';
import 'driverlapsdiff.dart';

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
  bool _isLoading = true;
  List<String> _selectedDrivers = [];

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
    if (context.mounted) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _fetchQualifyingResults() async {
    final qualifyingResults =
        await fetchQualifyingResults(widget.season, widget.race.round);
    if (context.mounted) {
      setState(() {
        this.qualifyingResults = qualifyingResults;
      });
    }
  }

  Future<void> _fetchLaps() async {
    final laps = await fetchLaps(widget.season, widget.race.round);
    if (context.mounted) {
      setState(() {
        this.laps = laps;
      });
    }
    _calculateLapTimes();
  }

  Future<void> _fetchPitStops() async {
    final pitstops = await fetchPitStops(widget.season, widget.race.round);
    if (context.mounted) {
      setState(() {
        this.pitstops = pitstops;
      });
    }
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
      cumulativeLapTimes[laps[k].number.toString()] = cumulativeDriverTime;
    }
    for (var lap in laps) {
      for (var timing in lap.timings) {
        var newQualifyingResults = qualifyingResults.toList();
        final matchedQualifyingResults = qualifyingResults
            .where((element) => element.driver.driverId == timing.driverId);
        if (matchedQualifyingResults.isEmpty) {
          newQualifyingResults.add(
            QualifyingResult(
              number: "0",
              position: newQualifyingResults.length,
              driver: Driver(
                driverId: timing.driverId!,
                permanentNumber: null,
                code: null,
                url: null,
                givenName: null,
                familyName: null,
                dateOfBirth: null,
                nationality: null,
              ),
              constructor: null,
              q1: null,
              q2: null,
              q3: null,
            ),
          );
        }
        setState(() {
          qualifyingResults = newQualifyingResults;
        });
      }
    }
    if (context.mounted) {
      setState(() {
        this.cumulativeLapTimes = cumulativeLapTimes;
      });
    }
  }

  Duration _getCumulativeDiffToLeader(String driverId, int currentLap) {
    for (var i = currentLap - 1; i >= 0; i--) {
      final currentCumulative = cumulativeLapTimes[laps[i].number.toString()];
      if (currentCumulative != null && currentCumulative[driverId] != null) {
        return currentCumulative[driverId]!
            .difference((currentCumulative.values.toList()..sort()).first);
      }
    }
    return const Duration();
  }

  Duration _getDiffToLeader(String driverId, int currentLap) {
    if (currentLap != 0) {
      final timings = laps[currentLap - 1]
          .timings
          .where((element) => element.driverId == driverId);
      if (timings.isNotEmpty) {
        final timing = timings.first;
        if (timing.time != null) {
          final aheadTiming = laps[currentLap - 1].timings[0].time;
          if (aheadTiming != null) {
            final diff = stringToTime(timing.time!)
                .difference(stringToTime(aheadTiming));
            return diff;
          }
        }
      }
    }
    return const Duration();
  }

  Timing _getCurrentTiming(String driverId, int currentLap) {
    if (currentLap == 0) {
      return Timing(
        driverId: driverId,
        position: 999,
        time: null,
      );
    }
    return laps[currentLap - 1].timings.singleWhere(
          (element) => element.driverId == driverId,
          orElse: () => Timing(
            driverId: driverId,
            position: 999,
            time: null,
          ),
        );
  }

  RaceLap? _getLastValidLap(String driverId, int currentLap) {
    int lappedLaps = 0;
    if (currentLap > 0) {
      final diff = _getCumulativeDiffToLeader(driverId, currentLap);
      final leaderTimeString = laps[currentLap - 1].timings[0].time;
      if (leaderTimeString != null) {
        final leaderDiffFromZero = stringToTime(leaderTimeString)
            .copyWith(
              year: int.parse(widget.season),
              month: 1,
              day: 1,
              hour: 0,
            )
            .difference(DateTime(int.parse(widget.season)));
        if (diff > leaderDiffFromZero) {
          lappedLaps =
              (diff.inMilliseconds / leaderDiffFromZero.inMilliseconds).floor();
        }
      }
      for (var i = max(0, currentLap - (1 + lappedLaps)); i >= 0; i--) {
        final timings =
            laps[i].timings.where((element) => element.driverId == driverId);
        if (timings.isNotEmpty) {
          return (laps[i]);
        }
      }
    }
    return null;
  }

  int? _getPosition(String driverId, int currentLap) {
    final timing = _getLastTiming(driverId, currentLap);
    if (timing != null) {
      return timing.position;
    }
    return null;
  }

  Timing? _getLastTiming(String driverId, int currentLap) {
    for (var i = currentLap - 1; i >= 0; i--) {
      final timings =
          laps[i].timings.where((element) => element.driverId == driverId);
      if (timings.isNotEmpty) {
        final timing = timings.first;
        return timing;
      }
    }
    return null;
  }

  int _getPositionFromStart(String driverId, int currentLap) {
    final qResult = qualifyingResults
        .singleWhere((element) => element.driver.driverId == driverId);
    final position = _getPosition(driverId, currentLap);
    if (position != null) {
      return qResult.position - position;
    }
    return 0;
  }

  String _lastLapTiming(String driverId, int currentLap) {
    final timing = _getCurrentTiming(driverId, currentLap);
    if (timing.time != null) {
      return timing.time!;
    }
    return "";
  }

  int _positionCompare(QualifyingResult a, QualifyingResult b, int currentLap) {
    if (currentLap == 0) {
      return a.position.compareTo(b.position);
    }
    final currentTimingA = _getCurrentTiming(a.driver.driverId, currentLap);
    final currentTimingB = _getCurrentTiming(b.driver.driverId, currentLap);
    if (currentTimingA.position != currentTimingB.position) {
      return currentTimingA.position.compareTo(currentTimingB.position);
    }
    final lastLapA = _getLastValidLap(a.driver.driverId, currentLap);
    final lastLapB = _getLastValidLap(b.driver.driverId, currentLap);
    if (lastLapA != null &&
        lastLapB != null &&
        lastLapA.number != lastLapB.number) {
      return (-lastLapA.number).compareTo(-(lastLapB.number));
    }
    final positionA = _getPosition(a.driver.driverId, currentLap);
    final positionB = _getPosition(b.driver.driverId, currentLap);
    if (positionA != null && positionB != null) {
      return positionA.compareTo(positionB);
    }
    return a.position.compareTo(b.position);
  }

  String durationToText(Duration diff) {
    final milliseconds = diff.inMilliseconds;
    return "${milliseconds >= 0 ? '+' : ''}${(milliseconds / 1000).toStringAsFixed(3)}";
  }

  void _selectDriver(String driverId) {
    final selectedDrivers = _selectedDrivers.toList();
    if (selectedDrivers.contains(driverId)) {
      selectedDrivers.remove(driverId);
    } else {
      selectedDrivers.add(driverId);
    }
    setState(() {
      _selectedDrivers = selectedDrivers;
    });
  }

  List<Timing> _getDriverTimings(String driverId) {
    final List<Timing> timings = [];
    for (var lap in laps) {
      timings
          .addAll(lap.timings.where((element) => element.driverId == driverId));
    }
    return timings;
  }

  @override
  Widget build(BuildContext context) {
    final currentLapNotifier = Provider.of<CurrentLapNotifier>(context);
    final currentLap =
        currentLapNotifier.getCurrentLap(widget.season, widget.race.round);
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
                physics: const NeverScrollableScrollPhysics(),
                itemCount: qualifyingResults.length,
                itemBuilder: (context, index) {
                  final qResult = (qualifyingResults
                    ..sort(
                        (a, b) => _positionCompare(a, b, currentLap)))[index];
                  String timingText = "";
                  int diffPositionFromStart = _getPositionFromStart(
                      qResult.driver.driverId, currentLap);
                  final driverPitstops = pitstops
                      .where((a) =>
                          (a.driverId == qResult.driver.driverId) &&
                          a.lap < currentLap)
                      .map((e) => e.lap)
                      .join(",");
                  timingText +=
                      _lastLapTiming(qResult.driver.driverId, currentLap);
                  final diff =
                      _getDiffToLeader(qResult.driver.driverId, currentLap);
                  timingText += " ${durationToText(diff)}";
                  final diffToLeader = _getCumulativeDiffToLeader(
                      qResult.driver.driverId, currentLap);

                  timingText += " ${durationToText(diffToLeader)}";
                  final lap =
                      _getLastValidLap(qResult.driver.driverId, currentLap);
                  String secondRow = "";
                  secondRow += "Pitstops: $driverPitstops";
                  if (lap != null) {
                    secondRow += " Lap: ${lap.number}";
                  }
                  return ListTile(
                    leading: Text(
                      (index + 1).toString(),
                      style: const TextStyle(fontSize: 30),
                    ),
                    selected:
                        _selectedDrivers.contains(qResult.driver.driverId),
                    title: DriverName(
                      constructor: qResult.constructor,
                      driver: qResult.driver,
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [Text(timingText), Text(secondRow)],
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
                    onTap: () {
                      if (_selectedDrivers.isNotEmpty) {
                        _selectDriver(qResult.driver.driverId);
                        return;
                      }
                      Navigator.of(context).push(
                        MaterialPageRoute<void>(
                          builder: (context) => DriverLapsView(
                            season: widget.season,
                            race: widget.race,
                            qualifyingResult: qResult,
                            driverPitStops: pitstops
                                .where(
                                  (element) =>
                                      element.driverId ==
                                      qResult.driver.driverId,
                                )
                                .toList(),
                            driverTimings:
                                _getDriverTimings(qResult.driver.driverId),
                          ),
                        ),
                      );
                    },
                    onLongPress: () {
                      _selectDriver(qResult.driver.driverId);
                    },
                  );
                },
              ),
            ),
          ),
        if (_selectedDrivers.isNotEmpty)
          TextButton(
            onPressed: () {
              final Map<String, TimingGraphData> driverTimingsArray = {};
              final List<Color> availableColors = [
                Colors.green,
                Colors.red,
                Colors.amber,
                Colors.blue,
                Colors.deepOrange
              ];
              for (var i = 0; i < _selectedDrivers.length; i++) {
                final selectedDriver = _selectedDrivers[i];
                driverTimingsArray[selectedDriver] = TimingGraphData(
                  timing: _getDriverTimings(selectedDriver),
                  color: i < availableColors.length ? availableColors[i] : null,
                );
              }
              Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (context) => DriverLapsDifference(
                    season: widget.season,
                    race: widget.race,
                    driverTimingsArray: driverTimingsArray,
                  ),
                ),
              );
            },
            child: const Text("Difference"),
          ),
        if (laps.isNotEmpty)
          LapSlider(
            season: widget.season,
            round: widget.race.round,
            totalLaps: laps.length,
          )
      ],
    );
  }
}
