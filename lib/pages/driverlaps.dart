import 'dart:math';

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../api/ergast.dart';
import '../components/lapsslider.dart';
import '../models/current_lap.dart';
import '../models/result.dart';

class DriverLapsView extends StatefulWidget {
  const DriverLapsView({
    super.key,
    required this.season,
    required this.race,
    required this.qualifyingResult,
  });

  final String season;
  final Race race;
  final QualifyingResult qualifyingResult;

  @override
  State<DriverLapsView> createState() => DriverLapsViewState();
}

class DriverLapsViewState extends State<DriverLapsView> {
  List<RaceLap> laps = [];
  List<PitStop> pitstops = [];
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
      _fetchLaps(),
      _fetchPitStops(),
    ]);
    setState(() {
      _isLoading = false;
    });
  }

  Future<void> _fetchLaps() async {
    final laps = await fetchLaps(widget.season, widget.race.round);
    setState(() {
      this.laps = laps;
    });
  }

  Future<void> _fetchPitStops() async {
    final pitstops = await fetchPitStops(widget.season, widget.race.round);
    setState(() {
      this.pitstops = pitstops;
    });
  }

  List<PitStop> get _driverPitStops {
    return pitstops
        .where(
          (element) =>
              element.driverId == widget.qualifyingResult.driver.driverId,
        )
        .toList();
  }

  List<Timing> get _driverTimings {
    final List<Timing> timings = [];
    for (var lap in laps) {
      timings.addAll(lap.timings.where((element) =>
          element.driverId == widget.qualifyingResult.driver.driverId));
    }
    return timings;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              "${widget.race.season} - ${widget.race.raceName}",
            ),
            Visibility(
              visible: true,
              child: Text(
                "${widget.qualifyingResult.driver.givenName} ${widget.qualifyingResult.driver.familyName}",
                style: const TextStyle(
                  fontSize: 12.0,
                ),
              ),
            ),
          ],
        ),
      ),
      body: _isLoading ? const LinearProgressIndicator() : _buildBody(),
    );
  }

  List<FlSpot> getSpots(int currentLap) {
    List<FlSpot> spots = [];
    for (var i = 0; i < _driverTimings.length; i++) {
      if (i < currentLap) {
        final time = _driverTimings[i].time;
        if (time != null) {
          final diff = stringToTime(time)
              .copyWith(
                year: int.parse(widget.season),
                month: 1,
                day: 1,
                hour: 0,
              )
              .difference(DateTime(int.parse(widget.season)));
          spots.add(FlSpot(
            (i + 1).toDouble(),
            diff.inMilliseconds.toDouble(),
          ));
        }
      }
    }
    return spots;
  }

  Widget _buildBody() {
    final currentLapNotifier = Provider.of<CurrentLapNotifier>(context);
    final currentLap =
        currentLapNotifier.getCurrentLap(widget.season, widget.race.round);
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        if (_driverTimings.isEmpty)
          const Center(
            child: Text("No lap data for this driver"),
          ),
        Expanded(
          child: SingleChildScrollView(
            child: ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: min(_driverTimings.length, currentLap),
              itemBuilder: (context, index) {
                return ListTile(
                  leading: Text(
                    (index + 1).toString(),
                    style: const TextStyle(fontSize: 30),
                  ),
                  title:
                      Text(_driverTimings[index].time ?? "No lap data found"),
                  trailing: _driverPitStops
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
                          _driverTimings[index - 1].time ?? "NA",
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
        if (_driverTimings.isNotEmpty)
          LapSlider(
            season: widget.season,
            round: widget.race.round,
            totalLaps: _driverTimings.length,
          )
      ],
    );
  }
}
