import 'dart:convert';
import 'package:http/http.dart' as http;
import '../constants/api_constants.dart';
import '../models/pesca_response_model.dart';
import '../services/date_formatter_service.dart';

class ApiService {
  static const String _url =
      "${ApiConstants.baseUrl}${ApiConstants.reportePescaEndpoint}";

  Future<PescaResponse> consultarPesca(
    String usuarioApi,
    DateTime fechaInicio,
    DateTime fechaFin,
  ) async {
    final String fechaInicioStr = DateFormatterService.toApiFormat(fechaInicio);
    final String fechaFinStr = DateFormatterService.toApiFormat(fechaFin);

    final Map<String, dynamic> payload = {
      "p_options": [],
      "options": [
        {
          "cantidad":
              "10", // Este valor parece fijo, si puede cambiar, parametrizar
          "control": "MULTIINPUT",
          "key": "FECCONMOV",
          "valueHigh": fechaFinStr,
          "valueLow": fechaInicioStr,
        },
      ],
      "p_rows": "", // Si este valor puede cambiar, parametrizar
      "p_user": usuarioApi,
    };

    // print("API Request URL: $_url");
    // print("API Request Payload: ${json.encode(payload)}");

    try {
      final response = await http
          .post(
            Uri.parse(_url),
            headers: {
              "Content-Type": "application/json;charset=UTF-8",
              "Accept": "application/json",
            },
            body: json.encode(payload),
          )
          .timeout(const Duration(seconds: 30)); // Añadir timeout

      // print("API Response Status Code: ${response.statusCode}");
      // print("API Response Body: ${response.body}");

      if (response.statusCode == 200) {
        // Decodificar UTF-8 explícitamente si hay problemas con caracteres especiales
        final decodedBody = utf8.decode(response.bodyBytes);
        return PescaResponse.fromJson(json.decode(decodedBody));
      } else {
        // Intentar decodificar el cuerpo del error si es JSON
        String errorMessage =
            'Error al consultar la API: ${response.statusCode}';
        try {
          final errorBody = json.decode(utf8.decode(response.bodyBytes));
          if (errorBody is Map && errorBody.containsKey('mensaje')) {
            errorMessage += ' - ${errorBody['mensaje']}';
          } else if (errorBody is Map &&
              errorBody.containsKey('error') &&
              errorBody['error'] is Map &&
              errorBody['error'].containsKey('message')) {
            errorMessage += ' - ${errorBody['error']['message']}';
          }
        } catch (e) {
          // Si el cuerpo del error no es JSON o no tiene el formato esperado.
          errorMessage +=
              ' (Respuesta no JSON: ${utf8.decode(response.bodyBytes).substring(0, 100)}...)';
        }
        throw Exception(errorMessage);
      }
    } catch (e) {
      // print("Error en ApiService: $e");
      throw Exception('Error de conexión o timeout: ${e.toString()}');
    }
  }
}
