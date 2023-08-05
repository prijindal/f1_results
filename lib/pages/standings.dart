import 'package:flutter/material.dart';

import '../api/ergast.dart';
import '../models/result.dart';

class Standing<T> {
  final T data;
  double points;

  Standing({
    required this.data,
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
  List<Standing<Constructor>> constructorStandings = [];
  List<Standing<Driver>> driverStandings = [];

  @override
  initState() {
    super.initState();
    _fetchSeries();
  }

  Future<void> _fetchSeries() async {
    final results = await fetchResults(widget.season);
    final Map<String, Standing<Constructor>> constructorStandings = {};
    final Map<String, Standing<Driver>> driverStandings = {};
    for (var race in results) {
      if (widget.selectedDate.compareTo(stringToDate(race.date)) >= 0) {
        for (var result in race.results) {
          final constructor = result.constructor;
          final driver = result.driver;
          if (constructorStandings[constructor.constructorId] == null) {
            constructorStandings[constructor.constructorId] =
                Standing<Constructor>(
              data: constructor,
            );
          }
          if (driverStandings[driver.driverId] == null) {
            driverStandings[driver.driverId] = Standing<Driver>(
              data: driver,
            );
          }
          constructorStandings[constructor.constructorId]?.points +=
              double.parse(result.points);
          driverStandings[driver.driverId]?.points +=
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
    });
  }

  Widget _buildConstructors() {
    return ListView.builder(
      itemCount: constructorStandings.length,
      itemBuilder: (context, index) {
        return ListTile(
          title: Text(constructorStandings[index].data.name),
          trailing: Text(constructorStandings[index].points.toString()),
          onTap: () {},
        );
      },
    );
  }

  Widget _buildDrivers() {
    return ListView.builder(
      itemCount: driverStandings.length,
      itemBuilder: (context, index) {
        return ListTile(
          title: Text(driverStandings[index].data.givenName),
          trailing: Text(driverStandings[index].points.toString()),
          onTap: () {},
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return widget.standingType == StandingType.constructor
        ? _buildConstructors()
        : _buildDrivers();
  }
}
