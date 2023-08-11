import 'dart:io';

import 'package:easy_debounce/easy_throttle.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:quick_actions/quick_actions.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../helpers/constants.dart';
import '../helpers/logger.dart';
import '../pages/serieshome.dart';

const favouritesShortcut = "favourites";

const QuickActions quickActions = QuickActions();

void handleQuickActions(BuildContext context) {
  if (kIsWeb || !(Platform.isAndroid || Platform.isIOS)) {
    return;
  }
  quickActions.initialize((type) async {
    EasyThrottle.throttle(
      "quick-action-handler",
      const Duration(seconds: 10),
      () {
        if (type.startsWith("$favouritesShortcut:")) {
          final season = type.split("$favouritesShortcut:")[1];
          Navigator.of(context).push(
            MaterialPageRoute<void>(
              builder: (BuildContext context) => SeriesHomePage(
                season: season,
              ),
            ),
          );
        }
      },
    );
  });
}

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
    _addQuickActions();
  }

  Future<void> _addQuickActions() async {
    if (kIsWeb || !(Platform.isAndroid || Platform.isIOS)) {
      return;
    }
    final List<ShortcutItem> shortcuts = [];
    for (final favourite in favourites) {
      final type = "$favouritesShortcut:$favourite";
      final localizedTitle = "$favourite Season";
      shortcuts.add(ShortcutItem(type: type, localizedTitle: localizedTitle));
    }
    quickActions.setShortcutItems(shortcuts);
  }
}
