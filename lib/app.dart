import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'core/providers/app_config_provider.dart';
import 'presentation/screens/initial_setup_screen.dart';
import 'presentation/screens/main_navigation_screen.dart'; // Crearemos esta pantalla en la parte 2

class ControlPescaApp extends StatelessWidget {
  const ControlPescaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Control Pesca',
      debugShowCheckedModeBanner: false,
      home: Consumer<AppConfigProvider>(
        builder: (context, appConfig, child) {
          if (appConfig.isLoading) {
            return const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );
          }
          // Si la configuración inicial no está hecha O el usuario API es nulo (ej. después de un reset)
          if (!appConfig.isInitialSetupDone ||
              appConfig.usuarioServidor == null) {
            return const InitialSetupScreen(); // Crearemos esta pantalla en la parte 2
          } else {
            return const MainNavigationScreen(); // Crearemos esta pantalla en la parte 2
          }
        },
      ),
    );
  }
}
