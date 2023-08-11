import 'dart:convert';
import 'dart:io';

import 'package:f1_results/models/result.dart';
import 'package:flutter_test/flutter_test.dart';

void main() async {
  test("Test if parsing for race results works", () async {
    var myFile = File('test/results.json');
    final string = await myFile.readAsString();
    final json = jsonDecode(string);
    final races = (json["MRData"]["RaceTable"]["Races"] as List<dynamic>)
        .map(
          (e) => ResultsRace.fromJson(e as Map<String, dynamic>),
        )
        .toList();
    // ignore: avoid_print
    expect(races.length, 22);
  });
}
