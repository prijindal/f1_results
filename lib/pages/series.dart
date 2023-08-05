import 'package:flutter/material.dart';

import './serieshome.dart';
import '../api/ergast.dart';

class SeriesListPage extends StatefulWidget {
  const SeriesListPage({super.key});

  @override
  State<SeriesListPage> createState() => _SeriesListPageState();
}

class _SeriesListPageState extends State<SeriesListPage> {
  List<String> seasons = [];

  @override
  initState() {
    super.initState();
    _fetchSeries();
  }

  Future<void> _fetchSeries() async {
    final seasons = await fetchSeries();
    setState(() {
      this.seasons = seasons;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Race Series"),
      ),
      body: ListView.builder(
        itemCount: seasons.length,
        itemBuilder: (context, index) {
          return ListTile(
            title: Text(seasons[index]),
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (BuildContext context) => SeriesHomePage(
                    season: seasons[index],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
