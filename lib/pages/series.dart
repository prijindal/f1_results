import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import './serieshome.dart';
import '../api/ergast.dart';
import '../models/favorites.dart';
import 'profile.dart';

class SeriesListPage extends StatefulWidget {
  const SeriesListPage({super.key});

  @override
  State<SeriesListPage> createState() => _SeriesListPageState();
}

class _SeriesListPageState extends State<SeriesListPage> {
  List<String> seasons = [];
  bool _isLoading = true;

  @override
  initState() {
    super.initState();
    setState(() {
      _isLoading = true;
    });
    _fetchSeries();
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
    final favouritesNotifier = Provider.of<FavouritesNotifier>(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text("Race Series"),
        actions: [
          IconButton(
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (BuildContext context) => const ProfileScreen(),
                ),
              );
            },
            icon: const Icon(Icons.person),
          ),
        ],
      ),
      body: ListView(
        children: [
          if (_isLoading) const LinearProgressIndicator(),
          ExpansionTile(
            title: const Text("Favorites"),
            initiallyExpanded: true,
            children: favouritesNotifier
                .getFavourites()
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
