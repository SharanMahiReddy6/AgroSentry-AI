import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

final preferencesServiceProvider = Provider<PreferencesService>((ref) {
  throw UnimplementedError('Must be initialized before app start');
});

class PreferencesService {
  final SharedPreferences _prefs;

  PreferencesService(this._prefs);

  static const String _themeKey = 'app_theme';
  static const String _langKey = 'app_lang';

  Future<void> saveTheme(String theme) async {
    await _prefs.setString(_themeKey, theme);
  }

  String? getTheme() {
    return _prefs.getString(_themeKey);
  }

  Future<void> saveLanguage(String lang) async {
    await _prefs.setString(_langKey, lang);
  }

  String? getLanguage() {
    return _prefs.getString(_langKey);
  }
}
