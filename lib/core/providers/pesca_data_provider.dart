import 'package:flutter/foundation.dart';
import 'package:fl_chart/fl_chart.dart'; // Necesario para FlSpot
import 'package:intl/intl.dart';
import '../api/api_service.dart';
import '../models/pesca_detalle_model.dart';
import '../models/pesca_response_model.dart';
import '../enums/tipo_propiedad.dart';
import 'app_config_provider.dart'; // Para acceder a las cuotas

class PescaData {
  final double totalPescado;
  final double porcentajeAvance;
  final List<FlSpot> pescaDiariaSpots;
  final List<FlSpot> pescaAcumuladaSpots;
  final String diasRestantesEstimados;
  final double cuotaMeta;

  PescaData({
    required this.totalPescado,
    required this.porcentajeAvance,
    required this.pescaDiariaSpots,
    required this.pescaAcumuladaSpots,
    required this.diasRestantesEstimados,
    required this.cuotaMeta,
  });
}

class PescaDataProvider with ChangeNotifier {
  final ApiService _apiService;
  final AppConfigProvider _appConfigProvider; // Para leer las cuotas

  PescaDataProvider(this._apiService, this._appConfigProvider);

  // Estado de la UI
  bool _isLoading = false;
  String? _errorMessage;
  DateTime? _fechaInicioSeleccionada;
  DateTime? _fechaFinSeleccionada;

  // Datos crudos y procesados
  List<PescaDetalleModel> _listaPescaRaw = [];

  PescaData? _datosGenerales;
  PescaData? _datosPropia;
  PescaData? _datosTerceros;

  // Getters
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  DateTime? get fechaInicioSeleccionada => _fechaInicioSeleccionada;
  DateTime? get fechaFinSeleccionada => _fechaFinSeleccionada;

  List<PescaDetalleModel> get listaPescaRaw => _listaPescaRaw;
  PescaData? get datosGenerales => _datosGenerales;
  PescaData? get datosPropia => _datosPropia;
  PescaData? get datosTerceros => _datosTerceros;

  bool get hasDataToDisplay =>
      !_isLoading && _errorMessage == null && _listaPescaRaw.isNotEmpty;
  bool get hasError => _errorMessage != null;
  bool get canPerformQuery =>
      _fechaInicioSeleccionada != null &&
      _fechaFinSeleccionada != null &&
      _appConfigProvider.usuarioServidor != null;

  void setFechas(DateTime inicio, DateTime fin) {
    _fechaInicioSeleccionada = inicio;
    _fechaFinSeleccionada = fin;
    notifyListeners();
  }

