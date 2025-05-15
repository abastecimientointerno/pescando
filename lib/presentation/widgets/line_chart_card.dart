import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'dart:math' as math;

class LineChartCard extends StatefulWidget {
  final String title;
  final List<FlSpot> spots;
  final List<String> bottomTitles;
  final Color lineColor;
  final String? yAxisLabelFormatter;
  final bool showGradient;
  final bool enableAnimation;

  const LineChartCard({
    super.key,
    required this.title,
    required this.spots,
    required this.bottomTitles,
    this.lineColor = const Color(0xFF4A80F0),
    this.yAxisLabelFormatter,
    this.showGradient = true,
    this.enableAnimation = true,
  });

  @override
  State<LineChartCard> createState() => _LineChartCardState();
}

class _LineChartCardState extends State<LineChartCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _animation;
  bool _isHovered = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );
    _animation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOutCubic,
    );

    if (widget.enableAnimation) {
      _animationController.forward();
    } else {
      _animationController.value = 1.0;
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        decoration: BoxDecoration(
          color: theme.cardColor,
          boxShadow: [
            BoxShadow(
              color:
                  _isHovered
                      ? widget.lineColor.withOpacity(0.15)
                      : Colors.black.withOpacity(0.05),
              blurRadius: _isHovered ? 12 : 5,
              offset: const Offset(0, 4),
            ),
          ],
          border: Border.all(
            color:
                _isHovered
                    ? widget.lineColor.withOpacity(0.5)
                    : Colors.grey.withOpacity(0.1),
            width: 1,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    widget.title,
                    style: theme.textTheme.titleSmall?.copyWith(
                      color: theme.textTheme.titleSmall?.color,
                    ),
                  ),
                  if (widget.spots.isNotEmpty)
                    Row(
                      children: [
                        Text(
                          'Último valor: ',
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: theme.textTheme.labelSmall?.color
                                ?.withOpacity(0.7),
                          ),
                        ),
                        Text(
                          '${widget.spots.last.y.toStringAsFixed(1)}${widget.yAxisLabelFormatter != null ? ' ${widget.yAxisLabelFormatter}' : ''}',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: widget.lineColor,
                          ),
                        ),
                      ],
                    ),
                ],
              ),
              const SizedBox(height: 10),
              Divider(color: Colors.grey.withOpacity(0.1), thickness: 1),
              const SizedBox(height: 20),
              if (widget.spots.isEmpty)
                SizedBox(
                  height: 200,
                  child: Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.data_exploration_outlined,
                          size: 48,
                          color: Colors.grey[400],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'No hay datos para mostrar',
                          style: TextStyle(color: Colors.grey[600]),
                        ),
                      ],
                    ),
                  ),
                )
              else
                SizedBox(
                  height: 220,
                  child: AnimatedBuilder(
                    animation: _animation,
                    builder: (context, child) {
                      return LineChart(
                        LineChartData(
                          lineTouchData: LineTouchData(
                            touchTooltipData: LineTouchTooltipData(
                              tooltipRoundedRadius: 8,
                              tooltipPadding: const EdgeInsets.all(8),
                              tooltipBorder: BorderSide(width: 0),
                              getTooltipItems: (
                                List<LineBarSpot> touchedSpots,
                              ) {
                                return touchedSpots.map((spot) {
                                  final date =
                                      widget.bottomTitles[spot.x.toInt()];
                                  return LineTooltipItem(
                                    '${date}\n',
                                    TextStyle(
                                      color: theme.textTheme.bodyMedium?.color,
                                      fontWeight: FontWeight.w500,
                                      fontSize: 9,
                                    ),
                                    children: [
                                      TextSpan(
                                        text:
                                            '${spot.y.toStringAsFixed(1)}${widget.yAxisLabelFormatter != null ? ' ${widget.yAxisLabelFormatter}' : ''}',
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 12,
                                        ),
                                      ),
                                    ],
                                  );
                                }).toList();
                              },
                            ),
                            handleBuiltInTouches: true,
                            touchSpotThreshold: 15,
                          ),
                          gridData: FlGridData(
                            drawHorizontalLine: true,
                            drawVerticalLine: true,
                            horizontalInterval: _calculateOptimalInterval(),
                            getDrawingHorizontalLine: (value) {
                              return FlLine(
                                color: Colors.grey.withOpacity(0.1),
                                strokeWidth: 1,
                                dashArray: [5, 5],
                              );
                            },
                            getDrawingVerticalLine: (value) {
                              return FlLine(
                                color: Colors.grey.withOpacity(0.05),
                                strokeWidth: 1,
                                dashArray: [5, 5],
                              );
                            },
                          ),
                          titlesData: FlTitlesData(
                            show: true,
                            rightTitles: const AxisTitles(
                              sideTitles: SideTitles(showTitles: false),
                            ),
                            topTitles: const AxisTitles(
                              sideTitles: SideTitles(showTitles: false),
                            ),
                            bottomTitles: AxisTitles(
                              sideTitles: SideTitles(
                                showTitles: true,
                                reservedSize: 25,
                                getTitlesWidget: _bottomTitleWidgets,
                              ),
                            ),

                            leftTitles: AxisTitles(sideTitles: SideTitles()),
                          ),
                          borderData: FlBorderData(show: false),
                          minX: 0,
                          maxX: (widget.spots.length - 1).toDouble(),
                          minY: 0,
                          maxY: _calculateYMax() * 1.1,
                          lineBarsData: [
                            LineChartBarData(
                              spots:
                                  widget.enableAnimation
                                      ? widget.spots
                                          .map(
                                            (spot) => FlSpot(
                                              spot.x,
                                              spot.y * _animation.value,
                                            ),
                                          )
                                          .toList()
                                      : widget.spots,
                              isCurved: true,
                              preventCurveOverShooting: true,
                              color: widget.lineColor,
                              barWidth: 1.5,
                              belowBarData: BarAreaData(
                                show: widget.showGradient,
                                gradient: LinearGradient(
                                  colors: [
                                    widget.lineColor.withOpacity(0.3),
                                    widget.lineColor.withOpacity(0.05),
                                  ],
                                  begin: Alignment.topCenter,
                                  end: Alignment.bottomCenter,
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              // Espacio para leyenda o información adicional
              if (widget.spots.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 2),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      _buildLegendItem(
                        color: widget.lineColor,
                        label: 'Tendencia',
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _leftTitleWidgets(double value, TitleMeta meta) {
    final style = TextStyle(
      color: Colors.grey[600],
      fontSize: 8,
      fontWeight: FontWeight.w500,
    );

    String text;
    if (value >= 1000000) {
      text = '${(value / 1000000).toStringAsFixed(1)}M';
    } else if (value >= 1000) {
      text = '${(value / 1000).toStringAsFixed(1)}k';
    } else {
      text = value.toStringAsFixed(0);
    }

    if (widget.yAxisLabelFormatter != null) {
      text += ' ${widget.yAxisLabelFormatter}';
    }

    return Padding(
      padding: const EdgeInsets.only(right: 1),
      child: Text(text, style: style, textAlign: TextAlign.right),
    );
  }

  Widget _bottomTitleWidgets(double value, TitleMeta meta) {
    final index = value.toInt();
    if (index < 0 || index >= widget.bottomTitles.length) {
      return const SizedBox.shrink();
    }

    // Mostrar menos etiquetas si hay demasiadas
    bool showLabel = true;
    if (widget.bottomTitles.length > 6) {
      final interval = _calculateXAxisInterval();
      showLabel =
          index % interval.toInt() == 0 ||
          index == 0 ||
          index == widget.bottomTitles.length - 1;
    }

    if (!showLabel) {
      return const SizedBox.shrink();
    }

    return SideTitleWidget(
      axisSide: meta.axisSide,
      space: 8,
      child: Text(
        widget.bottomTitles[index],
        style: TextStyle(
          color: Colors.grey[600],
          fontSize: 9,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  double _calculateOptimalInterval() {
    if (widget.spots.isEmpty) return 1;

    final maxY = _calculateYMax();
    if (maxY <= 10) return 1;
    if (maxY <= 50) return 5;
    if (maxY <= 100) return 10;
    if (maxY <= 500) return 50;
    if (maxY <= 1000) return 100;

    return math.pow(10, (math.log(maxY) / math.ln10).floor() - 1).toDouble();
  }

  double _calculateXAxisInterval() {
    final length = widget.bottomTitles.length;
    if (length <= 6) return 1;
    if (length <= 12) return 2;
    if (length <= 24) return 4;
    if (length <= 50) return 8;

    return (length / 6).ceil().toDouble();
  }

  double _calculateYMax() {
    if (widget.spots.isEmpty) return 10;

    double maxY = 0;
    for (final spot in widget.spots) {
      if (spot.y > maxY) {
        maxY = spot.y;
      }
    }

    return maxY == 0 ? 10 : maxY;
  }

  Widget _buildLegendItem({required Color color, required String label}) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(6),
          ),
        ),
        const SizedBox(width: 6),
        Text(label, style: TextStyle(fontSize: 10, color: Colors.grey[600])),
      ],
    );
  }
}
