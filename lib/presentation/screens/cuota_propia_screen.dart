import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../core/providers/app_config_provider.dart';
import '../../core/providers/pesca_data_provider.dart';
import '../widgets/circular_progress_indicator_card.dart';
import '../widgets/line_chart_card.dart';
import '../widgets/metric_display_card.dart';
import '../widgets/no_data_found_widget.dart';

class CuotaPropiaScreen extends StatelessWidget {
  const CuotaPropiaScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final appConfig = Provider.of<AppConfigProvider>(
      context,
      listen: false,
    ); // No necesita escuchar cambios aquí
    final pescaProvider = Provider.of<PescaDataProvider>(context);
    final NumberFormat toneladasFormat = NumberFormat("#,##0.00 'Tn'", "es_PE");

    Widget buildContent() {
      if (pescaProvider.isLoading && pescaProvider.datosPropia == null) {
        return const Center(child: CircularProgressIndicator());
      }
      if (pescaProvider.hasError) {
        return NoDataFoundWidget(
          message: "Error al cargar datos: ${pescaProvider.errorMessage}",
        );
      }
      if (!pescaProvider.hasDataToDisplay &&
          pescaProvider.datosPropia == null) {
        return const NoDataFoundWidget(
          message: "Consulta primero los datos en la pestaña 'Resumen'.",
        );
      }

      final datos = pescaProvider.datosPropia;

      if (datos == null ||
          (datos.totalPescado == 0 &&
              datos.cuotaMeta > 0 &&
              !pescaProvider.isLoading &&
              pescaProvider.listaPescaRaw.isNotEmpty)) {
        // Hay cuota, se consultó, pero no hay pesca propia en el periodo
        return ListView(
          // Permite refresh
          children: [
            MetricDisplayCard(
              title: 'Cuota Meta Propia',
              value: toneladasFormat.format(datos?.cuotaMeta ?? 0.0),
              icon: Icons.flag_circle_outlined,
            ),
            const NoDataFoundWidget(
              message:
                  "No se encontró pesca propia para el periodo seleccionado.",
            ),
          ],
        );
      }
      if (datos == null) {
        // Si no hay datos aun (ej. antes de primera consulta)
        return const NoDataFoundWidget(
          message:
              "Los datos de pesca propia aparecerán aquí después de consultar.",
        );
      }

      return RefreshIndicator(
        onRefresh:
            () async =>
                pescaProvider.consultarDatosDePesca(), // Re-consulta todo
        child: ListView(
          padding: const EdgeInsets.symmetric(
            horizontal: 0,
            vertical: 8.0,
          ).copyWith(bottom: 16),
          children: [
            MetricDisplayCard(
              title: 'Cuota Meta Propia',
              value: toneladasFormat.format(datos.cuotaMeta),
              icon: Icons.flag_circle_outlined,
            ),
            MetricDisplayCard(
              title: 'Pesca Propia Descargada (Periodo)',
              value: toneladasFormat.format(datos.totalPescado),
              icon: Icons.sailing_outlined,
              iconColor: Colors.teal,
            ),
            CircularProgressIndicatorCard(
              title: 'Avance Cuota Propia',
              percent: datos.porcentajeAvance / 100,
              centerText: '${datos.porcentajeAvance.toStringAsFixed(1)}%',
              footerText:
                  'Estimado para alcanzar meta: ${datos.diasRestantesEstimados}',
            ),
            LineChartCard(
              title: 'Pesca Diaria (Propia)',
              spots: datos.pescaDiariaSpots,
              bottomTitles: pescaProvider.getFechasEjeX(datos),
              lineColor: Colors.tealAccent,
              yAxisLabelFormatter: "Tn",
            ),
            LineChartCard(
              title: 'Pesca Acumulada (Propia)',
              spots: datos.pescaAcumuladaSpots,
              bottomTitles: pescaProvider.getFechasEjeX(datos),
              lineColor: Colors.cyan,
              yAxisLabelFormatter: "Tn",
            ),
          ],
        ),
      );
    }

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.only(
            top: 16.0,
          ), // Un poco de espacio arriba ya que no hay DatePicker aquí
          child: buildContent(),
        ),
      ),
    );
  }
}
