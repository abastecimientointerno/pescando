import 'dart:convert';
import 'pesca_detalle_model.dart';

PescaResponse pescaResponseFromJson(String str) =>
    PescaResponse.fromJson(json.decode(str));

class PescaResponse {
  final List<PescaDetalleModel> detalles;
  final String mensaje;

  PescaResponse({required this.detalles, required this.mensaje});

  factory PescaResponse.fromJson(Map<String, dynamic> json) {
    var list = json['str_des'] as List<dynamic>? ?? [];
    List<PescaDetalleModel> detallesList =
        list.map((i) => PescaDetalleModel.fromJson(i)).toList();

    return PescaResponse(
      detalles: detallesList,
      mensaje: json['mensaje'] as String? ?? 'Error: Mensaje no encontrado',
    );
  }
}