  Future<void> consultarDatosDePesca() async {
    if (!canPerformQuery) {
      _errorMessage =
          "Por favor, configure el usuario API y seleccione un rango de fechas.";
      notifyListeners();
      return;
    }

    _isLoading = true;
    _errorMessage = null;
    _listaPescaRaw = []; // Limpiar datos anteriores
    _datosGenerales = null;
    _datosPropia = null;
    _datosTerceros = null;
    notifyListeners();

    try {
      final response = await _apiService.consultarPesca(
        _appConfigProvider.usuarioServidor!,
        _fechaInicioSeleccionada!,
        _fechaFinSeleccionada!,
      );

      if (response.mensaje.toUpperCase() == "OK") {
        _listaPescaRaw = response.detalles;
        _procesarDatosPesca();
      } else {
        _errorMessage = response.mensaje;
      }
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void _procesarDatosPesca() {
    if (_listaPescaRaw.isEmpty) {
      _datosGenerales = _crearPescaDataVacia(
        _appConfigProvider.cuotaMetaGeneral,
      );
      _datosPropia = _crearPescaDataVacia(_appConfigProvider.cuotaMetaPropia);
      _datosTerceros = _crearPescaDataVacia(
        _appConfigProvider.cuotaMetaTerceros,
      );
      return;
    }

    // Filtrar por tipo
    final List<PescaDetalleModel> pescaPropia =
        _listaPescaRaw
            .where((p) => p.tipoPropiedad == TipoPropiedad.propia)
            .toList();
    final List<PescaDetalleModel> pescaTerceros =
        _listaPescaRaw
            .where((p) => p.tipoPropiedad == TipoPropiedad.tercero)
            .toList();

    _datosGenerales = _calcularPescaData(
      _listaPescaRaw,
      _appConfigProvider.cuotaMetaGeneral,
    );
    _datosPropia = _calcularPescaData(
      pescaPropia,
      _appConfigProvider.cuotaMetaPropia,
    );
    _datosTerceros = _calcularPescaData(
      pescaTerceros,
      _appConfigProvider.cuotaMetaTerceros,
    );
  }

  PescaData _crearPescaDataVacia(double cuotaMeta) {
    return PescaData(
      totalPescado: 0,
      porcentajeAvance: 0,
      pescaDiariaSpots: [],
      pescaAcumuladaSpots: [],
      diasRestantesEstimados: cuotaMeta > 0 ? "N/A" : "Meta 0",
      cuotaMeta: cuotaMeta,
    );
  }

  PescaData _calcularPescaData(
    List<PescaDetalleModel> detalles,
    double cuotaMeta,
  ) {
    if (detalles.isEmpty) return _crearPescaDataVacia(cuotaMeta);

    double totalPescado = detalles.fold(
      0.0,
      (sum, item) => sum + item.cantidadPesca,
    );
    double porcentajeAvance =
        (cuotaMeta > 0) ? (totalPescado / cuotaMeta * 100).clamp(0, 100) : 0.0;

    // 1. Agrupar pesca por día
    Map<DateTime, double> pescaPorDia = {};
    for (var detalle in detalles) {
      // Normalizar la fecha a medianoche para agrupar correctamente por día
      DateTime dia = DateTime(
        detalle.fechaDescarga.year,
        detalle.fechaDescarga.month,
        detalle.fechaDescarga.day,
      );
      pescaPorDia[dia] = (pescaPorDia[dia] ?? 0) + detalle.cantidadPesca;
    }

    // 2. Ordenar por fecha y crear spots para gráfico diario
    List<MapEntry<DateTime, double>> sortedPescaDiaria =
        pescaPorDia.entries.toList()..sort((a, b) => a.key.compareTo(b.key));

    List<FlSpot> pescaDiariaSpots = [];
    if (sortedPescaDiaria.isNotEmpty) {
      // Para el eje X, usamos un índice o el timestamp
      // Usaremos un índice para simplicidad, y las etiquetas del eje X pueden mostrar las fechas.
      for (int i = 0; i < sortedPescaDiaria.length; i++) {
        pescaDiariaSpots.add(FlSpot(i.toDouble(), sortedPescaDiaria[i].value));
      }
    }

    // 3. Calcular pesca acumulada y crear spots
    List<FlSpot> pescaAcumuladaSpots = [];
    double acumulado = 0;
    if (sortedPescaDiaria.isNotEmpty) {
      for (int i = 0; i < sortedPescaDiaria.length; i++) {
        acumulado += sortedPescaDiaria[i].value;
        pescaAcumuladaSpots.add(FlSpot(i.toDouble(), acumulado));
      }
    }

    // 4. Calcular días restantes estimados
    String diasRestantesEstimados = "N/A";
    if (cuotaMeta > 0 && totalPescado < cuotaMeta) {
      if (sortedPescaDiaria.isNotEmpty && totalPescado > 0) {
        // Usar solo los días dentro del rango seleccionado para el promedio
        final diasConPescaEnRango = sortedPescaDiaria.length;
        if (diasConPescaEnRango > 0) {
          double promedioPescaDiaria = totalPescado / diasConPescaEnRango;
          if (promedioPescaDiaria > 0) {
            double diasNecesarios =
                (cuotaMeta - totalPescado) / promedioPescaDiaria;
            diasRestantesEstimados = "${diasNecesarios.ceil()} días";
          }
        }
      }
    } else if (totalPescado >= cuotaMeta && cuotaMeta > 0) {
      diasRestantesEstimados = "Meta Alcanzada";
    } else if (cuotaMeta == 0) {
      diasRestantesEstimados = "Meta 0";
    }

    return PescaData(
      totalPescado: totalPescado,
      porcentajeAvance: porcentajeAvance,
      pescaDiariaSpots: pescaDiariaSpots,
      pescaAcumuladaSpots: pescaAcumuladaSpots,
      diasRestantesEstimados: diasRestantesEstimados,
      cuotaMeta: cuotaMeta,
    );
  }

  // Método para obtener las etiquetas de fecha para el eje X de los gráficos de líneas
  List<String> getFechasEjeX(PescaData? data) {
    if (data == null || data.pescaDiariaSpots.isEmpty || _listaPescaRaw.isEmpty)
      return [];

    // Reconstruir las fechas a partir de los datos originales ordenados
    Map<DateTime, double> pescaPorDia = {};
    List<PescaDetalleModel> dataSource;
    if (data == _datosGenerales)
      dataSource = _listaPescaRaw;
    else if (data == _datosPropia)
      dataSource =
          _listaPescaRaw
              .where((p) => p.tipoPropiedad == TipoPropiedad.propia)
              .toList();
    else if (data == _datosTerceros)
      dataSource =
          _listaPescaRaw
              .where((p) => p.tipoPropiedad == TipoPropiedad.tercero)
              .toList();
    else
      return [];

    for (var detalle in dataSource) {
      DateTime dia = DateTime(
        detalle.fechaDescarga.year,
        detalle.fechaDescarga.month,
        detalle.fechaDescarga.day,
      );
      pescaPorDia[dia] = (pescaPorDia[dia] ?? 0) + detalle.cantidadPesca;
    }

    // AQUÍ ESTÁ EL ERROR CORREGIDO:
    List<DateTime> sortedFechas =
        pescaPorDia.keys.toList()..sort((a, b) => a.compareTo(b));

    // Formatear las fechas para mostrarlas. Puede que necesites mostrar menos etiquetas si hay muchos puntos.
    return sortedFechas
        .map((fecha) => DateFormat('dd/MM').format(fecha))
        .toList();
  }

  void clearData() {
    _isLoading = false;
    _errorMessage = null;
    _listaPescaRaw = [];
    _datosGenerales = null;
    _datosPropia = null;
    _datosTerceros = null;
    // No limpiamos las fechas seleccionadas aquí, el usuario podría querer re-consultar
    notifyListeners();
  }
}
