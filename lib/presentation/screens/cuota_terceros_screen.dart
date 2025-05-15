import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../core/providers/app_config_provider.dart';
import '../../core/providers/pesca_data_provider.dart';
import '../widgets/circular_progress_indicator_card.dart';
import '../widgets/line_chart_card.dart';
import '../widgets/metric_display_card.dart';
import '../widgets/no_data_found_widget.dart';

class CuotaTercerosScreen extends StatelessWidget {
  const CuotaTercerosScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final appConfig = Provider.of<AppConfigProvider>(context, listen: false);
    final pescaProvider = Provider.of<PescaDataProvider>(context);
    final NumberFormat toneladasFormat = NumberFormat("#,##0.00 'Tn'", "es_PE");

    Widget buildContent() {
      if (pescaProvider.isLoading && pescaProvider.datosTerceros == null) {
        return const Center(child: CircularProgressIndicator());
      }
      if (pescaProvider.hasError) {
        return NoDataFoundWidget(
          message: "Error al cargar datos: ${pescaProvider.errorMessage}",
        );
      }
      if (!pescaProvider.hasDataToDisplay &&
          pescaProvider.datosTerceros == null) {
        return const NoDataFoundWidget(
          message: "Consulta primero los datos en la pestaña 'Resumen'.",
        );
      }

      final datos = pescaProvider.datosTerceros;

      if (datos == null ||
          (datos.totalPescado == 0 &&
              datos.cuotaMeta > 0 &&
              !pescaProvider.isLoading &&
              pescaProvider.listaPescaRaw.isNotEmpty)) {
        return ListView(
          children: [
            MetricDisplayCard(
              title: 'Cuota Meta Terceros',
              value: toneladasFormat.format(datos?.cuotaMeta ?? 0.0),
              icon: Icons.handshake_outlined,
            ),
            const NoDataFoundWidget(
              message:
                  "No se encontró pesca de terceros para el periodo seleccionado.",
            ),
          ],
        );
      }
      if (datos == null) {
        return const NoDataFoundWidget(
          message:
              "Los datos de pesca de terceros aparecerán aquí después de consultar.",
        );
      }

      return RefreshIndicator(
        onRefresh: () async => pescaProvider.consultarDatosDePesca(),
        child: ListView(
          padding: const EdgeInsets.symmetric(
            horizontal: 0,
            vertical: 8.0,
          ).copyWith(bottom: 16),
          children: [
            MetricDisplayCard(
              title: 'Cuota Meta Terceros',
              value: toneladasFormat.format(datos.cuotaMeta),
              icon: Icons.handshake_outlined,
            ),
            MetricDisplayCard(
              title: 'Pesca Terceros Descargada (Periodo)',
              value: toneladasFormat.format(datos.totalPescado),
              icon: Icons.storefront_outlined,
              iconColor: Colors.deepOrange,
            ),
            CircularProgressIndicatorCard(
              title: 'Avance Cuota Terceros',
              percent: datos.porcentajeAvance / 100,
              centerText: '${datos.porcentajeAvance.toStringAsFixed(1)}%',
              footerText:
                  'Estimado para alcanzar meta: ${datos.diasRestantesEstimados}',
            ),
            LineChartCard(
              title: 'Pesca Diaria (Terceros)',
              spots: datos.pescaDiariaSpots,
              bottomTitles: pescaProvider.getFechasEjeX(datos),
              lineColor: Colors.redAccent,
              yAxisLabelFormatter: "Tn",
            ),
            LineChartCard(
              title: 'Pesca Acumulada (Terceros)',
              spots: datos.pescaAcumuladaSpots,
              bottomTitles: pescaProvider.getFechasEjeX(datos),
              lineColor: Colors.pinkAccent,
              yAxisLabelFormatter: "Tn",
            ),
          ],
        ),
      );
    }

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.only(top: 16.0),
          child: buildContent(),
        ),
      ),
    );
  }
}
