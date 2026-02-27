import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../core/config/app_dimens.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../core/utils/date_formatter.dart';
import '../../../../core/widgets/app_snackbar.dart';
import '../../domain/entities/expense.dart';

class ExpenseListTile extends StatelessWidget {
  final Expense expense;
  final VoidCallback onTap;
  final Future<void> Function() onDelete;

  const ExpenseListTile({
    super.key,
    required this.expense,
    required this.onTap,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Semantics(
      label: 'Expense ${expense.title}, ${CurrencyFormatter.format(expense.amount)}',
      button: true,
      child: Dismissible(
        key: ValueKey(expense.id),
        direction: DismissDirection.endToStart,
        background: Container(
          alignment: Alignment.centerRight,
          padding: const EdgeInsets.only(right: AppDimens.p24),
          color: colorScheme.errorContainer,
          child: Icon(Icons.delete_outline, color: colorScheme.onErrorContainer),
        ),
        confirmDismiss: (_) => _confirmDelete(context),
        onDismissed: (_) async {
          HapticFeedback.mediumImpact();
          try {
            await onDelete();
            // Undo logic handled via Snackbar Action if integrated with Provider support
            // For now, basic confirmation
            if (context.mounted) AppSnackBar.show(context, 'Expense deleted');
          } catch (e) {
            if (context.mounted) AppSnackBar.show(context, 'Delete failed', isError: true);
          }
        },
        child: ListTile(
          onTap: onTap,
          contentPadding: const EdgeInsets.symmetric(horizontal: AppDimens.p16, vertical: AppDimens.p4),
          leading: Container(
            width: AppDimens.iconBox,
            height: AppDimens.iconBox,
            decoration: BoxDecoration(
              color: expense.category.color.withOpacity(0.15),
              shape: BoxShape.circle,
            ),
            child: Icon(expense.category.icon, color: expense.category.color, size: 22),
          ),
          title: Text(
            expense.title,
            style: theme.textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w600),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          subtitle: Text(
            DateFormatter.format(expense.date),
            style: theme.textTheme.bodySmall?.copyWith(color: colorScheme.onSurfaceVariant),
          ),
          trailing: Text(
            CurrencyFormatter.format(expense.amount),
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              letterSpacing: -0.5,
            ),
          ),
        ),
      ),
    );
  }

  Future<bool?> _confirmDelete(BuildContext context) {
    return showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Delete "${expense.title}"?'),
        content: const Text('This cannot be undone.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
              foregroundColor: Theme.of(context).colorScheme.onError,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}
