import 'package:flutter/material.dart';

import '../models/result.dart';

class RacesList extends StatefulWidget {
  const RacesList({
    super.key,
    required this.season,
    required this.races,
    required this.selectedDate,
  });

  final String season;
  final List<dynamic> races;
  final DateTime selectedDate;

  @override
  State<RacesList> createState() => _RacesListState();
}

class _RacesListState extends State<RacesList> {
  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: widget.races.length,
      itemBuilder: (context, index) {
        return ListTile(
          title: Text(widget.races[index]["raceName"] as String),
          subtitle: Text(widget.races[index]["date"] as String),
          enabled: widget.selectedDate.compareTo(
                  stringToDate(widget.races[index]["date"] as String)) >=
              0,
          // onTap: () {},
        );
      },
    );
  }
}
