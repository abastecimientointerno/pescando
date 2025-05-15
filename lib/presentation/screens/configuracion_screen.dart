import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../core/providers/app_config_provider.dart';
import '../../core/providers/pesca_data_provider.dart'; // Para limpiar datos al resetear
import '../widgets/custom_card.dart';

class ConfiguracionScreen extends StatefulWidget {
  const ConfiguracionScreen({super.key});

  @override
  State<ConfiguracionScreen> createState() => _ConfiguracionScreenState();
}

class _ConfiguracionScreenState extends State<ConfiguracionScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _usuarioController;
  late TextEditingController _cuotaPropiaController;
  late TextEditingController _cuotaTercerosController;

  bool _isEditing = false;

  @override
  void initState() {
    super.initState();
    final appConfig = Provider.of<AppConfigProvider>(context, listen: false);
    _usuarioController = TextEditingController(
      text: appConfig.usuarioServidor ?? '',
    );
    _cuotaPropiaController = TextEditingController(
      text: appConfig.cuotaMetaPropia.toString(),
    );
    _cuotaTercerosController = TextEditingController(
      text: appConfig.cuotaMetaTerceros.toString(),
    );
  }

  @override
  void dispose() {
    _usuarioController.dispose();
    _cuotaPropiaController.dispose();
    _cuotaTercerosController.dispose();
    super.dispose();
  }

  void _toggleEdit() {
    setState(() {
      _isEditing = !_isEditing;
      if (!_isEditing) {
        // Si se cancela la edición, restaurar valores
        final appConfig = Provider.of<AppConfigProvider>(
          context,
          listen: false,
        );
        _usuarioController.text = appConfig.usuarioServidor ?? '';
        _cuotaPropiaController.text = appConfig.cuotaMetaPropia.toString();
        _cuotaTercerosController.text = appConfig.cuotaMetaTerceros.toString();
      }
    });
  }

  Future<void> _saveChanges() async {
    if (_formKey.currentState!.validate()) {
      final appConfig = Provider.of<AppConfigProvider>(context, listen: false);
      final scaffoldMessenger = ScaffoldMessenger.of(context);

      await appConfig.saveUsuarioServidor(_usuarioController.text.trim());
      await appConfig.saveCuotaMetaPropia(
        double.tryParse(_cuotaPropiaController.text) ?? 0.0,
      );
      await appConfig.saveCuotaMetaTerceros(
        double.tryParse(_cuotaTercerosController.text) ?? 0.0,
      );

      setState(() {
        _isEditing = false;
      });
      scaffoldMessenger.showSnackBar(
        const SnackBar(
          content: Text('Configuración guardada exitosamente.'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  Future<void> _resetAppConfirmation() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Restablecer Configuración'),
          content: const Text(
            '¿Estás seguro de que deseas borrar toda la configuración y los datos locales? Deberás configurar la app nuevamente.',
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancelar'),
              onPressed: () => Navigator.of(context).pop(false),
            ),
            TextButton(
              style: TextButton.styleFrom(foregroundColor: Colors.red),
              child: const Text('Restablecer'),
              onPressed: () => Navigator.of(context).pop(true),
            ),
          ],
        );
      },
    );

    if (confirmed == true) {
      final appConfig = Provider.of<AppConfigProvider>(context, listen: false);
      final pescaData = Provider.of<PescaDataProvider>(context, listen: false);
      await appConfig.resetConfig();
      pescaData.clearData(); // Limpia los datos de pesca en el provider
      // La navegación a InitialSetupScreen se manejará por el Consumer en app.dart
      // debido al cambio en appConfig.isInitialSetupDone
    }
  }

  @override
  Widget build(BuildContext context) {
    // final appConfig = Provider.of<AppConfigProvider>(context); // Ya no es necesario si solo se usa en initState y save

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                CustomCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Parámetros de Configuración',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: 20),
                      _buildTextFormField(
                        controller: _usuarioController,
                        label: 'Usuario Servidor (p_user)',
                        icon: Icons.person_outline,
                        validator: (value) {
                          if (value == null || value.trim().isEmpty)
                            return 'Campo requerido.';
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      _buildTextFormField(
                        controller: _cuotaPropiaController,
                        label: 'Cuota Propia (Tn)',
                        icon: Icons.directions_boat_outlined,
                        keyboardType: const TextInputType.numberWithOptions(
                          decimal: true,
                        ),
                        inputFormatters: [
                          FilteringTextInputFormatter.allow(
                            RegExp(r'^\d*\.?\d*'),
                          ),
                        ],
                        validator: (value) {
                          if (value == null || value.isEmpty)
                            return 'Campo requerido (0 si no aplica).';
                          if (double.tryParse(value) == null)
                            return 'Número inválido.';
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      _buildTextFormField(
                        controller: _cuotaTercerosController,
                        label: 'Cuota Terceros (Tn)',
                        icon: Icons.group_outlined,
                        keyboardType: const TextInputType.numberWithOptions(
                          decimal: true,
                        ),
                        inputFormatters: [
                          FilteringTextInputFormatter.allow(
                            RegExp(r'^\d*\.?\d*'),
                          ),
                        ],
                        validator: (value) {
                          if (value == null || value.isEmpty)
                            return 'Campo requerido (0 si no aplica).';
                          if (double.tryParse(value) == null)
                            return 'Número inválido.';
                          return null;
                        },
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                if (_isEditing)
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: _toggleEdit, // Cancelar
                          child: const Text('Cancelar'),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: _saveChanges,
                          child: const Text('Guardar Cambios'),
                        ),
                      ),
                    ],
                  )
                else
                  ElevatedButton.icon(
                    icon: const Icon(Icons.edit_outlined),
                    label: const Text('Editar Configuración'),
                    onPressed: _toggleEdit,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12.0),
                    ),
                  ),
                const SizedBox(height: 30),
                const Divider(),
                const SizedBox(height: 10),
                Text(
                  'Acciones Avanzadas',
                  style: Theme.of(
                    context,
                  ).textTheme.titleMedium?.copyWith(color: Colors.grey[700]),
                ),
                const SizedBox(height: 10),
                OutlinedButton.icon(
                  icon: const Icon(
                    Icons.warning_amber_outlined,
                    color: Colors.red,
                  ),
                  label: const Text(
                    'Restablecer Configuración de App',
                    style: TextStyle(color: Colors.red),
                  ),
                  onPressed: _resetAppConfirmation,
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Colors.red),
                    padding: const EdgeInsets.symmetric(vertical: 12.0),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextFormField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType? keyboardType,
    List<TextInputFormatter>? inputFormatters,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      enabled: _isEditing,
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
        prefixIcon: Icon(icon),
        filled: !_isEditing, // Color de fondo cuando no se edita
        fillColor: !_isEditing ? Colors.grey[200] : null,
      ),
      keyboardType: keyboardType,
      inputFormatters: inputFormatters,
      validator: validator,
      style: TextStyle(color: _isEditing ? null : Colors.grey[700]),
    );
  }
}
