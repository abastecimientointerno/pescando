import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:pescando/presentation/widgets/fishing_summary_card.dart';
import 'package:provider/provider.dart';
import '../../core/providers/app_config_provider.dart';
import '../../core/providers/pesca_data_provider.dart';
import '../widgets/date_range_selector_widget.dart';
import '../widgets/line_chart_card.dart';
import '../widgets/no_data_found_widget.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final ScrollController _scrollController = ScrollController();
  bool _isAppBarExpanded = true;

  @override
  void initState() {
    super.initState();
    // Añadir listener para detectar cuando el AppBar se expande o colapsa
    _scrollController.addListener(_onScroll);

    // Cargar datos iniciales si las fechas ya están seleccionadas o establecer fechas por defecto
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final pescaProvider = Provider.of<PescaDataProvider>(
        context,
        listen: false,
      );
      if (pescaProvider.fechaInicioSeleccionada == null ||
          pescaProvider.fechaFinSeleccionada == null) {
        final now = DateTime.now();
        final firstDayOfMonth = DateTime(now.year, now.month, 1);
        pescaProvider.setFechas(firstDayOfMonth, now);
      }
    });
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.hasClients) {
      final isAppBarExpanded = _scrollController.offset <= 0;
      if (isAppBarExpanded != _isAppBarExpanded) {
        setState(() {
          _isAppBarExpanded = isAppBarExpanded;
        });
      }
    }
  }

  void _fetchData() {
    Provider.of<PescaDataProvider>(
      context,
      listen: false,
    ).consultarDatosDePesca();
  }

  @override
  Widget build(BuildContext context) {
    final appConfig = Provider.of<AppConfigProvider>(context);
    final pescaProvider = Provider.of<PescaDataProvider>(context);

    // Formateador para las cantidades de pesca
    final NumberFormat toneladasFormat = NumberFormat("#,##0.00 'Tn'", "es_PE");

    return Scaffold(
      body: CustomScrollView(
        controller: _scrollController,
        slivers: [
          SliverAppBar(
            floating: true,
            pinned: false,
            snap: true,
            expandedHeight: 140.0,
            flexibleSpace: FlexibleSpaceBar(
              background: Padding(
                padding: const EdgeInsets.only(top: kToolbarHeight),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    DateRangeSelector(
                      initialStartDate: pescaProvider.fechaInicioSeleccionada,
                      initialEndDate: pescaProvider.fechaFinSeleccionada,
                      onDateRangeSelected: (inicio, fin) {
                        pescaProvider.setFechas(inicio, fin);
                      },
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16.0,
                        vertical: 8.0,
                      ),
                      child: ElevatedButton.icon(
                        icon:
                            pescaProvider.isLoading
                                ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.white,
                                  ),
                                )
                                : const Icon(Icons.search),
                        label: Text(
                          pescaProvider.isLoading
                              ? 'Consultando...'
                              : 'Consultar Pesca',
                        ),
                        onPressed:
                            pescaProvider.isLoading ||
                                    !pescaProvider.canPerformQuery
                                ? null
                                : _fetchData,
                        style: ElevatedButton.styleFrom(
                          minimumSize: const Size(double.infinity, 48),
                          textStyle: const TextStyle(fontSize: 16),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: _buildContent(pescaProvider, appConfig, toneladasFormat),
          ),
        ],
      ),
    );
  }

  Widget _buildContent(
    PescaDataProvider pescaProvider,
    AppConfigProvider appConfig,
    NumberFormat toneladasFormat,
  ) {
    if (pescaProvider.isLoading && pescaProvider.datosGenerales == null) {
      // Mostrar loader solo si no hay datos previos
      return const SizedBox(
        height: 300,
        child: Center(child: CircularProgressIndicator()),
      );
    }

    if (pescaProvider.hasError) {
      return NoDataFoundWidget(
        icon: Icons.error_outline,
        message:
            "Error: ${pescaProvider.errorMessage}\nPor favor, verifica tu conexión o la configuración.",
      );
    }

    if (!pescaProvider.hasDataToDisplay &&
        pescaProvider.datosGenerales == null) {
      // Si aún no se ha consultado o no hay datos después de la consulta
      return const NoDataFoundWidget(
        message: "Selecciona un rango de fechas y presiona 'Consultar Pesca'.",
      );
    }

    final datos = pescaProvider.datosGenerales;

    if (datos == null ||
        (datos.totalPescado == 0 &&
            pescaProvider.listaPescaRaw.isEmpty &&
            !pescaProvider.isLoading)) {
      // Si la consulta devolvió 0 resultados y no está cargando
      return const NoDataFoundWidget(
        message:
            "No se encontraron datos de pesca para el periodo seleccionado.",
      );
    }

    // Si datos no es null, pero totalPescado es 0 y la meta es > 0 (significa que hay cuota pero no pesca)
    // Este caso está cubierto por la lógica de porcentaje y gráficos mostrando 0%

    return RefreshIndicator(
      onRefresh: () async => _fetchData(),
      child: ListView(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        padding: const EdgeInsets.only(
          bottom: 16.0,
        ), // Espacio para el último card
        children: [
          FishingSummaryCard(
            cuotaMetaTitle: 'Cuota Total Meta',
            cuotaMetaValue: toneladasFormat.format(datos.cuotaMeta),
            cuotaMetaIcon: Icons.flag_outlined,

            pescaActualTitle: 'Pesca Total Descargada (Periodo)',
            pescaActualValue: toneladasFormat.format(datos.totalPescado),
            pescaActualIcon: Icons.phishing_outlined,

            // pescaActualIconColor: Colors.green, // El widget ya lo pone verde por defecto
            avanceTitle: 'Avance General de Cuota',
            porcentajeAvance: datos.porcentajeAvance,
            estimacionDiasRestantesText:
                'Estimado para meta: ${datos.diasRestantesEstimados}', // Texto completo
          ),
          LineChartCard(
            title: 'Pesca Diaria (General)',
            spots: datos.pescaDiariaSpots,
            bottomTitles: pescaProvider.getFechasEjeX(datos),
            lineColor: Colors.orange,
            yAxisLabelFormatter: "Tn",
          ),
          LineChartCard(
            title: 'Pesca Acumulada (General)',
            spots: datos.pescaAcumuladaSpots,
            bottomTitles: pescaProvider.getFechasEjeX(datos),
            lineColor: Colors.purple,
            yAxisLabelFormatter: "Tn",
          ),
        ],
      ),
    );
  }
}
