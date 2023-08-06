import 'package:flutter/material.dart';

import '../components/drivername.dart';
import '../models/result.dart';

class RaceResultList extends StatefulWidget {
  const RaceResultList({
    super.key,
    required this.season,
    required this.race,
    required this.fetchRaceResult,
  });

  final String season;
  final Race race;
  final Future<List<RaceResult>> Function(String season, String round)
      fetchRaceResult;

  @override
  State<RaceResultList> createState() => RaceResultListState();
}

class RaceResultListState extends State<RaceResultList> {
  List<RaceResult> raceResults = [];
  bool _isLoading = true;

  @override
  initState() {
    super.initState();
    _fetchRaceResult();
  }

  Future<void> _fetchRaceResult() async {
    setState(() {
      _isLoading = true;
    });
    final raceResults =
        await widget.fetchRaceResult(widget.season, widget.race.round);
    setState(() {
      this.raceResults = raceResults;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return _isLoading
        ? const LinearProgressIndicator()
        : ListView.builder(
            itemCount: raceResults.length,
            itemBuilder: (context, index) {
              return ListTile(
                leading: Text(
                  (index + 1).toString(),
                  style: const TextStyle(fontSize: 30),
                ),
                title: DriverName(
                  driver: raceResults[index].driver,
                  constructor: raceResults[index].constructor,
                ),
                subtitle: Text(raceResults[index].points),
              );
            },
          );
  }
}
