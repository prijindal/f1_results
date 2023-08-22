import 'package:flutter/material.dart';

import '../api/ergast.dart';
import '../models/result.dart';
import 'constructorsstadings.dart';
import 'driverstandings.dart';

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
  List<ResultsRace> resultsRace = [];
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
    final List<ResultsRace> results = ([
      ...mainResults,
      ...sprintResults,
    ]..sort((a, b) {
            return a.date.compareTo(b.date);
          }))
        .toList();
    if (context.mounted) {
      setState(() {
        resultsRace = results;
        _isLoading = false;
      });
    }
  }

  List<ConstructorStanding> get constructorStandings {
    final Map<String, ConstructorStanding> constructorStandings = {};
    for (var race in resultsRace) {
      for (var result in race.allResults) {
        final constructor = result.constructor;
        if (constructorStandings[constructor.constructorId] == null) {
          constructorStandings[constructor.constructorId] = ConstructorStanding(
            constructor: constructor,
          );
        }
      }
    }
    for (var race in resultsRace) {
      if (widget.selectedDate.compareTo(stringToDate(race.date)) >= 0) {
        for (var result in race.allResults) {
          constructorStandings[result.constructor.constructorId]?.points +=
              double.parse(result.points);
        }
      }
    }
    return (constructorStandings.values.toList()
          ..sort((a, b) => a.points.compareTo(b.points)))
        .reversed
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    return _isLoading
        ? const LinearProgressIndicator()
        : widget.standingType == StandingType.constructor
            ? ConstructorStandingsList(
                constructorStandings: constructorStandings,
              )
            : DriverStandingsList(
                season: widget.season,
                resultsRace: resultsRace,
                selectedDate: widget.selectedDate,
              );
  }
}
