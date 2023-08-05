import 'package:flutter/material.dart';

import 'raceslist.dart';
import 'standings.dart';

class SeriesHomePage extends StatefulWidget {
  const SeriesHomePage({super.key, required this.season});

  final String season;

  @override
  State<SeriesHomePage> createState() => _SeriesHomePageState();
}

class _SeriesHomePageState extends State<SeriesHomePage> {
  int _selectedIndex = 0;

  List<Widget> get _widgetOptions {
    return <Widget>[
      RacesList(season: widget.season),
      StandingsList(
        season: widget.season,
        standingType: StandingType.driver,
      ),
      StandingsList(
        season: widget.season,
        standingType: StandingType.constructor,
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("${widget.season} Season"),
      ),
      body: _widgetOptions.elementAt(_selectedIndex),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Races',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.business),
            label: 'Driver Standings',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.business),
            label: 'Constructor Standings',
          ),
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
