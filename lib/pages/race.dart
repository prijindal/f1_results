import 'package:flutter/material.dart';

import '../api/ergast.dart';
import '../models/result.dart';
import 'laps.dart';
import 'qualifying.dart';
import 'raceresult.dart';

class RacePage extends StatefulWidget {
  const RacePage({
    super.key,
    required this.season,
    required this.race,
  });

  final String season;
  final Race race;

  @override
  State<RacePage> createState() => _RacePageState();
}

class _RacePageState extends State<RacePage> {
  int _selectedIndex = 0;

  List<Widget> get _widgetOptions {
    final widgets = <Widget>[
      QualifyingList(
        season: widget.season,
        race: widget.race,
      ),
    ];
    if (widget.race.sprint != null) {
      widgets.add(
        RaceResultList(
          key: Key("${widget.season}-${widget.race.round}-sprint"),
          season: widget.season,
          race: widget.race,
          fetchRaceResult: fetchSprintResult,
        ),
      );
    }
    widgets.add(
      RaceResultList(
        key: Key("${widget.season}-${widget.race.round}-race"),
        season: widget.season,
        race: widget.race,
        fetchRaceResult: fetchRaceResult,
      ),
    );
    widgets.add(
      RaceLapsView(
        season: widget.season,
        race: widget.race,
      ),
    );
    return widgets;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("${widget.race.season} - ${widget.race.raceName}"),
      ),
      body: _widgetOptions.elementAt(_selectedIndex),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        items: <BottomNavigationBarItem>[
          const BottomNavigationBarItem(
            icon: Icon(Icons.flag_outlined),
            label: 'Qualifying',
          ),
          if (widget.race.sprint != null)
            const BottomNavigationBarItem(
              icon: Icon(Icons.flag_circle),
              label: 'Sprint',
            ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.flag_circle),
            label: 'Results',
          ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.flag),
            label: 'Laps',
          ),
          // BottomNavigationBarItem(
          //   icon: Icon(Icons.car_rental),
          //   label: 'Pit Stops',
          // ),
        ],
        currentIndex: _selectedIndex,
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
      ),
    );
  }
}
