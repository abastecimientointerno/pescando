import 'package:shared_preferences/shared_preferences.dart';

class LocalStorageService {
  static const String _userApiKey = 'user_api_key';
  static const String _cuotaPropiaKey = 'cuota_propia_key';
  static const String _cuotaTercerosKey = 'cuota_terceros_key';
  static const String _initialSetupDoneKey = 'initial_setup_done_key';

  Future<SharedPreferences> get _prefs async => SharedPreferences.getInstance();

  // Initial Setup Flag
  Future<void> setInitialSetupDone(bool value) async {
    final prefs = await _prefs;
    await prefs.setBool(_initialSetupDoneKey, value);
  }

  Future<bool> isInitialSetupDone() async {
    final prefs = await _prefs;
    return prefs.getBool(_initialSetupDoneKey) ?? false;
  }

  // User API Key
  Future<void> saveUserApiKey(String apiKey) async {
    final prefs = await _prefs;
    await prefs.setString(_userApiKey, apiKey);
  }

  Future<String?> getUserApiKey() async {
    final prefs = await _prefs;
    return prefs.getString(_userApiKey);
  }

  // Cuota Propia
  Future<void> saveCuotaPropia(double cuota) async {
    final prefs = await _prefs;
    await prefs.setDouble(_cuotaPropiaKey, cuota);
  }

  Future<double?> getCuotaPropia() async {
    final prefs = await _prefs;
    return prefs.getDouble(_cuotaPropiaKey);
  }

  // Cuota Terceros
  Future<void> saveCuotaTerceros(double cuota) async {
    final prefs = await _prefs;
    await prefs.setDouble(_cuotaTercerosKey, cuota);
  }

  Future<double?> getCuotaTerceros() async {
    final prefs = await _prefs;
    return prefs.getDouble(_cuotaTercerosKey);
  }

  Future<void> clearAllData() async {
    final prefs = await _prefs;
    await prefs.remove(_userApiKey);
    await prefs.remove(_cuotaPropiaKey);
    await prefs.remove(_cuotaTercerosKey);
    await prefs.remove(
      _initialSetupDoneKey,
    ); // Importante para permitir reconfiguración
  }
}
