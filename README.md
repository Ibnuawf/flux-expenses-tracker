# Flux — Expenses Tracker

A clean-architecture Flutter expense tracker. Log expenses, browse them by date, and visualize spending with charts.

## Features

- Add, edit, and delete expenses through a bottom-sheet form with input sanitization.
- Home screen listing expenses with formatted currency and dates.
- Stats screen with an expense chart for spending insight.
- Local persistence via `shared_preferences` (local datasource + repository).
- Polished UI with `google_fonts`, custom theme, snackbar feedback.

## Architecture

The app follows a layered clean architecture:

```
lib/
  core/           # config (theme, constants, DI), infrastructure (clock, id generator), utils, shared widgets
  domain/         # entities (Expense), repository interfaces, failures
  data/           # models, local datasource, repository implementation
  presentation/   # app shell, controllers, state, screens (home, stats), widgets
  bootstrap.dart  # app bootstrap and dependency wiring
  main.dart
```

- **Domain layer** is Flutter-free: `Expense` entity, `ExpenseRepository` interface, typed `Failure`s.
- **Data layer** implements the repository over a `shared_preferences`-backed datasource.
- **Presentation** uses a controller + immutable state pattern.
- **Dependency injection** is wired in `core/config/dependency_injection.dart`; testable seams for clock and ID generation (`uuid`).

## Getting Started

```bash
flutter pub get
flutter run
```

Requires Flutter with Dart SDK `>=3.0.0`.

## Screenshots

_Screenshots coming soon._

## License

This project is provided as-is for educational and personal use.
