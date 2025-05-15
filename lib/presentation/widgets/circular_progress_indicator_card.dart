import 'package:flutter/material.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';

class CircularProgressIndicatorCard extends StatelessWidget {
  final String title;
  final double percent; // 0.0 to 1.0
  final String centerText;
  final String? footerText;
  final Color? progressColor;
  final Color? circleBackgroundColor;
  final double radius;
  final double lineWidth;
  final IconData? leadingIcon; // Nuevo: icono opcional para el título
  final GestureTapCallback? onTap; // Nuevo: callback para interactividad
  final bool showAnimatedGlow; // Nuevo: opción para efecto visual de brillo

  const CircularProgressIndicatorCard({
    super.key,
    required this.title,
    required this.percent,
    required this.centerText,
    this.footerText,
    this.progressColor,
    this.circleBackgroundColor,
    this.radius = 65.0, // Ligeramente aumentado
    this.lineWidth = 14.0, // Más grueso para mejor visibilidad
    this.leadingIcon, // Nuevo parámetro
    this.onTap, // Nuevo parámetro
    this.showAnimatedGlow = true, // Nuevo parámetro con valor predeterminado
  });

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final TextTheme textTheme = theme.textTheme;
    final Color primaryColor = progressColor ?? theme.colorScheme.primary;

    // Normaliza el porcentaje para el CircularPercentIndicator (0.0 a 1.0)
    final double normalizedPercent =
        percent.isNaN || percent.isInfinite ? 0.0 : percent.clamp(0.0, 1.0);

    // Determinamos el color del progreso según el porcentaje
    Color effectiveProgressColor = primaryColor;
    if (normalizedPercent < 0.3) {
      effectiveProgressColor = Colors.redAccent;
    } else if (normalizedPercent < 0.7) {
      effectiveProgressColor = Colors.amberAccent;
    }

    return Card(
      elevation: 3.0, // Sombra más pronunciada
      shadowColor: theme.shadowColor.withOpacity(0.3), // Sombra con color suave
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20.0), // Mayor redondeo
        side: BorderSide(
          color: theme.colorScheme.surfaceVariant.withOpacity(0.2),
          width: 1.0,
        ), // Borde sutil para elevación visual
      ),
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20.0), // Coincidir con la card
        child: Padding(
          padding: const EdgeInsets.all(22.0), // Padding aumentado
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Título con icono opcional
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (leadingIcon != null) ...[
                    Icon(leadingIcon, color: effectiveProgressColor, size: 22),
                    const SizedBox(width: 8),
                  ],
                  Flexible(
                    child: Text(
                      title,
                      style: textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: theme.colorScheme.onSurface.withOpacity(0.9),
                        letterSpacing: 0.2, // Mejor espaciado de letras
                      ),
                      textAlign: TextAlign.center,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 28), // Mayor separación
              // Widget con efecto de brillo condicional
              showAnimatedGlow
                  ? _buildGlowEffect(
                    context,
                    effectiveProgressColor,
                    normalizedPercent,
                    textTheme,
                  )
                  : _buildProgressIndicator(
                    normalizedPercent,
                    effectiveProgressColor,
                    theme,
                    textTheme,
                  ),
              if (footerText != null && footerText!.isNotEmpty) ...[
                const SizedBox(height: 20),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surfaceVariant.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    footerText!,
                    style: textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurface.withOpacity(0.7),
                      fontStyle: FontStyle.normal,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  // Extracción del indicador de progreso a un método separado
  Widget _buildProgressIndicator(
    double normalizedPercent,
    Color effectiveProgressColor,
    ThemeData theme,
    TextTheme textTheme,
  ) {
    return CircularPercentIndicator(
      radius: radius,
      lineWidth: lineWidth,
      animation: true,
      animationDuration: 1200, // Más lenta para mejor efecto
      animateFromLastPercent: true,
      percent: normalizedPercent,
      center: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            centerText,
            style: textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w800,
              color: effectiveProgressColor,
            ),
          ),
          // Mostrar texto de "Completado" si es 100%
          if (normalizedPercent >= 0.999)
            Text(
              "Completado",
              style: textTheme.bodySmall?.copyWith(
                color: effectiveProgressColor,
                fontWeight: FontWeight.w500,
              ),
            ),
        ],
      ),
      circularStrokeCap: CircularStrokeCap.round,
      progressColor: effectiveProgressColor,
      backgroundColor:
          circleBackgroundColor ?? effectiveProgressColor.withOpacity(0.15),
      widgetIndicator:
          normalizedPercent >= 0.999
              ? Container(
                width: 20,
                height: 20,
                decoration: BoxDecoration(
                  color: effectiveProgressColor,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.check, color: Colors.white, size: 12),
              )
              : null, // Indicador de completado
    );
  }

  // Método para crear el efecto de brillo animado
  Widget _buildGlowEffect(
    BuildContext context,
    Color effectiveProgressColor,
    double normalizedPercent,
    TextTheme textTheme,
  ) {
    return Container(
      decoration:
          normalizedPercent > 0.7
              ? BoxDecoration(
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: effectiveProgressColor.withOpacity(0.3),
                    blurRadius: 20,
                    spreadRadius: 2,
                  ),
                ],
              )
              : null,
      child: _buildProgressIndicator(
        normalizedPercent,
        effectiveProgressColor,
        Theme.of(context),
        textTheme,
      ),
    );
  }
}
