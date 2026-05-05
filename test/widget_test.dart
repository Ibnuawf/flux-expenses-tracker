import 'package:flutter_test/flutter_test.dart';

import 'package:resonance_app/core/infrastructure/clock.dart';
import 'package:resonance_app/core/infrastructure/id_generator.dart';
import 'package:resonance_app/core/utils/input_sanitizer.dart';
import 'package:resonance_app/domain/entities/expense.dart';
import 'package:resonance_app/domain/failures/failure.dart';
import 'package:resonance_app/domain/repositories/expense_repository.dart';
import 'package:resonance_app/presentation/controllers/expense_controller.dart';
import 'package:resonance_app/presentation/state/expense_state.dart';

class _FakeRepository implements ExpenseRepository {
  final Map<String, Expense> store = {};
  bool failNextSave = false;

  @override
  Future<Result<List<Expense>>> getAll() async => (store.values.toList(), null);

  @override
  Future<Result<void>> save(Expense expense) async {
    if (failNextSave) {
      failNextSave = false;
      return (null, const Failure('save failed'));
    }
    store[expense.id] = expense;
    return (null, null);
  }

  @override
  Future<Result<void>> delete(String id) async {
    store.remove(id);
    return (null, null);
  }
}

class _FixedClock implements Clock {
  @override
  DateTime now() => DateTime(2026, 8, 15);
}

void main() {
  group('InputSanitizer', () {
    test('parses plain and comma-decimal input', () {
      expect(InputSanitizer.parseDouble('12.50'), 12.50);
      expect(InputSanitizer.parseDouble('12,50'), 12.50);
      expect(InputSanitizer.parseDouble(' 7 '), 7.0);
      expect(InputSanitizer.parseDouble('abc'), isNull);
    });
  });

  group('ExpenseController', () {
    late _FakeRepository repository;
    late ExpenseController controller;

    setUp(() {
      repository = _FakeRepository();
      controller = ExpenseController(repository, _FixedClock(), IdGenerator());
    });

    test('load emits loaded state with monthly totals', () async {
      repository.store['a'] = Expense(
        id: 'a',
        title: 'Lunch',
        amount: 10,
        date: DateTime(2026, 8, 10),
        category: ExpenseCategory.food,
      );
      repository.store['b'] = Expense(
        id: 'b',
        title: 'Old bill',
        amount: 99,
        date: DateTime(2026, 7, 1),
        category: ExpenseCategory.bills,
      );

      await controller.load();

      final state = controller.state;
      expect(state, isA<ExpenseLoaded>());
      final loaded = state as ExpenseLoaded;
      expect(loaded.expenses.length, 2);
      expect(loaded.monthTotal, 10); // only current-month expenses counted
      expect(loaded.breakdown[ExpenseCategory.food], 10);
    });

    test('add persists the expense and updates state', () async {
      await controller.load();
      await controller.add(
          'Taxi', 5, ExpenseCategory.transport, DateTime(2026, 8, 12));

      expect(repository.store.length, 1);
      final loaded = controller.state as ExpenseLoaded;
      expect(loaded.expenses.single.title, 'Taxi');
      expect(loaded.monthTotal, 5);
    });

    test('add rolls back optimistic update when save fails', () async {
      await controller.load();
      repository.failNextSave = true;

      await expectLater(
        controller.add('Bad', 5, ExpenseCategory.other, DateTime(2026, 8, 12)),
        throwsException,
      );

      final loaded = controller.state as ExpenseLoaded;
      expect(loaded.expenses, isEmpty);
      expect(repository.store, isEmpty);
    });

    test('delete removes the expense', () async {
      repository.store['a'] = Expense(
        id: 'a',
        title: 'Lunch',
        amount: 10,
        date: DateTime(2026, 8, 10),
        category: ExpenseCategory.food,
      );
      await controller.load();

      await controller.delete('a');

      final loaded = controller.state as ExpenseLoaded;
      expect(loaded.expenses, isEmpty);
      expect(repository.store, isEmpty);
    });
  });
}
