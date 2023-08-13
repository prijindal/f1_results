import 'package:flutter/material.dart';

class CurrentLapNotifier with ChangeNotifier {
  final Map<String, int> _currentLapMap = {};

  int getCurrentLap(String season) => _currentLapMap[season] ?? 0;

  void setCurrentLap(String season, int lap) {
    _currentLapMap.update(
      season,
      (value) => lap,
      ifAbsent: () => lap,
    );
    notifyListeners();
  }
}
