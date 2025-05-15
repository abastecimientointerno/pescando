import 'package:flutter/material.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';

class FishingSummaryCard extends StatelessWidget {
  final String cuotaMetaTitle;
  final String cuotaMetaValue;
  final IconData? cuotaMetaIcon;
  final Color? cuotaMetaIconColor;

  final String pescaActualTitle;
  final String pescaActualValue;
  final IconData? pescaActualIcon;
  final Color? pescaActualIconColor;

  final String avanceTitle;
  final double porcentajeAvance; // 0.0 a 100.0
  final String estimacionDiasRestantesText;

  const FishingSummaryCard({
    super.key,
    required this.cuotaMetaTitle,
    required this.cuotaMetaValue,
    this.cuotaMetaIcon,
    this.cuotaMetaIconColor,
    required this.pescaActualTitle,
    required this.pescaActualValue,
    this.pescaActualIcon,
    this.pescaActualIconColor,
    required this.avanceTitle,
    required this.porcentajeAvance,
    required this.estimacionDiasRestantesText,
  });

  Widget _buildMetricBlock(
    BuildContext context, {
    required String title,
    required String value,
    required IconData icon,
    required Color iconColor,
    required Color backgroundColor,
  }) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;

    return Container(
      padding: const EdgeInsets.all(12.0),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(10.0),
        // boxShadow: [
        //   BoxShadow(
        //     color: Colors.black.withOpacity(0.05),
        //     blurRadius: 4,
        //     offset: Offset(0, 2),
        //   )
        // ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8.0),
            decoration: BoxDecoration(
              color: iconColor.withOpacity(0.15),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: iconColor, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  title,
                  style: textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant.withOpacity(0.8),
                    fontWeight: FontWeight.w500,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color:
                        theme
                            .colorScheme
                            .onSurface, // Usa el color de texto principal de la superficie
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme colorScheme = theme.colorScheme;
    final TextTheme textTheme = theme.textTheme;

    final double progressPercent =
        (porcentajeAvance.isNaN || porcentajeAvance.isInfinite)
            ? 0.0
            : (porcentajeAvance / 100).clamp(0.0, 1.0);

    return Card(
      elevation: 0, // Sutil elevación
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.0)),
      clipBehavior:
          Clip.antiAlias, // Para que el contenido respete el borde redondeado
      child: Container(
        // Opcional: Añadir un gradiente sutil al fondo del Card
        // decoration: BoxDecoration(
        //   gradient: LinearGradient(
        //     colors: [
        //       colorScheme.surface.withOpacity(0.9),
        //       colorScheme.surfaceVariant.withOpacity(0.5),
        //     ],
        //     begin: Alignment.topLeft,
        //     end: Alignment.bottomRight,
        //   )
        // ),
        padding: const EdgeInsets.all(16.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Sección Izquierda: Indicador de Progreso
            Expanded(
              flex: 3, // Un poco más de espacio para el círculo
              child: Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    avanceTitle,
                    textAlign: TextAlign.center,
                    style: textTheme.labelLarge?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                      fontWeight: FontWeight.w600, // Un poco más de peso
                    ),
                  ),
                  const SizedBox(height: 25),
                  CircularPercentIndicator(
                    backgroundWidth: 25,
                    radius: 70.0, // Un poco más grande
                    lineWidth: 20.0, // Un poco más grueso
                    animation: true,
                    percent: progressPercent,
                    center: Text(
                      '${porcentajeAvance.toStringAsFixed(1)}%',
                      style: textTheme.headlineSmall?.copyWith(
                        // Más prominente
                        fontWeight: FontWeight.bold,
                        color: colorScheme.primary,
                      ),
                    ),
                    circularStrokeCap: CircularStrokeCap.square,
                    progressColor: colorScheme.primary,
                    backgroundColor: colorScheme.primary.withOpacity(0.2),
                  ),
                  const SizedBox(height: 25),
                  if (estimacionDiasRestantesText.isNotEmpty)
                    Text(
                      estimacionDiasRestantesText,
                      textAlign: TextAlign.center,
                      style: textTheme.bodySmall?.copyWith(
                        color: colorScheme.onSurfaceVariant.withOpacity(0.7),
                        fontSize: 11,
                      ),
                    ),
                ],
              ),
            ),

            const SizedBox(width: 16),

            // Sección Derecha: Métricas
            Expanded(
              flex: 4, // Espacio para los bloques de métricas
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildMetricBlock(
                    context,
                    title: cuotaMetaTitle,
                    value: cuotaMetaValue,
                    icon: cuotaMetaIcon ?? Icons.flag_outlined,
                    iconColor: cuotaMetaIconColor ?? colorScheme.secondary,
                    backgroundColor: colorScheme.secondaryContainer.withOpacity(
                      0.3,
                    ),
                  ),
                  const SizedBox(height: 12),
                  _buildMetricBlock(
                    context,
                    title: pescaActualTitle,
                    value: pescaActualValue,
                    icon: pescaActualIcon ?? Icons.phishing_outlined,
                    iconColor: pescaActualIconColor ?? Colors.green.shade600,
                    backgroundColor: Colors.green.withOpacity(0.1),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
