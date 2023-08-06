import 'package:flutter/material.dart';

import '../api/ergast.dart';
import '../models/result.dart';

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

class ConstructorStanding {
  final Constructor constructor;

  double points;

  ConstructorStanding({
    required this.constructor,
    this.points = 0.0,
  });
}

enum StandingType {
  driver,
  constructor,
}

class StandingsList extends StatefulWidget {
  const StandingsList({
    super.key,
    required this.season,
    required this.standingType,
    required this.selectedDate,
  });

  final String season;
  final StandingType standingType;
  final DateTime selectedDate;

  @override
  State<StandingsList> createState() => _StandingsListState();
}

class _StandingsListState extends State<StandingsList> {
  List<ConstructorStanding> constructorStandings = [];
  List<DriverStanding> driverStandings = [];
  bool _isLoading = true;

  @override
  initState() {
    super.initState();
    _fetchSeries();
  }

  Future<void> _fetchSeries() async {
    setState(() {
      _isLoading = true;
    });
    final mainResults = await fetchResults(widget.season);
    final sprintResults = await fetchSprintResults(widget.season);
    final List<ResultsRace> results = [
      ...mainResults,
      ...sprintResults,
    ];
    final Map<String, ConstructorStanding> constructorStandings = {};
    final Map<String, DriverStanding> driverStandings = {};
    for (var race in results) {
      for (var result in race.allResults) {
        final constructor = result.constructor;
        final driver = result.driver;
        if (constructorStandings[constructor.constructorId] == null) {
          constructorStandings[constructor.constructorId] = ConstructorStanding(
            constructor: constructor,
          );
        }
        if (driverStandings[driver.driverId] == null) {
          driverStandings[driver.driverId] = DriverStanding(
            driver: driver,
            constructor: constructor,
          );
        }
      }
    }
    for (var race in results) {
      if (widget.selectedDate.compareTo(stringToDate(race.date)) >= 0) {
        for (var result in race.allResults) {
          constructorStandings[result.constructor.constructorId]?.points +=
              double.parse(result.points);
          driverStandings[result.driver.driverId]?.points +=
              double.parse(result.points);
        }
      }
    }
    setState(() {
      this.constructorStandings = (constructorStandings.values.toList()
            ..sort((a, b) => a.points.compareTo(b.points)))
          .reversed
          .toList();
      this.driverStandings = (driverStandings.values.toList()
            ..sort((a, b) => a.points.compareTo(b.points)))
          .reversed
          .toList();
      _isLoading = false;
    });
  }

  Widget _buildConstructors() {
    return ListView.builder(
      itemCount: constructorStandings.length,
      itemBuilder: (context, index) {
        return ListTile(
          title: Text(constructorStandings[index].constructor.name),
          trailing: Text(constructorStandings[index].points.toString()),
        );
      },
    );
  }

  Widget _buildDrivers() {
    return ListView.builder(
      itemCount: driverStandings.length,
      itemBuilder: (context, index) {
        return ListTile(
          title: Text(
              "${driverStandings[index].driver.givenName} ${driverStandings[index].driver.familyName}"),
          subtitle: Text(driverStandings[index].constructor.name),
          trailing: Text(driverStandings[index].points.toString()),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return _isLoading
        ? const LinearProgressIndicator()
        : widget.standingType == StandingType.constructor
            ? _buildConstructors()
            : _buildDrivers();
  }
}
