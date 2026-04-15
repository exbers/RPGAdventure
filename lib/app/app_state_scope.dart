import 'package:flutter/widgets.dart';

import 'app_state.dart';

/// Provides the [AppState] composition root to the widget tree using a plain
/// [InheritedWidget] — no external state-management packages required.
///
/// Usage in screens:
/// ```dart
/// final state = AppStateScope.of(context);
/// state.hero.loadHero();
/// ```
///
/// Place [AppStateScope] above [MaterialApp] (or at least above the first
/// screen that reads state) so that all routes have access.
class AppStateScope extends InheritedWidget {
  const AppStateScope({
    super.key,
    required this.appState,
    required super.child,
  });

  final AppState appState;

  /// Returns the [AppState] from the nearest [AppStateScope] ancestor.
  ///
  /// Throws a [FlutterError] if no [AppStateScope] is found in the tree.
  static AppState of(BuildContext context) {
    final scope = context.dependOnInheritedWidgetOfExactType<AppStateScope>();
    assert(
      scope != null,
      'No AppStateScope found. Wrap your widget tree with AppStateScope.',
    );
    return scope!.appState;
  }

  /// Like [of] but without registering a dependency, for fire-and-forget
  /// reads (e.g. inside callbacks where rebuilds are not needed).
  static AppState read(BuildContext context) {
    final scope = context.getInheritedWidgetOfExactType<AppStateScope>();
    assert(
      scope != null,
      'No AppStateScope found. Wrap your widget tree with AppStateScope.',
    );
    return scope!.appState;
  }

  /// [AppStateScope] never triggers widget rebuilds by itself; individual
  /// controllers notify their own listeners via [ChangeNotifier].
  @override
  bool updateShouldNotify(AppStateScope oldWidget) =>
      appState != oldWidget.appState;
}
