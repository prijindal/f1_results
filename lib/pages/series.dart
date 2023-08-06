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
  bool _isLoading = true;

  @override
  initState() {
    super.initState();
    _fetchSeries();
  }

  Future<void> _fetchSeries() async {
    setState(() {
      _isLoading = true;
    });
    await initCache();
    final seasons = await fetchSeries();
    setState(() {
      this.seasons = seasons;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Race Series"),
      ),
      body: _isLoading
          ? const LinearProgressIndicator()
          : ListView.builder(
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
