import 'package:flutter/material.dart';

import '../models/result.dart';
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
    return <Widget>[
      QualifyingList(
        season: widget.season,
        race: widget.race,
      ),
      RaceResultList(
        season: widget.season,
        race: widget.race,
      )
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("${widget.race.season} - ${widget.race.raceName}"),
      ),
      body: _widgetOptions.elementAt(_selectedIndex),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.flag_outlined),
            label: 'Qualifying',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.flag_circle),
            label: 'Results',
          ),
          // BottomNavigationBarItem(
          //   icon: Icon(Icons.flag),
          //   label: 'Laps',
          // ),
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
