import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'core/config/dependency_injection.dart';
import 'presentation/app.dart';
export 'presentation/app.dart';

class Bootstrap {
  static Future<Widget> build() async {
    final providers = await DependencyInjection.setup();

    return MultiProvider(
      providers: providers,
      child: const ExpenseApp(),
    );
  }
}
