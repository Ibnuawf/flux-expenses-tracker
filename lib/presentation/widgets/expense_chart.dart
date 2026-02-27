import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import '../../../../core/config/app_dimens.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../domain/entities/expense.dart';

class ExpenseChart extends StatelessWidget {
  final Map<ExpenseCategory, double> data;
  final double maxY;

  const ExpenseChart({super.key, required this.data, required this.maxY});

  @override
  Widget build(BuildContext context) {
    final total = data.values.fold(0.0, (a, b) => a + b);
    if (total <= 0) return const SizedBox.shrink();

    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Semantics(
      label: 'Monthly expenses chart',
      child: AspectRatio(
        aspectRatio: AppDimens.chartRatio,
        child: BarChart(
          BarChartData(
            alignment: BarChartAlignment.spaceAround,
            maxY: maxY,
            barTouchData: BarTouchData(
              touchTooltipData: BarTouchTooltipData(
                tooltipBgColor: theme.colorScheme.surfaceContainerHighest,
                getTooltipItem: (group, groupIndex, rod, rodIndex) {
                  final cat = ExpenseCategory.values[group.x];
                  return BarTooltipItem(
                    '${cat.label}\n',
                    TextStyle(
                        color: theme.colorScheme.onSurface,
                        fontWeight: FontWeight.bold),
                    children: [
                      TextSpan(
                        text: CurrencyFormatter.format(rod.toY),
                        style: TextStyle(
                            color: theme.colorScheme.primary,
                            fontWeight: FontWeight.normal),
                      ),
                    ],
                  );
                },
              ),
            ),
            gridData: const FlGridData(show: false),
            borderData: FlBorderData(show: false),
            titlesData: FlTitlesData(
              leftTitles:
                  const AxisTitles(sideTitles: SideTitles(showTitles: false)),
              rightTitles:
                  const AxisTitles(sideTitles: SideTitles(showTitles: false)),
              topTitles:
                  const AxisTitles(sideTitles: SideTitles(showTitles: false)),
              bottomTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  getTitlesWidget: (value, _) {
                    final idx = value.toInt();
                    if (idx < 0 || idx >= ExpenseCategory.values.length)
                      return const SizedBox.shrink();

                    final cat = ExpenseCategory.values[idx];
                    final color = isDark
                        ? theme.colorScheme.onSurface.withOpacity(0.6)
                        : theme.colorScheme.outline;

                    return Padding(
                      padding: const EdgeInsets.only(top: AppDimens.p8),
                      child: Icon(cat.icon, size: 20, color: color),
                    );
                  },
                ),
              ),
            ),
            barGroups: ExpenseCategory.values.asMap().entries.map((e) {
              return BarChartGroupData(
                x: e.key,
                barRods: [
                  BarChartRodData(
                    toY: data[e.value] ?? 0,
                    color: e.value.color,
                    width: 16,
                    borderRadius: BorderRadius.circular(4),
                    backDrawRodData: BackgroundBarChartRodData(
                      show: true,
                      toY: maxY,
                      color: theme.colorScheme.surfaceContainerHighest
                          .withOpacity(0.3),
                    ),
                  ),
                ],
              );
            }).toList(),
          ),
        ),
      ),
    );
  }
}
