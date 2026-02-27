import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';

import '../../data/datasources/expense_local_datasource.dart';
import '../../data/repositories/expense_repository_impl.dart';
import '../../domain/repositories/expense_repository.dart';
import '../../presentation/controllers/expense_controller.dart';
import '../infrastructure/clock.dart';
import '../infrastructure/id_generator.dart';

class DependencyInjection {
  static Future<List<SingleChildWidget>> setup() async {
    // Datasources
    final localDataSource = ExpenseLocalDataSource();
    await localDataSource.init();

    // Repositories
    final expenseRepository = ExpenseRepositoryImpl(localDataSource);

    // Core
    final clock = Clock();
    final idGenerator = IdGenerator();

    return [
      // Repositories
      Provider<ExpenseRepository>(
        create: (_) => expenseRepository,
      ),

      // Core
      Provider<Clock>(
        create: (_) => clock,
      ),
      Provider<IdGenerator>(
        create: (_) => idGenerator,
      ),

      // Controllers
      ChangeNotifierProvider<ExpenseController>(
        create: (context) => ExpenseController(
          context.read<ExpenseRepository>(),
          context.read<Clock>(),
          context.read<IdGenerator>(),
        ),
      ),
    ];
  }
}
