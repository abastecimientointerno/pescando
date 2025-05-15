import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../core/providers/app_config_provider.dart';
import '../widgets/custom_card.dart'; // Reutilizando CustomCard

class InitialSetupScreen extends StatefulWidget {
  const InitialSetupScreen({super.key});

  @override
  State<InitialSetupScreen> createState() => _InitialSetupScreenState();
}

class _InitialSetupScreenState extends State<InitialSetupScreen> {
  final _formKey = GlobalKey<FormState>();
  final _usuarioController = TextEditingController();
  final _cuotaPropiaController = TextEditingController();
  final _cuotaTercerosController = TextEditingController();

  @override
  void dispose() {
    _usuarioController.dispose();
    _cuotaPropiaController.dispose();
    _cuotaTercerosController.dispose();
    super.dispose();
  }

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      final appConfig = Provider.of<AppConfigProvider>(context, listen: false);
      final usuario = _usuarioController.text.trim();
      final cuotaPropia = double.tryParse(_cuotaPropiaController.text) ?? 0.0;
      final cuotaTerceros =
          double.tryParse(_cuotaTercerosController.text) ?? 0.0;

      appConfig.completeInitialSetup(usuario, cuotaPropia, cuotaTerceros);
      // La navegación se manejará por el Consumer en app.dart
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20.0),
          child: CustomCard(
            // Usando CustomCard para un look consistente
            margin: const EdgeInsets.all(
              0,
            ), // Sin margen para que ocupe el centro
            padding: const EdgeInsets.all(24.0),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  Text(
                    'Configuración Inicial',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Por favor, ingresa los datos requeridos para comenzar.',
                    style: Theme.of(context).textTheme.bodyMedium,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),
                  TextFormField(
                    controller: _usuarioController,
                    decoration: const InputDecoration(
                      labelText: 'Usuario Servidor (p_user)',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.person_outline),
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Por favor, ingresa el usuario del servidor.';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _cuotaPropiaController,
                    decoration: const InputDecoration(
                      labelText: 'Cuota Propia (Tn)',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.directions_boat_outlined),
                    ),
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*')),
                    ],
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Ingresa la cuota propia (0 si no aplica).';
                      }
                      if (double.tryParse(value) == null) {
                        return 'Ingresa un número válido.';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _cuotaTercerosController,
                    decoration: const InputDecoration(
                      labelText: 'Cuota Terceros (Tn)',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.group_outlined),
                    ),
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*')),
                    ],
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Ingresa la cuota de terceros (0 si no aplica).';
                      }
                      if (double.tryParse(value) == null) {
                        return 'Ingresa un número válido.';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: _submitForm,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16.0),
                      textStyle: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    child: const Text('Guardar y Continuar'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
