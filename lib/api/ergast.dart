import 'package:dio/dio.dart';
import 'package:dio_cache_interceptor/dio_cache_interceptor.dart';
import 'package:dio_cache_interceptor_hive_store/dio_cache_interceptor_hive_store.dart';
import 'package:path_provider/path_provider.dart';

import '../models/result.dart';

final dio = Dio();

const rootApi = "https://ergast.com/api/f1";

Future<void> initCache() async {
  String? dir;
  try {
    var cacheDir = await getTemporaryDirectory();
    dir = cacheDir.path;
  } catch (e) {
    dir = null;
  }
// Global options
  final options = CacheOptions(
    // A default store is required for interceptor.
    store: HiveCacheStore(
      dir,
      hiveBoxName: "f1_results",
    ),

    // All subsequent fields are optional.

    // Default.
    policy: CachePolicy.request,
    // Returns a cached response on error but for statuses 401 & 403.
    // Also allows to return a cached response on network errors (e.g. offline usage).
    // Defaults to [null].
    hitCacheOnErrorExcept: [401, 403],
    // Overrides any HTTP directive to delete entry past this duration.
    // Useful only when origin server has no cache config or custom behaviour is desired.
    // Defaults to [null].
    maxStale: const Duration(days: 7),
    // Default. Allows 3 cache sets and ease cleanup.
    priority: CachePriority.normal,
    // Default. Body and headers encryption with your own algorithm.
    cipher: null,
    // Default. Key builder to retrieve requests.
    keyBuilder: CacheOptions.defaultCacheKeyBuilder,
    // Default. Allows to cache POST requests.
    // Overriding [keyBuilder] is strongly recommended when [true].
    allowPostMethod: false,
  );
  dio.interceptors.add(DioCacheInterceptor(options: options));
}

Future<List<String>> fetchSeries() async {
  final Response<dynamic> response =
      await dio.get("$rootApi/seasons.json?limit=1000");
  final list = (response.data["MRData"]["SeasonTable"]["Seasons"]
          as List<dynamic>)
      .map((e) => e["season"] as String)
      .toList()
    ..sort();
  return list.reversed.toList();
}

Future<List<Race>> fetchRaces(String season) async {
  final Response<dynamic> response =
      await dio.get("$rootApi/$season.json?limit=1000");
  final list = (response.data["MRData"]["RaceTable"]["Races"] as List<dynamic>)
      .map((e) => Race.fromJson(e as Map<String, dynamic>))
      .toList();
  return list;
}

Future<List<ResultsRace>> fetchResults(String season) async {
  final Response<dynamic> response =
      await dio.get("$rootApi/$season/results.json?limit=1000");
  final list = (response.data["MRData"]["RaceTable"]["Races"] as List<dynamic>)
      .map(
        (e) => ResultsRace.fromJson(e as Map<String, dynamic>),
      )
      .toList();
  return list;
}

Future<List<ResultsRace>> fetchSprintResults(String season) async {
  final Response<dynamic> response =
      await dio.get("$rootApi/$season/sprint.json?limit=1000");
  final list = (response.data["MRData"]["RaceTable"]["Races"] as List<dynamic>)
      .map(
        (e) => ResultsRace.fromJson(e as Map<String, dynamic>),
      )
      .toList();
  return list;
}

Future<List<QualifyingResult>> fetchQualifyingResults(
    String season, String round) async {
  final Response<dynamic> response =
      await dio.get("$rootApi/$season/$round/qualifying.json?limit=1000");
  final list =
      (response.data["MRData"]["RaceTable"]["Races"] as List<dynamic>).toList();
  if (list.isNotEmpty) {
    final qualifyingResult = list.first["QualifyingResults"] as List<dynamic>;
    return qualifyingResult
        .map((e) => QualifyingResult.fromJson(e as Map<String, dynamic>))
        .toList();
  }
  return [];
}

Future<List<RaceResult>> fetchRaceResult(String season, String round) async {
  final Response<dynamic> response =
      await dio.get("$rootApi/$season/$round/results.json?limit=1000");
  final list =
      (response.data["MRData"]["RaceTable"]["Races"] as List<dynamic>).toList();
  if (list.isNotEmpty) {
    final result = list.first["Results"] as List<dynamic>;
    return result
        .map((e) => RaceResult.fromJson(e as Map<String, dynamic>))
        .toList();
  }
  return [];
}
