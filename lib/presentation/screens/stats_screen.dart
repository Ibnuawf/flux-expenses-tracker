import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/config/app_dimens.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../controllers/expense_controller.dart';
import '../state/expense_state.dart';
import '../widgets/expense_chart.dart';

class StatsScreen extends StatelessWidget {
  const StatsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Scaffold(
      appBar: AppBar(title: const Text('Monthly Insights')),
      body: Consumer<ExpenseController>(
        builder: (context, controller, _) {
          final state = controller.state;
          
          if (state is! ExpenseLoaded) return const SizedBox.shrink();
          
          if (state.monthTotal <= 0) {
            return Center(
              child: Text(
                'No data this month',
                style: theme.textTheme.bodyLarge?.copyWith(color: theme.colorScheme.onSurfaceVariant),
              ),
            );
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(AppDimens.p16),
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(AppDimens.p24),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primaryContainer,
                    borderRadius: BorderRadius.circular(AppDimens.r28),
                  ),
                  child: Column(
                    children: [
                      Text('Total Spent', style: theme.textTheme.labelLarge),
                      const SizedBox(height: AppDimens.p8),
                      Text(
                        CurrencyFormatter.format(state.monthTotal),
                        style: theme.textTheme.displayMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: theme.colorScheme.onPrimaryContainer,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AppDimens.p32),
                ExpenseChart(data: state.breakdown, maxY: state.chartMaxY),
              ],
            ),
          );
        },
      ),
    );
  }
}
