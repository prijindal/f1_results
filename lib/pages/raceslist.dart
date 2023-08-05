import 'package:flutter/material.dart';

import '../api/ergast.dart';

class RacesList extends StatefulWidget {
  const RacesList({super.key, required this.season});

  final String season;

  @override
  State<RacesList> createState() => _RacesListState();
}

class _RacesListState extends State<RacesList> {
  List<dynamic> races = [];

  @override
  initState() {
    super.initState();
    _fetchSeries();
  }

  Future<void> _fetchSeries() async {
    final races = await fetchRaces(widget.season);
    setState(() {
      this.races = races;
    });
  }

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: races.length,
      itemBuilder: (context, index) {
        return ListTile(
          title: Text(races[index]["raceName"] as String),
          onTap: () {
            // Navigator.of(context).push(
            //   MaterialPageRoute<void>(
            //     builder: (BuildContext context) => SeriesHomePage(
            //       season: seasons[index],
            //     ),
            //   ),
            // );
          },
        );
      },
    );
  }
}
