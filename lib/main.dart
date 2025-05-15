import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'app.dart';
import 'core/api/api_service.dart';
import 'core/providers/app_config_provider.dart';
import 'core/providers/pesca_data_provider.dart';
import 'core/services/local_storage_service.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized(); // Asegura que los bindings estén inicializados

  // Instancias de servicios
  final localStorageService = LocalStorageService();
  final apiService = ApiService();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => AppConfigProvider(localStorageService),
        ),
        ChangeNotifierProvider(
          create:
              (context) => PescaDataProvider(
                apiService,
                Provider.of<AppConfigProvider>(context, listen: false),
              ),
        ),
      ],
      child: const ControlPescaApp(),
    ),
  );
}
