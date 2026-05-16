import 'package:shared_preferences/shared_preferences.dart';
import 'package:saxpath_mobile/shared/education/sax_foundation_models.dart';

class SettingsService {
  static const String _saxTypeKey = 'selected_sax_type';

  Future<SaxType> getSelectedSaxType() async {
    final prefs = await SharedPreferences.getInstance();
    final index = prefs.getInt(_saxTypeKey) ?? SaxType.altoEb.index;
    return SaxType.values[index];
  }

  Future<void> setSelectedSaxType(SaxType type) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_saxTypeKey, type.index);
  }
}
