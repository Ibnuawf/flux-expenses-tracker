import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../../../core/config/app_dimens.dart';
import '../../../../core/utils/date_formatter.dart';
import '../../../../core/utils/input_sanitizer.dart';
import '../../../../core/widgets/app_snackbar.dart';
import '../../domain/entities/expense.dart';
import '../controllers/expense_controller.dart';

class ExpenseFormSheet extends StatefulWidget {
  final Expense? expense;

  const ExpenseFormSheet({super.key, this.expense});

  @override
  State<ExpenseFormSheet> createState() => _ExpenseFormSheetState();
}

class _ExpenseFormSheetState extends State<ExpenseFormSheet> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _titleCtrl;
  late TextEditingController _amountCtrl;
  late DateTime _selectedDate;
  late ExpenseCategory _selectedCategory;

  @override
  void initState() {
    super.initState();
    _titleCtrl = TextEditingController(text: widget.expense?.title ?? '');
    _amountCtrl = TextEditingController(
      text: widget.expense != null
          ? widget.expense!.amount.toStringAsFixed(0)
          : '',
    );
    _selectedDate = widget.expense?.date ?? DateTime.now();
    _selectedCategory = widget.expense?.category ?? ExpenseCategory.food;
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    _amountCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final title = _titleCtrl.text.trim();
    final amount = InputSanitizer.parseDouble(_amountCtrl.text);

    if (amount == null || amount <= 0) return;

    final controller = context.read<ExpenseController>();

    try {
      if (widget.expense != null) {
        await controller.update(widget.expense!.copyWith(
          title: title,
          amount: amount,
          date: _selectedDate,
          category: _selectedCategory,
        ));
      } else {
        await controller.add(title, amount, _selectedCategory, _selectedDate);
      }

      if (mounted) {
        HapticFeedback.mediumImpact();
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) AppSnackBar.show(context, 'Operation failed', isError: true);
    }
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: now.subtract(const Duration(days: 365)),
      lastDate: now,
    );
    if (picked != null) setState(() => _selectedDate = picked);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return Container(
      padding: EdgeInsets.fromLTRB(AppDimens.p24, AppDimens.p24, AppDimens.p24,
          bottomInset + AppDimens.p24),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius:
            const BorderRadius.vertical(top: Radius.circular(AppDimens.r28)),
      ),
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              widget.expense == null ? 'New Expense' : 'Edit Expense',
              style: theme.textTheme.headlineSmall
                  ?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: AppDimens.p24),
            TextFormField(
              controller: _titleCtrl,
              textCapitalization: TextCapitalization.sentences,
              decoration: const InputDecoration(
                  labelText: 'Description',
                  prefixIcon: Icon(Icons.edit_outlined)),
              validator: (v) => (v?.trim().isEmpty ?? true) ? 'Required' : null,
            ),
            const SizedBox(height: AppDimens.p16),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _amountCtrl,
                    keyboardType:
                        const TextInputType.numberWithOptions(decimal: true),
                    decoration: const InputDecoration(
                        labelText: 'Amount',
                        prefixIcon: Icon(Icons.attach_money)),
                    validator: (v) {
                      if (v == null || v.trim().isEmpty) return 'Required';
                      final val = InputSanitizer.parseDouble(v);
                      if (val == null || val <= 0) return 'Invalid';
                      return null;
                    },
                  ),
                ),
                const SizedBox(width: AppDimens.p12),
                Expanded(
                  child: InkWell(
                    onTap: _pickDate,
                    borderRadius: BorderRadius.circular(AppDimens.r12),
                    child: Container(
                      height: 56,
                      padding:
                          const EdgeInsets.symmetric(horizontal: AppDimens.p12),
                      decoration: BoxDecoration(
                        color: theme.inputDecorationTheme.fillColor,
                        borderRadius: BorderRadius.circular(AppDimens.r12),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.calendar_today,
                              size: 20,
                              color: theme.colorScheme.onSurfaceVariant),
                          const SizedBox(width: 8),
                          Text(DateFormatter.format(_selectedDate)),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppDimens.p16),
            DropdownButtonFormField<ExpenseCategory>(
              value: _selectedCategory,
              decoration: const InputDecoration(
                  labelText: 'Category',
                  prefixIcon: Icon(Icons.category_outlined)),
              items: ExpenseCategory.values
                  .map((c) => DropdownMenuItem(
                        value: c,
                        child: Row(
                          children: [
                            Icon(c.icon, size: 20, color: c.color),
                            const SizedBox(width: 10),
                            Text(c.label),
                          ],
                        ),
                      ))
                  .toList(),
              onChanged: (v) => setState(() => _selectedCategory = v!),
            ),
            const SizedBox(height: AppDimens.p32),
            FilledButton(
              onPressed: _submit,
              style: FilledButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: AppDimens.p16),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppDimens.r12)),
              ),
              child: Text(widget.expense == null ? 'Save' : 'Update'),
            ),
          ],
        ),
      ),
    );
  }
}
