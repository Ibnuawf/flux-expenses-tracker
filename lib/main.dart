import 'dart:async';
import 'package:flutter/material.dart';
import 'bootstrap.dart';
import 'core/utils/logger.dart';

void main() {
  runZonedGuarded(() async {
    WidgetsFlutterBinding.ensureInitialized();
    final app = await Bootstrap.build();
    runApp(app);
  }, (error, stack) {
    Logger.log("Critical App Failure", error);
    // In production: report to Crashlytics
    runApp(
      MaterialApp(
        home: Scaffold(
          body: Center(child: Text("Fatal Error: $error")),
        ),
      ),
    );
  });
}
