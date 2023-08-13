class RaceResult {
  final String number;
  final int position;
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
      position: int.parse(json['position'] as String),
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
  final String? rank;
  final String? lap;
  final Time? time;
  final AverageSpeed? averageSpeed;

  FastestLap({
    required this.rank,
    required this.lap,
    required this.time,
    required this.averageSpeed,
  });

  factory FastestLap.fromJson(Map<String, dynamic> json) {
    return FastestLap(
      rank: json['rank'] == null ? null : json['rank'] as String,
      lap: json['lap'] == null ? null : json['lap'] as String,
      time: json['Time'] == null
          ? null
          : Time.fromJson(json['Time'] as Map<String, dynamic>),
      averageSpeed: json['AverageSpeed'] == null
          ? null
          : AverageSpeed.fromJson(json['AverageSpeed'] as Map<String, dynamic>),
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
  final int position;
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
      position: int.parse(json['position'] as String),
      driver: Driver.fromJson(json['Driver'] as Map<String, dynamic>),
      constructor:
          Constructor.fromJson(json['Constructor'] as Map<String, dynamic>),
      q1: json['Q1'] == null ? null : json['Q1'] as String,
      q2: json['Q2'] == null ? null : json['Q2'] as String,
      q3: json['Q3'] == null ? null : json['Q3'] as String,
    );
  }
}

class Session {
  String? date;
  String? time;

  Session({
    required this.date,
    required this.time,
  });

  factory Session.fromJson(Map<String, dynamic> json) {
    return Session(
      date: json['date'] == null ? null : json['date'] as String,
      time: json['time'] == null ? null : json['time'] as String,
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
  Session? sprint;

  Race({
    required this.season,
    required this.round,
    required this.url,
    required this.raceName,
    required this.circuit,
    required this.date,
    required this.time,
    required this.sprint,
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
      sprint: json['Sprint'] == null
          ? null
          : Session.fromJson(json["Sprint"] as Map<String, dynamic>),
    );
  }
}

class ResultsRace extends Race {
  List<RaceResult>? results;
  List<RaceResult>? sprintResults;

  List<RaceResult> get allResults {
    final List<RaceResult> allResults = [];
    if (results != null) {
      allResults.addAll(results!);
    }
    if (sprintResults != null) {
      allResults.addAll(sprintResults!);
    }
    return allResults;
  }

  ResultsRace({
    required String season,
    required String round,
    required String url,
    required String raceName,
    required RaceCircuit circuit,
    required String date,
    required String? time,
    required Session? sprint,
    required this.results,
    required this.sprintResults,
  }) : super(
          season: season,
          round: round,
          url: url,
          raceName: raceName,
          circuit: circuit,
          date: date,
          time: time,
          sprint: sprint,
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
      results: json['Results'] == null
          ? null
          : (json['Results'] as List<dynamic>)
              .map((result) =>
                  RaceResult.fromJson(result as Map<String, dynamic>))
              .toList(),
      sprintResults: json['SprintResults'] == null
          ? null
          : (json['SprintResults'] as List<dynamic>)
              .map((result) =>
                  RaceResult.fromJson(result as Map<String, dynamic>))
              .toList(),
      sprint: json['Sprint'] == null
          ? null
          : Session.fromJson(json["Sprint"] as Map<String, dynamic>),
    );
  }
}

class RaceLap {
  int number;
  List<Timing> timings;

  RaceLap({
    required this.number,
    required this.timings,
  });

  factory RaceLap.fromJson(Map<String, dynamic> json) {
    return RaceLap(
      number: json['number'] == null ? 0 : int.parse(json['number'] as String),
      timings: json['Timings'] == null
          ? []
          : (json['Timings'] as List<dynamic>)
              .map((timingJson) =>
                  Timing.fromJson(timingJson as Map<String, dynamic>))
              .toList(),
    );
  }
}

class Timing {
  String? driverId;
  int position;
  String? time;

  Timing({
    required this.driverId,
    required this.position,
    required this.time,
  });

  factory Timing.fromJson(Map<String, dynamic> json) {
    return Timing(
      driverId: json['driverId'] == null ? null : json['driverId'] as String,
      position: int.parse(json['position'] as String),
      time: json['time'] == null ? null : json['time'] as String,
    );
  }
}

class PitStop {
  String driverId;
  int lap;
  String stop;
  String time;
  String duration;

  PitStop({
    required this.driverId,
    required this.lap,
    required this.stop,
    required this.time,
    required this.duration,
  });

  factory PitStop.fromJson(Map<String, dynamic> json) {
    return PitStop(
      driverId: json["driverId"] as String,
      lap: int.parse(json["lap"] as String),
      stop: json["stop"] as String,
      time: json["time"] as String,
      duration: json["duration"] as String,
    );
  }
}

DateTime stringToDate(String e) {
  final split = e.split("-").map((a) => int.parse(a)).toList();
  return DateTime(split[0], split[1], split[2]);
}

DateTime stringToTime(String e) {
  final splitted = e.split(":");
  int minutes = 0;
  int seconds = 0;
  int ms = 0;
  if (splitted.length > 1) {
    final secondsSplitted = splitted[splitted.length - 1].split(".");
    minutes = int.parse(splitted[0]);
    if (secondsSplitted.length > 1) {
      seconds = int.parse(secondsSplitted[0]);
      ms = int.parse(secondsSplitted[1]);
    }
  }
  return DateTime.now()
      .copyWith(minute: minutes, second: seconds, millisecond: ms);
}
