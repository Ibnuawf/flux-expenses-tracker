# Flux — Expenses Tracker

[![Flutter](https://img.shields.io/badge/Flutter-3.x-02569B?logo=flutter&logoColor=white)](https://flutter.dev)
[![Dart](https://img.shields.io/badge/Dart-%3E%3D3.0-0175C2?logo=dart&logoColor=white)](https://dart.dev)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](LICENSE)

A clean-architecture Flutter expense tracker. Log expenses, browse them by date, and visualize monthly spending with charts.

## Features

- Add, edit, and delete expenses through a bottom-sheet form with input sanitization and validation.
- Optimistic updates with automatic rollback and user feedback when persistence fails.
- Home screen listing expenses with formatted currency and dates.
- Stats screen with a monthly total and per-category expense chart (`fl_chart`).
- Local persistence via Hive (local datasource + repository).
- Polished Material 3 UI with `google_fonts`, custom theme, and snackbar feedback.

## Architecture

The app follows a layered clean architecture:

```
lib/
  core/           # config (theme, constants, DI), infrastructure (clock, id generator), utils, shared widgets
  domain/         # entities (Expense), repository interfaces, failures
  data/           # models, Hive-backed local datasource, repository implementation
  presentation/   # app shell, controllers, state, screens (home, stats), widgets
  bootstrap.dart  # app bootstrap and dependency wiring
  main.dart
```

- **Domain layer** is storage-free: `Expense` entity, `ExpenseRepository` interface, typed `Failure`s returned via a record-based `Result` type.
- **Data layer** implements the repository over a Hive-backed local datasource.
- **Presentation** uses a `ChangeNotifier` controller + immutable state pattern (initial / loading / loaded / error).
- **Dependency injection** is wired in `core/config/dependency_injection.dart`, with testable seams for the clock and ID generation (`uuid`).

## Getting Started

```bash
flutter pub get
flutter run
```

Requires Flutter with Dart SDK `>=3.0.0`.

### Tests

```bash
flutter test
```

Unit tests cover the expense controller (loading, monthly aggregation, optimistic add/delete with rollback) and input sanitization.

## Roadmap

- Recurring expenses and budgets per category.
- Export to CSV.
- Cloud sync backend behind the existing repository interface.

## License

Released under the [MIT License](LICENSE).
