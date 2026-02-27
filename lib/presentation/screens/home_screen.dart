import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/config/app_dimens.dart';
import '../controllers/expense_controller.dart';
import '../state/expense_state.dart';
import '../widgets/expense_form_sheet.dart';
import '../widgets/expense_list_tile.dart';
import 'stats_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    // Micro-task init to avoid build collisions
    Future.microtask(() => context.read<ExpenseController>().load());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar.large(
            title: const Text('Expenses'),
            actions: [
              IconButton(
                icon: const Icon(Icons.bar_chart_rounded),
                onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const StatsScreen())),
              )
            ],
          ),
          Consumer<ExpenseController>(
            builder: (context, controller, child) {
              final state = controller.state;

              if (state is ExpenseLoading || state is ExpenseInitial) {
                return const SliverFillRemaining(child: Center(child: CircularProgressIndicator()));
              }

              if (state is ExpenseError) {
                return SliverFillRemaining(
                  child: Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.error_outline, size: 48, color: Colors.red),
                        const SizedBox(height: 16),
                        Text(state.message),
                        TextButton(onPressed: controller.load, child: const Text("Retry")),
                      ],
                    ),
                  ),
                );
              }

              if (state is ExpenseLoaded) {
                if (state.expenses.isEmpty) {
                  return SliverFillRemaining(
                    child: Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.savings_outlined, size: 64, color: Theme.of(context).colorScheme.outline),
                          const SizedBox(height: AppDimens.p16),
                          Text("No expenses yet", style: Theme.of(context).textTheme.bodyLarge),
                        ],
                      ),
                    ),
                  );
                }

                return SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final expense = state.expenses[index];
                      return ExpenseListTile(
                        expense: expense,
                        onTap: () => _showSheet(context, expense),
                        onDelete: () => controller.delete(expense.id),
                      );
                    },
                    childCount: state.expenses.length,
                  ),
                );
              }
              
              return const SliverToBoxAdapter(child: SizedBox.shrink());
            },
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 80)),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showSheet(context, null),
        label: const Text('Add'),
        icon: const Icon(Icons.add),
      ),
    );
  }

  void _showSheet(BuildContext context, dynamic expense) { // expense typed dynamically to reuse method
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => ExpenseFormSheet(expense: expense),
    );
  }
}
