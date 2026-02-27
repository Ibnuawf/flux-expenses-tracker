import 'package:flutter/material.dart';

enum ExpenseCategory { food, transport, bills, other }

extension CategoryUi on ExpenseCategory {
  String get label => name[0].toUpperCase() + name.substring(1);

  IconData get icon {
    switch (this) {
      case ExpenseCategory.food: return Icons.restaurant_rounded;
      case ExpenseCategory.transport: return Icons.commute_rounded;
      case ExpenseCategory.bills: return Icons.receipt_long_rounded;
      case ExpenseCategory.other: return Icons.donut_small_rounded;
    }
  }

  Color get color {
    switch (this) {
      case ExpenseCategory.food: return const Color(0xFFFF7043);
      case ExpenseCategory.transport: return const Color(0xFF5C6BC0);
      case ExpenseCategory.bills: return const Color(0xFF66BB6A);
      case ExpenseCategory.other: return const Color(0xFF78909C);
    }
  }
}

class Expense {
  final String id;
  final String title;
  final double amount;
  final DateTime date;
  final ExpenseCategory category;

  const Expense({
    required this.id,
    required this.title,
    required this.amount,
    required this.date,
    required this.category,
  });

  Expense copyWith({
    String? title,
    double? amount,
    DateTime? date,
    ExpenseCategory? category,
  }) {
    return Expense(
      id: id,
      title: title ?? this.title,
      amount: amount ?? this.amount,
      date: date ?? this.date,
      category: category ?? this.category,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Expense && id == other.id && amount == other.amount && date == other.date;

  @override
  int get hashCode => Object.hash(id, amount, date);
}
