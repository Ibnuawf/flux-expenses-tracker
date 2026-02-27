import 'package:flutter/foundation.dart';
import '../../core/infrastructure/clock.dart';
import '../../core/infrastructure/id_generator.dart';
import '../../core/utils/date_formatter.dart';
import '../../core/utils/logger.dart';
import '../../domain/entities/expense.dart';
import '../../domain/repositories/expense_repository.dart';
import '../state/expense_state.dart';

class ExpenseController extends ChangeNotifier {
  final ExpenseRepository _repository;
  final Clock _clock;
  final IdGenerator _idGenerator;

  ExpenseState _state = ExpenseInitial();
  
  // Internal cache to support optimistic updates
  List<Expense> _currentItems = [];

  ExpenseController(this._repository, this._clock, this._idGenerator);

  ExpenseState get state => _state;

  Future<void> load() async {
    _state = ExpenseLoading();
    notifyListeners();

    final result = await _repository.getAll();
    if (result.$2 != null) {
      _state = ExpenseError(result.$2!.message);
    } else {
      _currentItems = result.$1!;
      _currentItems.sort((a, b) => b.date.compareTo(a.date));
      _emitLoaded();
    }
    notifyListeners();
  }

  Future<void> add(String title, double amount, ExpenseCategory category, DateTime date) async {
    final expense = Expense(
      id: _idGenerator.v4(),
      title: title.trim(),
      amount: amount,
      date: date,
      category: category,
    );

    await _optimisticUpdate(
      action: () => _repository.save(expense),
      onDo: () => _currentItems.insert(0, expense),
      onUndo: () => _currentItems.removeWhere((x) => x.id == expense.id),
    );
  }

  Future<void> update(Expense updated) async {
    final index = _currentItems.indexWhere((e) => e.id == updated.id);
    if (index == -1) return;
    final old = _currentItems[index];

    await _optimisticUpdate(
      action: () => _repository.save(updated),
      onDo: () => _currentItems[index] = updated,
      onUndo: () => _currentItems[index] = old,
    );
  }

  Future<void> delete(String id) async {
    final index = _currentItems.indexWhere((e) => e.id == id);
    if (index == -1) return;
    final deleted = _currentItems[index];

    await _optimisticUpdate(
      action: () => _repository.delete(id),
      onDo: () => _currentItems.removeAt(index),
      onUndo: () => _currentItems.insert(index, deleted),
    );
  }

  Future<void> _optimisticUpdate({
    required Future<Result<void>> Function() action,
    required VoidCallback onDo,
    required VoidCallback onUndo,
  }) async {
    onDo();
    _currentItems.sort((a, b) => b.date.compareTo(a.date)); // Keep sort integrity
    _emitLoaded();
    notifyListeners();

    final result = await action();
    if (result.$2 != null) {
      Logger.log('Operation failed', result.$2!.message);
      onUndo();
      _emitLoaded(); // Re-emit old state
      notifyListeners();
      throw Exception(result.$2!.message); // Throw to UI for SnackBar
    }
  }

  void _emitLoaded() {
    final now = _clock.now();
    final monthItems = _currentItems.where((e) => DateFormatter.isSameMonth(e.date, now));
    
    double total = 0.0;
    final breakdown = {for (var c in ExpenseCategory.values) c: 0.0};

    for (var e in monthItems) {
      total += e.amount;
      breakdown[e.category] = (breakdown[e.category] ?? 0) + e.amount;
    }

    final maxVal = breakdown.values.fold(0.0, (p, c) => c > p ? c : p);

    _state = ExpenseLoaded(
      expenses: List.unmodifiable(_currentItems),
      monthTotal: total,
      breakdown: breakdown,
      chartMaxY: maxVal > 0 ? maxVal * 1.15 : 100.0,
    );
  }
}
