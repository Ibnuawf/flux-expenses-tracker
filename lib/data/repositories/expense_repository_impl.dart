import '../../domain/entities/expense.dart';
import '../../domain/failures/failure.dart';
import '../../domain/repositories/expense_repository.dart';
import '../datasources/expense_local_datasource.dart';

class ExpenseRepositoryImpl implements ExpenseRepository {
  final ExpenseLocalDataSource _dataSource;

  ExpenseRepositoryImpl(this._dataSource);

  @override
  Future<Result<List<Expense>>> getAll() async {
    try {
      final data = _dataSource.getAll();
      return (data, null);
    } catch (e) {
      return (null, Failure(e.toString()));
    }
  }

  @override
  Future<Result<void>> save(Expense expense) async {
    try {
      await _dataSource.save(expense);
      return (null, null);
    } catch (e) {
      return (null, Failure(e.toString()));
    }
  }

  @override
  Future<Result<void>> delete(String id) async {
    try {
      await _dataSource.delete(id);
      return (null, null);
    } catch (e) {
      return (null, Failure(e.toString()));
    }
  }
}
