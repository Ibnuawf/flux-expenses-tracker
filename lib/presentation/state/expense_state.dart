import '../../domain/entities/expense.dart';

// Simulated Sealed Class
abstract class ExpenseState {
  const ExpenseState();
}

class ExpenseInitial extends ExpenseState {}

class ExpenseLoading extends ExpenseState {}

class ExpenseLoaded extends ExpenseState {
  final List<Expense> expenses;
  final double monthTotal;
  final Map<ExpenseCategory, double> breakdown;
  final double chartMaxY;

  const ExpenseLoaded({
    required this.expenses,
    required this.monthTotal,
    required this.breakdown,
    required this.chartMaxY,
  });
}

class ExpenseError extends ExpenseState {
  final String message;
  const ExpenseError(this.message);
}
