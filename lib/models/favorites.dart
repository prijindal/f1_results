import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../helpers/constants.dart';
import '../helpers/logger.dart';

class FavouritesNotifier with ChangeNotifier {
  List<String> favourites;

  FavouritesNotifier({this.favourites = const []}) {
    init();
  }

  void init() {
    AppLogger.instance.d("Reading $favouritesKey from shared_preferences");
    SharedPreferences.getInstance().then((instance) {
      final favourites = instance.getStringList(favouritesKey);
      if (favourites != null) {
        this.favourites = favourites;
      }
      AppLogger.instance
          .d("Read $favouritesKey as $favourites from shared_preferences");
      notifyListeners();
    });
  }

  List<String> getFavourites() => favourites;

  Future<void> toggleFavourite(String favourite) async {
    final newFavourites = favourites.toList();
    if (favourites.contains(favourite)) {
      newFavourites.remove(favourite);
    } else {
      newFavourites.add(favourite);
    }
    favourites = newFavourites;
    (await SharedPreferences.getInstance()).setStringList(
      favouritesKey,
      newFavourites,
    );
    notifyListeners();
  }
}
