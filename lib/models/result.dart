class RaceResult {
  final String number;
  final String position;
  final String positionText;
  final String points;
  final Driver driver;
  final Constructor constructor;
  final String grid;
  final String laps;
  final String status;
  final FastestLap? fastestLap;

  RaceResult({
    required this.number,
    required this.position,
    required this.positionText,
    required this.points,
    required this.driver,
    required this.constructor,
    required this.grid,
    required this.laps,
    required this.status,
    required this.fastestLap,
  });

  factory RaceResult.fromJson(Map<String, dynamic> json) {
    return RaceResult(
      number: json['number'] as String,
      position: json['position'] as String,
      positionText: json['positionText'] as String,
      points: json['points'] as String,
      driver: Driver.fromJson(json['Driver'] as Map<String, dynamic>),
      constructor:
          Constructor.fromJson(json['Constructor'] as Map<String, dynamic>),
      grid: json['grid'] as String,
      laps: json['laps'] as String,
      status: json['status'] as String,
      fastestLap: json['FastestLap'] == null
          ? null
          : FastestLap.fromJson(json['FastestLap'] as Map<String, dynamic>),
    );
  }
}

class Driver {
  final String driverId;
  final String? permanentNumber;
  final String? code;
  final String url;
  final String givenName;
  final String familyName;
  final String dateOfBirth;
  final String nationality;

  Driver({
    required this.driverId,
    required this.permanentNumber,
    required this.code,
    required this.url,
    required this.givenName,
    required this.familyName,
    required this.dateOfBirth,
    required this.nationality,
  });

  factory Driver.fromJson(Map<String, dynamic> json) {
    return Driver(
      driverId: json['driverId'] as String,
      permanentNumber: json['permanentNumber'] == null
          ? null
          : json['permanentNumber'] as String,
      code: json['code'] == null ? null : json['code'] as String,
      url: json['url'] as String,
      givenName: json['givenName'] as String,
      familyName: json['familyName'] as String,
      dateOfBirth: json['dateOfBirth'] as String,
      nationality: json['nationality'] as String,
    );
  }
}

class Constructor {
  final String constructorId;
  final String url;
  final String name;
  final String nationality;

  Constructor({
    required this.constructorId,
    required this.url,
    required this.name,
    required this.nationality,
  });

  factory Constructor.fromJson(Map<String, dynamic> json) {
    return Constructor(
      constructorId: json['constructorId'] as String,
      url: json['url'] as String,
      name: json['name'] as String,
      nationality: json['nationality'] as String,
    );
  }
}

class Time {
  final String time;

  Time({
    required this.time,
  });

  factory Time.fromJson(Map<String, dynamic> json) {
    return Time(
      time: json['time'] as String,
    );
  }
}

class FastestLap {
  final String rank;
  final String lap;
  final Time time;
  final AverageSpeed averageSpeed;

  FastestLap({
    required this.rank,
    required this.lap,
    required this.time,
    required this.averageSpeed,
  });

  factory FastestLap.fromJson(Map<String, dynamic> json) {
    return FastestLap(
      rank: json['rank'] as String,
      lap: json['lap'] as String,
      time: Time.fromJson(json['Time'] as Map<String, dynamic>),
      averageSpeed:
          AverageSpeed.fromJson(json['AverageSpeed'] as Map<String, dynamic>),
    );
  }
}

class AverageSpeed {
  final String units;
  final String speed;

  AverageSpeed({
    required this.units,
    required this.speed,
  });

  factory AverageSpeed.fromJson(Map<String, dynamic> json) {
    return AverageSpeed(
      units: json['units'] as String,
      speed: json['speed'] as String,
    );
  }
}

class RaceCircuit {
  String circuitId;
  String url;
  String circuitName;

  RaceCircuit({
    required this.circuitId,
    required this.url,
    required this.circuitName,
  });

  factory RaceCircuit.fromJson(Map<String, dynamic> json) {
    return RaceCircuit(
      circuitId: json['circuitId'] as String,
      url: json['url'] as String,
      circuitName: json['circuitName'] as String,
    );
  }
}

class QualifyingResult {
  final String number;
  final String position;
  final Driver driver;
  final Constructor constructor;
  final String? q1;
  final String? q2;
  final String? q3;

  String get bestTime {
    return q3 ?? q2 ?? q1 ?? "NA";
  }

  QualifyingResult({
    required this.number,
    required this.position,
    required this.driver,
    required this.constructor,
    required this.q1,
    required this.q2,
    required this.q3,
  });

  factory QualifyingResult.fromJson(Map<String, dynamic> json) {
    return QualifyingResult(
      number: json['number'] as String,
      position: json['position'] as String,
      driver: Driver.fromJson(json['Driver'] as Map<String, dynamic>),
      constructor:
          Constructor.fromJson(json['Constructor'] as Map<String, dynamic>),
      q1: json['Q1'] == null ? null : json['Q1'] as String,
      q2: json['Q2'] == null ? null : json['Q2'] as String,
      q3: json['Q3'] == null ? null : json['Q3'] as String,
    );
  }
}

class Race {
  String season;
  String round;
  String url;
  String raceName;
  RaceCircuit circuit;
  String date;
  String? time;

  Race({
    required this.season,
    required this.round,
    required this.url,
    required this.raceName,
    required this.circuit,
    required this.date,
    required this.time,
  });

  factory Race.fromJson(Map<String, dynamic> json) {
    return Race(
      season: json['season'] as String,
      round: json['round'] as String,
      url: json['url'] as String,
      raceName: json['raceName'] as String,
      circuit: RaceCircuit.fromJson(json['Circuit'] as Map<String, dynamic>),
      date: json['date'] as String,
      time: json['time'] == null ? null : json['time'] as String,
    );
  }
}

class ResultsRace extends Race {
  List<RaceResult> results;

  ResultsRace({
    required String season,
    required String round,
    required String url,
    required String raceName,
    required RaceCircuit circuit,
    required String date,
    required String? time,
    required this.results,
  }) : super(
          season: season,
          round: round,
          url: url,
          raceName: raceName,
          circuit: circuit,
          date: date,
          time: time,
        );

  factory ResultsRace.fromJson(Map<String, dynamic> json) {
    return ResultsRace(
      season: json['season'] as String,
      round: json['round'] as String,
      url: json['url'] as String,
      raceName: json['raceName'] as String,
      circuit: RaceCircuit.fromJson(json['Circuit'] as Map<String, dynamic>),
      date: json['date'] as String,
      time: json['time'] == null ? null : json['time'] as String,
      results: (json['Results'] as List<dynamic>)
          .map((result) => RaceResult.fromJson(result as Map<String, dynamic>))
          .toList(),
    );
  }
}

DateTime stringToDate(String e) {
  final split = e.split("-").map((a) => int.parse(a)).toList();
  return DateTime(split[0], split[1], split[2]);
}
