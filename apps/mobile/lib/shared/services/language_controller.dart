import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LanguageController extends ChangeNotifier {
  LanguageController() {
    _load();
  }

  static const String _langKey = 'app_language';
  Locale _locale = const Locale('ar');

  Locale get locale => _locale;

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    final langCode = prefs.getString(_langKey) ?? 'ar';
    _locale = Locale(langCode);
    notifyListeners();
  }

  Future<void> setLanguage(String langCode) async {
    if (_locale.languageCode == langCode) return;
    _locale = Locale(langCode);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_langKey, langCode);
    notifyListeners();
  }

  String translate(String ar, String en) {
    return _locale.languageCode == 'ar' ? ar : en;
  }
}
