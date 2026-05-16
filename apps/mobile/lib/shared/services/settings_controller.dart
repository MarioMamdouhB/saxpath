import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:saxpath_mobile/shared/education/sax_foundation_models.dart';

class SettingsController extends ChangeNotifier {
  SettingsController() {
    _load();
  }

  static const String _saxTypeKey = 'selected_sax_type';
  SaxType _saxType = SaxType.altoEb;

  SaxType get saxType => _saxType;

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    final index = prefs.getInt(_saxTypeKey) ?? SaxType.altoEb.index;
    _saxType = SaxType.values[index];
    notifyListeners();
  }

  Future<void> setSaxType(SaxType type) async {
    if (_saxType == type) return;
    _saxType = type;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_saxTypeKey, type.index);
    notifyListeners();
  }
}
