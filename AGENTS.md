# AGENTS.md

## Scope

These instructions apply to the whole repository. Add a nested `AGENTS.md` only
when a subdirectory truly needs different rules.

## Project Context

This is a Flutter project for an Android-first text strategy game. Optimize for
clear game rules, deterministic state changes, readable UI, and tests around
turns, resources, choices, progression, and save/load behavior.

The current project is intentionally small:

- Dart SDK constraint: `^3.11.4`.
- Lints: `package:flutter_lints/flutter.yaml`.
- Runtime dependencies: Flutter SDK and `cupertino_icons`.
- Dev dependencies: `flutter_test` and `flutter_lints`.

Do not assume extra packages or generators are available unless they are already
declared in `pubspec.yaml`.

## Repository Layout

- `lib/` contains application code.
- `test/` contains Dart and Flutter tests.
- `android/` contains Android platform configuration.
- Do not edit generated or local machine output such as `build/`, `.dart_tool/`,
  `.metadata`, or `android/local.properties` unless explicitly requested.

## Validation Commands

Run the relevant checks after code changes:

- Format Dart code: `dart format .`
- Static analysis: `flutter analyze`
- Tests: `flutter test`

If `flutter` or `dart` is not available in `PATH`, say so clearly and do not
claim validation passed.

## Architecture

- Keep game rules, turn resolution, resource calculations, progression, and
  save-state logic outside widgets.
- Prefer small pure-Dart classes and functions for domain logic so they can be
  unit-tested without a Flutter widget tree.
- Keep widgets focused on rendering state and forwarding user intent.
- Use simple constructor dependency injection before adding a dependency
  injection package.
- Prefer feature-based organization once the project grows, for example
  `lib/features/<feature>/presentation`, `domain`, and `data`.

## Reusable Game Foundation SDK

When implementing systems that could be useful outside this game, design them as
part of a reusable Game Foundation SDK instead of coupling them to the current
app.

Reusable candidates include:

- persistence and save/load abstractions;
- data-driven content loading and validation;
- economy, currencies, prices, and trade rules;
- reputation, factions, standings, and relationship modifiers;
- inventory, cargo, item stacks, capacity, and transfer rules;
- status effects, modifiers, timers, and conditions;
- reusable Flutter UI for trading, inventory, resources, reputation, and status
  panels.

Keep reusable code game-agnostic:

- Do not import app screens, routes, assets, themes, or current-game feature
  folders from reusable systems.
- Prefer pure Dart for domain systems. Add Flutter dependencies only for
  reusable UI components.
- Expose stable public APIs through package entrypoints and keep implementation
  details inside `lib/src`.
- Use IDs, config objects, adapters, and callbacks instead of hard-coded game
  names, story entities, assets, or routes.
- Keep persistence behind interfaces so storage can be swapped without changing
  game rules.
- Keep UI components data-driven: widgets should receive models/configuration
  and callbacks rather than owning game-specific state.
- Add unit tests for reusable domain systems before wiring them into the app.

Preferred future package split:

- `packages/game_foundation`: pure Dart domain systems and contracts.
- `packages/game_persistence`: save/load adapters if persistence grows beyond
  simple files or key-value storage.
- `packages/game_ui_kit`: Flutter widgets for reusable game UI.
- The app remains the composition layer that binds game-specific content,
  screens, assets, and platform behavior.

## State Management

- Use Flutter built-ins first: `setState`, `ValueNotifier`,
  `ValueListenableBuilder`, `ChangeNotifier`, `ListenableBuilder`,
  `FutureBuilder`, and `StreamBuilder`.
- Do not add Provider, Riverpod, Bloc, GetX, or another state-management package
  unless the requested change clearly needs it.
- For shared game state, keep mutations explicit and testable. Avoid hiding game
  rule changes inside widget callbacks.

## Routing

- Use Flutter's built-in `Navigator` for simple Android-only flows.
- Add `go_router` or another routing package only when the app needs declarative
  routing, deep links, web URL support, or complex redirects.

## Dependencies

- Do not add production dependencies without explaining why the Flutter/Dart SDK
  or existing code is insufficient.
- Prefer stable, actively maintained packages from `pub.dev` when a dependency is
  justified.
- After dependency changes, update `pubspec.yaml`, keep `pubspec.lock`
  consistent, and mention any Android impact.
- Do not introduce code generation (`build_runner`, `json_serializable`,
  `freezed`, mock generators, etc.) unless the project already uses it or the
  task explicitly benefits from it.

## Flutter And Dart Style

- Follow the configured Flutter lints.
- Prefer `const` constructors where possible.
- Use meaningful names and avoid abbreviations.
- Keep functions and widgets small enough to read without jumping through the
  file.
- Prefer composition over inheritance.
- Use immutable data for game state snapshots when practical.
- Avoid expensive work in `build()` methods.
- Use `ListView.builder`, `GridView.builder`, or slivers for long lists.
- Preserve modern Dart syntax supported by the SDK constraint; do not downgrade
  code style without a compatibility reason.

## Android-First UI

- Design first for Android phone screens.
- Handle small screens, large text scaling, dark mode, and long localized text.
- Use Material widgets and a centralized `ThemeData`.
- Keep text-strategy screens readable: clear hierarchy, adequate contrast,
  stable layouts, and accessible tap targets.
- Add assets only when needed, declare them in `pubspec.yaml`, and keep licensing
  appropriate.

## Testing

- Add or update tests for game-rule changes.
- Prefer unit tests for domain logic such as turn resolution, resources,
  progression, and save/load serialization.
- Use widget tests for meaningful UI behavior.
- Use integration tests only for broader flows or platform behavior where unit
  and widget tests are insufficient.
- The project currently uses `flutter_test`; add `package:test`, `checks`,
  `mockito`, or `mocktail` only when there is a clear need.
- Prefer fakes and stubs over generated mocks.

## Logging And Errors

- Prefer explicit error handling over silent failures.
- Use `debugPrint` for temporary Flutter debug output.
- Use `dart:developer` logging for structured diagnostic logs.
- Do not add a logging package unless the app needs configurable production
  logging.

## Android Platform Rules

- Do not change `applicationId`, signing config, SDK versions, permissions, or
  Gradle settings unless the task requires it.
- Explain any Android manifest permission before adding it.
- Keep release-signing changes out of normal feature work unless explicitly
  requested.

## Documentation

- Document public APIs when they are part of reusable domain, data, or platform
  code.
- Prefer comments that explain why something exists, not comments that repeat
  what the code already says.
- Keep project documentation concise and synchronized with actual dependencies
  and commands.

## Agent Workflow

- Read the relevant files before editing.
- Keep changes scoped to the requested behavior.
- Do not rewrite unrelated Flutter template or platform files.
- Do not remove user changes.
- In the final response, summarize changed files and validation commands run.
