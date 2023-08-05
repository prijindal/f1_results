import 'package:flutter/material.dart';

import '../models/result.dart';
import 'race.dart';

class RacesList extends StatefulWidget {
  const RacesList({
    super.key,
    required this.season,
    required this.races,
    required this.selectedDate,
  });

  final String season;
  final List<Race> races;
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
          title: Text(widget.races[index].raceName),
          subtitle: Text(widget.races[index].date),
          enabled: widget.selectedDate
                  .compareTo(stringToDate(widget.races[index].date)) >=
              0,
          onTap: () {
            Navigator.of(context).push(
              MaterialPageRoute<void>(
                builder: (BuildContext context) => RacePage(
                  season: widget.season,
                  race: widget.races[index],
                ),
              ),
            );
          },
        );
      },
    );
  }
}
