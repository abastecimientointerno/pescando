import 'package:flutter/foundation.dart';
import '../services/local_storage_service.dart';

class AppConfigProvider with ChangeNotifier {
  final LocalStorageService _localStorageService;

  String? _usuarioServidor;
  double _cuotaMetaPropia = 0.0;
  double _cuotaMetaTerceros = 0.0;
  bool _isInitialSetupDone = false;
  bool _isLoading = true; // Para la carga inicial de datos de config

  AppConfigProvider(this._localStorageService) {
    _loadConfig();
  }

  // Getters
  String? get usuarioServidor => _usuarioServidor;
  double get cuotaMetaPropia => _cuotaMetaPropia;
  double get cuotaMetaTerceros => _cuotaMetaTerceros;
  bool get isInitialSetupDone => _isInitialSetupDone;
  bool get isLoading => _isLoading;
  double get cuotaMetaGeneral => _cuotaMetaPropia + _cuotaMetaTerceros;

  Future<void> _loadConfig() async {
    _isLoading = true;
    notifyListeners(); // Notificar que la carga ha comenzado

    _usuarioServidor = await _localStorageService.getUserApiKey();
    _cuotaMetaPropia = await _localStorageService.getCuotaPropia() ?? 0.0;
    _cuotaMetaTerceros = await _localStorageService.getCuotaTerceros() ?? 0.0;
    _isInitialSetupDone = await _localStorageService.isInitialSetupDone();

    _isLoading = false;
    notifyListeners();
  }

  Future<void> saveUsuarioServidor(String usuario) async {
    _usuarioServidor = usuario;
    await _localStorageService.saveUserApiKey(usuario);
    notifyListeners();
  }

  Future<void> saveCuotaMetaPropia(double cuota) async {
    _cuotaMetaPropia = cuota;
    await _localStorageService.saveCuotaPropia(cuota);
    notifyListeners();
  }

  Future<void> saveCuotaMetaTerceros(double cuota) async {
    _cuotaMetaTerceros = cuota;
    await _localStorageService.saveCuotaTerceros(cuota);
    notifyListeners();
  }

  Future<void> completeInitialSetup(
    String usuario,
    double cuotaPropia,
    double cuotaTerceros,
  ) async {
    await saveUsuarioServidor(usuario);
    await saveCuotaMetaPropia(cuotaPropia);
    await saveCuotaMetaTerceros(cuotaTerceros);
    _isInitialSetupDone = true;
    await _localStorageService.setInitialSetupDone(true);
    notifyListeners();
  }

  Future<void> resetConfig() async {
    _isLoading = true;
    notifyListeners();
    await _localStorageService.clearAllData();
    await _loadConfig(); // Recarga para reflejar el estado reseteado
    // _isLoading se pondrá a false dentro de _loadConfig
  }
}
