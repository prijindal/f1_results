import 'package:flutter/material.dart';

class CurrentLapNotifier with ChangeNotifier {
  final Map<String, int> _currentLapMap = {};

  int getCurrentLap(String season, String round) =>
      _currentLapMap["$season-$round"] ?? 0;

  void setCurrentLap(String season, String round, int lap) {
    _currentLapMap.update(
      "$season-$round",
      (value) => lap,
      ifAbsent: () => lap,
    );
    notifyListeners();
  }
}
