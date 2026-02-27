import 'package:flutter/material.dart';
import '../config/app_constants.dart';
import '../config/app_dimens.dart';

class AppSnackBar {
  static void show(
    BuildContext context, 
    String message, {
    bool isError = false,
    VoidCallback? onUndo,
  }) {
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
        backgroundColor: isError ? Theme.of(context).colorScheme.error : null,
        duration: AppConstants.snackBarDuration,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppDimens.r12)),
        action: onUndo != null 
            ? SnackBarAction(label: 'Undo', onPressed: onUndo) 
            : null,
      ),
    );
  }
}
