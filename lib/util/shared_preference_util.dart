import 'package:shared_preferences/shared_preferences.dart';

class SharedPreferenceUtil {
  static final instance = SharedPreferenceUtil._();

  final _preferences = SharedPreferences.getInstance();

  SharedPreferenceUtil._();

  Future<double> getWindowHeight() async {
    return (await _preferences).getDouble('window_height') ?? 720.0;
  }

  Future<double> getWindowWidth() async {
    return (await _preferences).getDouble('window_width') ?? 1080.0;
  }

  Future<void> setWindowHeight(double height) async {
    await (await _preferences).setDouble('window_height', height);
  }

  Future<void> setWindowWidth(double width) async {
    await (await _preferences).setDouble('window_width', width);
  }

  Future<String?> getString(String key) async {
    return (await _preferences).getString(key);
  }

  Future<int?> getInt(String key) async {
    return (await _preferences).getInt(key);
  }

  Future<double?> getDouble(String key) async {
    return (await _preferences).getDouble(key);
  }

  Future<bool?> getBool(String key) async {
    return (await _preferences).getBool(key);
  }

  Future<void> setString(String key, String value) async {
    await (await _preferences).setString(key, value);
  }

  Future<void> setInt(String key, int value) async {
    await (await _preferences).setInt(key, value);
  }

  Future<void> setDouble(String key, double value) async {
    await (await _preferences).setDouble(key, value);
  }

  Future<void> setBool(String key, bool value) async {
    await (await _preferences).setBool(key, value);
  }

  Future<void> remove(String key) async {
    await (await _preferences).remove(key);
  }

  Future<void> clear() async {
    await (await _preferences).clear();
  }
}
