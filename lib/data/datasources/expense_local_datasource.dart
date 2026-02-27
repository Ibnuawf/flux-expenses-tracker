import 'package:hive_flutter/hive_flutter.dart';
import '../../../../core/config/app_constants.dart';
import '../../domain/entities/expense.dart';
import '../models/expense_model.dart';

class ExpenseLocalDataSource {
  late Box<Expense> _box;

  Future<void> init() async {
    await Hive.initFlutter();
    Hive.registerAdapter(ExpenseAdapter());
    _box = await Hive.openBox<Expense>(AppConstants.expenseBoxName);
  }

  List<Expense> getAll() => _box.values.toList();
  
  Future<void> save(Expense expense) => _box.put(expense.id, expense);
  
  Future<void> delete(String id) => _box.delete(id);
}
