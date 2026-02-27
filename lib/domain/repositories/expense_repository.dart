import '../entities/expense.dart';
import '../failures/failure.dart';

// Using a simple Record for Result pattern to avoid extra deps
typedef Result<T> = (T?, Failure?);

abstract class ExpenseRepository {
  Future<Result<List<Expense>>> getAll();
  Future<Result<void>> save(Expense expense);
  Future<Result<void>> delete(String id);
}
