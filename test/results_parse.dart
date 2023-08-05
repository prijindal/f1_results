import 'dart:convert';
import 'dart:io';

import 'package:f1_results/models/result.dart';

void main() async {
  var myFile = File('test/results.json');
  final string = await myFile.readAsString();
  final json = jsonDecode(string);
  final races = (json["MRData"]["RaceTable"]["Races"] as List<dynamic>)
      .map(
        (e) => ResultsRace.fromJson(e as Map<String, dynamic>),
      )
      .toList();
  print(races.length);
}
