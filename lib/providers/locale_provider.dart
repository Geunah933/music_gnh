import 'package:flutter/material.dart';
import '../core/database/hive_init.dart';
import '../core/database/hive_boxes.dart';

/// Manages the app locale (EN/ID) and persists it in Hive.
class LocaleProvider extends ChangeNotifier {
  Locale _locale = const Locale('en');

  LocaleProvider() {
    _loadFromHive();
  }

  Locale get locale => _locale;

  void _loadFromHive() {
    final box = HiveInit.settingsBox;
    final stored = box.get(HiveBoxes.locale, defaultValue: 'en') as String;
    _locale = Locale(stored);
  }

  void setLocale(Locale locale) {
    if (_locale == locale) return;
    _locale = locale;
    HiveInit.settingsBox.put(HiveBoxes.locale, locale.languageCode);
    notifyListeners();
  }

  /// Toggle between EN and ID.
  void toggleLocale() {
    setLocale(_locale.languageCode == 'en'
        ? const Locale('id')
        : const Locale('en'));
  }
}
