import 'package:hive/hive.dart';
import '../../domain/entities/expense.dart';

// Hive Adapter separated from Domain Entity
class ExpenseAdapter extends TypeAdapter<Expense> {
  @override
  final int typeId = 0;

  @override
  Expense read(BinaryReader reader) {
    return Expense(
      id: reader.read(),
      title: reader.read(),
      amount: reader.read(),
      date: reader.read(),
      category: ExpenseCategory.values.firstWhere(
        (e) => e.name == reader.read(),
        orElse: () => ExpenseCategory.other, // Defensive fallback
      ),
    );
  }

  @override
  void write(BinaryWriter writer, Expense obj) {
    writer.write(obj.id);
    writer.write(obj.title);
    writer.write(obj.amount);
    writer.write(obj.date);
    writer.write(obj.category.name); // Store string for durability
  }
}
