import 'package:flutter/material.dart';

import '../api/ergast.dart';
import '../models/result.dart';

class QualifyingList extends StatefulWidget {
  const QualifyingList({
    super.key,
    required this.season,
    required this.race,
  });

  final String season;
  final Race race;

  @override
  State<QualifyingList> createState() => QualifyingListState();
}

class QualifyingListState extends State<QualifyingList> {
  List<QualifyingResult> qualifyingResults = [];

  @override
  initState() {
    super.initState();
    _fetchQualifyingResults();
  }

  Future<void> _fetchQualifyingResults() async {
    final qualifyingResults =
        await fetchQualifyingResults(widget.season, widget.race.round);
    setState(() {
      this.qualifyingResults = qualifyingResults;
    });
  }

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: qualifyingResults.length,
      itemBuilder: (context, index) {
        return ListTile(
          title: Text(qualifyingResults[index].driver.code ??
              qualifyingResults[index].driver.givenName),
          subtitle: Text(qualifyingResults[index].bestTime),
        );
      },
    );
  }
}
