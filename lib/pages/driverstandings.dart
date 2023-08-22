import 'package:flutter/material.dart';

import '../models/result.dart';
import 'standingschart.dart';

class DriverStanding {
  final Driver driver;
  final Constructor constructor;
  double points;

  DriverStanding({
    required this.driver,
    required this.constructor,
    this.points = 0.0,
  });
}

class DriverStandingsList extends StatefulWidget {
  const DriverStandingsList({
    super.key,
    required this.season,
    required this.resultsRace,
    required this.selectedDate,
  });

  final String season;
  final List<ResultsRace> resultsRace;
  final DateTime selectedDate;

  @override
  State<DriverStandingsList> createState() => _DriverStandingsListState();
}

class _DriverStandingsListState extends State<DriverStandingsList> {
  List<String> _selectedDrivers = [];

  List<DriverStanding> get driverStandings {
    final Map<String, DriverStanding> driverStandings = {};
    for (var race in widget.resultsRace) {
      for (var result in race.allResults) {
        final constructor = result.constructor;
        final driver = result.driver;
        if (driverStandings[driver.driverId] == null) {
          driverStandings[driver.driverId] = DriverStanding(
            driver: driver,
            constructor: constructor,
          );
        }
      }
    }
    for (var race in widget.resultsRace) {
      if (widget.selectedDate.compareTo(stringToDate(race.date)) >= 0) {
        for (var result in race.allResults) {
          driverStandings[result.driver.driverId]?.points +=
              double.parse(result.points);
        }
      }
    }
    return (driverStandings.values.toList()
          ..sort((a, b) => a.points.compareTo(b.points)))
        .reversed
        .toList();
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

  List<double> _getDriverPoints(String driverId) {
    final List<double> points = [];
    double totalPoints = 0;
    for (var race in widget.resultsRace) {
      // result
      if (widget.selectedDate.compareTo(stringToDate(race.date)) >= 0) {
        double point = 0;
        for (final result in race.allResults) {
          if (result.driver.driverId == driverId) {
            point += double.parse(result.points);
          }
        }
        totalPoints += point;
        points.add(totalPoints);
      }
    }
    return points;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Flexible(
          child: SingleChildScrollView(
            child: ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: driverStandings.length,
              itemBuilder: (context, index) {
                final standing = driverStandings[index];
                return ListTile(
                  leading: Text(
                    (index + 1).toString(),
                    style: const TextStyle(fontSize: 30),
                  ),
                  selected: _selectedDrivers.contains(standing.driver.driverId),
                  title: Text(standing.driver.driverName),
                  subtitle: Text(standing.constructor.name),
                  trailing: Text(standing.points.toString()),
                  onTap: () {
                    if (_selectedDrivers.isNotEmpty) {
                      _selectDriver(standing.driver.driverId);
                      return;
                    }
                    Navigator.of(context).push(
                      MaterialPageRoute<void>(
                        builder: (context) => DriverStandingsChart(
                          season: widget.season,
                          driverStandingsChartData: {
                            standing.driver.driverId: DriverStandingGraphData(
                              points:
                                  _getDriverPoints(standing.driver.driverId),
                              color: Colors.green,
                            ),
                          },
                        ),
                      ),
                    );
                  },
                  onLongPress: () {
                    _selectDriver(standing.driver.driverId);
                  },
                );
              },
            ),
          ),
        ),
        if (_selectedDrivers.isNotEmpty)
          TextButton(
            onPressed: () {
              final Map<String, DriverStandingGraphData>
                  driverStandingsChartArray = {};
              final List<Color> availableColors = [
                Colors.green,
                Colors.red,
                Colors.amber,
                Colors.blue,
                Colors.deepOrange
              ];
              for (var i = 0; i < _selectedDrivers.length; i++) {
                final selectedDriver = _selectedDrivers[i];
                driverStandingsChartArray[selectedDriver] =
                    DriverStandingGraphData(
                  points: _getDriverPoints(selectedDriver),
                  color: i < availableColors.length ? availableColors[i] : null,
                );
              }
              Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (context) => DriverStandingsChart(
                    driverStandingsChartData: driverStandingsChartArray,
                    season: widget.season,
                  ),
                ),
              );
            },
            child: const Text("Difference"),
          ),
      ],
    );
  }
}
