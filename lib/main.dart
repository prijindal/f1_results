import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'components/notransitiononweb.dart';
import 'models/current_lap.dart';
import 'models/favorites.dart';
import 'models/theme.dart';
import 'pages/series.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<ThemeModeNotifier>(
          create: (context) => ThemeModeNotifier(ThemeMode.system),
        ),
        ChangeNotifierProvider<FavouritesNotifier>(
          create: (context) => FavouritesNotifier(),
        ),
        ChangeNotifierProvider<CurrentLapNotifier>(
          create: (context) => CurrentLapNotifier(),
        ),
      ],
      child: const MyMaterialApp(),
    );
  }
}

class MyMaterialApp extends StatelessWidget {
  const MyMaterialApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    final themeNotifier = Provider.of<ThemeModeNotifier>(context);
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
        pageTransitionsTheme: NoTransitionsOnWeb(),
      ),
      darkTheme: ThemeData.dark(
        useMaterial3: true,
      ).copyWith(
        useMaterial3: true,
        pageTransitionsTheme: NoTransitionsOnWeb(),
      ),
      themeMode: themeNotifier.getTheme(),
      home: const SeriesListPage(),
    );
  }
}
