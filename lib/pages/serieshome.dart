import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../api/ergast.dart';
import '../models/result.dart';
import 'raceslist.dart';
import 'standings.dart';

class SeriesHomePage extends StatefulWidget {
  const SeriesHomePage({super.key, required this.season});

  final String season;

  @override
  State<SeriesHomePage> createState() => _SeriesHomePageState();
}

class _SeriesHomePageState extends State<SeriesHomePage> {
  DateTime? _selectedDate;
  int _selectedIndex = 0;
  List<dynamic> races = [];

  @override
  initState() {
    super.initState();
    _loadSelectedDate();
    _fetchSeries();
  }

  Future<void> _fetchSeries() async {
    final races = await fetchRaces(widget.season);
    setState(() {
      this.races = races;
    });
  }

  Future<void> _loadSelectedDate() async {
    final dateString = (await SharedPreferences.getInstance())
        .getString("selectedDate${widget.season}");
    if (dateString != null) {
      final date = stringToDate(dateString);
      setState(() {
        _selectedDate = date;
      });
    }
  }

  Future<void> _setSelectedDate(DateTime date) async {
    setState(() {
      _selectedDate = date;
    });
    final dateString = "${date.year}-${date.month}-${date.day}";
    (await SharedPreferences.getInstance())
        .setString("selectedDate${widget.season}", dateString);
  }

  List<Widget> get _widgetOptions {
    return <Widget>[
      RacesList(
        season: widget.season,
        races: races,
        selectedDate: _selectedDate ??
            (selectableDates.isNotEmpty
                ? selectableDates.last
                : DateTime.now()),
      ),
      StandingsList(
        season: widget.season,
        standingType: StandingType.driver,
        selectedDate: _selectedDate ??
            (selectableDates.isNotEmpty
                ? selectableDates.last
                : DateTime.now()),
      ),
      StandingsList(
        season: widget.season,
        standingType: StandingType.constructor,
        selectedDate: _selectedDate ??
            (selectableDates.isNotEmpty
                ? selectableDates.last
                : DateTime.now()),
      ),
    ];
  }

  List<DateTime> get selectableDates {
    final dates =
        races.map((a) => a["date"] as String).map(stringToDate).toList();
    if (dates.isNotEmpty) {
      dates.add(dates.first.copyWith(day: dates.first.day - 7));
    }
    return dates..sort((a, b) => a.compareTo(b));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("${widget.season} Season"),
        actions: [
          IconButton(
            onPressed: selectableDates.isEmpty
                ? null
                : () async {
                    final date = await showDatePicker(
                      context: context,
                      initialDate: _selectedDate ?? selectableDates.last,
                      firstDate: selectableDates.first,
                      lastDate: selectableDates.last,
                      selectableDayPredicate: (date) {
                        return selectableDates.contains(date);
                      },
                    );
                    if (date != null) {
                      _setSelectedDate(date);
                    }
                  },
            icon: const Icon(Icons.calendar_month),
          )
        ],
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
