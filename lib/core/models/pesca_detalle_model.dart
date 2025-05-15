import 'package:intl/intl.dart';
import '../enums/tipo_propiedad.dart';

class PescaDetalleModel {
  final DateTime fechaDescarga;
  final TipoPropiedad tipoPropiedad;
  final String descTipoPropiedad;
  final double cantidadPesca; // CNPDS
  final String centro; // WERKS
  final String? cdEmb; // Código de embarcación
  final String? nmEmb; // Nombre de embarcación

  PescaDetalleModel({
    required this.fechaDescarga,
    required this.tipoPropiedad,
    required this.descTipoPropiedad,
    required this.cantidadPesca,
    required this.centro,
    this.cdEmb,
    this.nmEmb,
  });

  factory PescaDetalleModel.fromJson(Map<String, dynamic> json) {
    // Asumimos que FIDES es "DD/MM/YYYY"
    DateTime parsedDate;
    try {
      parsedDate = DateFormat(
        'dd/MM/yyyy',
      ).parse(json['FIDES'] as String? ?? '');
    } catch (e) {
      // Si hay un error de parseo o FIDES es nulo/vacío, usamos una fecha por defecto o manejamos el error.
      // Aquí, para simplicidad, usaremos la fecha actual, pero en producción podrías querer un manejo más robusto.
      // O lanzar una excepción si la fecha es crítica y siempre debe estar presente.
      // print('Error parseando fecha FIDES: ${json['FIDES']}, usando fecha actual. Error: $e');
      parsedDate = DateTime.now(); // Considera un mejor manejo aquí
    }

    // Asumimos que CNPDS es un string como "30.400" que representa 30.4
    // Si el formato es "30,400" para 30400, o "30.400,50" para 30400.50, el parseo necesita ajustes.
    double parsedCantidad = 0.0;
    if (json['CNPDS'] != null && (json['CNPDS'] as String).isNotEmpty) {
      // String cantidadStr = (json['CNPDS'] as String).replaceAll('.', '').replaceAll(',', '.'); // Para formatos como "1.234,56"
      String cantidadStr = (json['CNPDS'] as String).replaceAll(
        ',',
        '',
      ); // Para formatos como "30.400" o "30,400" (quitamos comas de miles)
      // Si el punto es miles y coma decimal, la lógica cambia.
      // Para "30.400" (treinta punto cuatrocientos), esto funciona.
      parsedCantidad = double.tryParse(cantidadStr) ?? 0.0;
    }

    return PescaDetalleModel(
      fechaDescarga: parsedDate,
      tipoPropiedad: tipoPropiedadFromString(json['INPRP'] as String?),
      descTipoPropiedad: json['DESC_INPRP'] as String? ?? 'N/A',
      cantidadPesca: parsedCantidad,
      centro: json['WERKS'] as String? ?? 'N/A',
      cdEmb: json['CDEMB'] as String?,
      nmEmb: json['NMEMB'] as String?,
    );
  }

  @override
  String toString() {
    return 'PescaDetalleModel(fecha: $fechaDescarga, tipo: $tipoPropiedad, cantidad: $cantidadPesca, centro: $centro)';
  }
}
