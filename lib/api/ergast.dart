import 'package:dio/dio.dart';
import 'package:dio_cache_interceptor/dio_cache_interceptor.dart';
import 'package:dio_cache_interceptor_hive_store/dio_cache_interceptor_hive_store.dart';

import '../models/result.dart';

final dio = Dio();
// Global options
final options = CacheOptions(
  // A default store is required for interceptor.
  store: HiveCacheStore(null),

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

const rootApi = "https://ergast.com/api/f1";

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

Future<List<dynamic>> fetchRaces(String season) async {
  final Response<dynamic> response =
      await dio.get("$rootApi/$season.json?limit=1000");
  final list =
      (response.data["MRData"]["RaceTable"]["Races"] as List<dynamic>).toList();
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
