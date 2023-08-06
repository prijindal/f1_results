import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import './serieshome.dart';
import '../api/ergast.dart';

class SeriesListPage extends StatefulWidget {
  const SeriesListPage({super.key});

  @override
  State<SeriesListPage> createState() => _SeriesListPageState();
}

class _SeriesListPageState extends State<SeriesListPage> {
  List<String> seasons = [];
  List<String> favorites = [];
  bool _isLoading = true;

  @override
  initState() {
    super.initState();
    setState(() {
      _isLoading = true;
    });
    _loadFavorites();
    _fetchSeries();
  }

  Future<void> _loadFavorites() async {
    final sharedPreferences = await SharedPreferences.getInstance();
    final favorites = sharedPreferences.getStringList("favourites");
    if (favorites != null) {
      setState(() {
        this.favorites = (favorites..sort()).reversed.toList();
      });
    }
  }

  Future<void> _fetchSeries() async {
    await initCache();
    final seasons = await fetchSeries();
    setState(() {
      this.seasons = seasons;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    _loadFavorites();
    return Scaffold(
      appBar: AppBar(
        title: const Text("Race Series"),
      ),
      body: _isLoading
          ? const LinearProgressIndicator()
          : ListView(
              children: [
                ExpansionTile(
                  title: const Text("Favorites"),
                  initiallyExpanded: true,
                  children: favorites
                      .map(
                        (season) => _SeriesListTile(
                          season: season,
                        ),
                      )
                      .toList(),
                ),
                ExpansionTile(
                  title: const Text("Seasons"),
                  initiallyExpanded: true,
                  children: seasons
                      .map(
                        (season) => _SeriesListTile(
                          season: season,
                        ),
                      )
                      .toList(),
                ),
              ],
            ),
    );
  }
}

class _SeriesListTile extends StatelessWidget {
  const _SeriesListTile({required this.season});

  final String season;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(season),
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute<void>(
            builder: (BuildContext context) => SeriesHomePage(
              season: season,
            ),
          ),
        );
      },
    );
  }
}
