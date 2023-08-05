import 'package:flutter/material.dart';

import '../api/ergast.dart';
import '../models/result.dart';

class RaceResultList extends StatefulWidget {
  const RaceResultList({
    super.key,
    required this.season,
    required this.race,
  });

  final String season;
  final Race race;

  @override
  State<RaceResultList> createState() => RaceResultListState();
}

class RaceResultListState extends State<RaceResultList> {
  List<RaceResult> raceResults = [];

  @override
  initState() {
    super.initState();
    _fetchRaceResult();
  }

  Future<void> _fetchRaceResult() async {
    final raceResults = await fetchRaceResult(widget.season, widget.race.round);
    setState(() {
      this.raceResults = raceResults;
    });
  }

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: raceResults.length,
      itemBuilder: (context, index) {
        return ListTile(
          title: Text(raceResults[index].driver.code ??
              raceResults[index].driver.givenName),
          subtitle: Text(raceResults[index].points),
        );
      },
    );
  }
}
