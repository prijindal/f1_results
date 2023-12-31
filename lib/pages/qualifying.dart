import 'package:flutter/material.dart';

import '../api/ergast.dart';
import '../components/drivername.dart';
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
  bool _isLoading = true;

  @override
  initState() {
    super.initState();
    _fetchQualifyingResults();
  }

  Future<void> _fetchQualifyingResults() async {
    setState(() {
      _isLoading = true;
    });
    final qualifyingResults =
        await fetchQualifyingResults(widget.season, widget.race.round);
    if (context.mounted) {
      setState(() {
        this.qualifyingResults = qualifyingResults;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return _isLoading
        ? const LinearProgressIndicator()
        : ListView.builder(
            itemCount: qualifyingResults.length,
            itemBuilder: (context, index) {
              return ListTile(
                leading: Text(
                  (index + 1).toString(),
                  style: const TextStyle(fontSize: 30),
                ),
                title: DriverName(
                  driver: qualifyingResults[index].driver,
                  constructor: qualifyingResults[index].constructor,
                ),
                subtitle: Text(qualifyingResults[index].bestTime),
              );
            },
          );
  }
}
