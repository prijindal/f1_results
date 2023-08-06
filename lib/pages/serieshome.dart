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
  List<String> favorites = [];
  int _selectedIndex = 0;
  List<Race> races = [];
  bool _isLoading = true;

  @override
  initState() {
    super.initState();
    setState(() {
      _isLoading = true;
    });
    _loadSelectedDate();
    _fetchRaces();
  }

  Future<void> _fetchRaces() async {
    final races = await fetchRaces(widget.season);
    setState(() {
      this.races = races;
      _isLoading = false;
    });
  }

  Future<void> _loadSelectedDate() async {
    final sharedPreferences = await SharedPreferences.getInstance();
    final dateString =
        sharedPreferences.getString("selectedDate${widget.season}");
    if (dateString != null) {
      final date = stringToDate(dateString);
      setState(() {
        _selectedDate = date;
      });
    }
    final favorites = sharedPreferences.getStringList("favourites");
    if (favorites != null) {
      setState(() {
        this.favorites = favorites;
      });
    }
  }

  Future<void> _setFavorite() async {
    var favorites = this.favorites;
    if (favorites.contains(widget.season)) {
      favorites.remove(widget.season);
    } else {
      favorites.add(widget.season);
    }
    setState(() {
      this.favorites = favorites;
    });
    final sharedPreferences = await SharedPreferences.getInstance();
    sharedPreferences.setStringList("favourites", favorites);
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
    final dates = races.map((a) => a.date).map(stringToDate).toList();
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
          ),
          IconButton(
            onPressed: _isLoading == true ? null : _setFavorite,
            icon: favorites.contains(widget.season)
                ? const Icon(Icons.favorite)
                : const Icon(Icons.favorite_border),
          ),
        ],
      ),
      body: _isLoading
          ? const LinearProgressIndicator()
          : _widgetOptions.elementAt(_selectedIndex),
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
