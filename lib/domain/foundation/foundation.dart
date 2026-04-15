/// Game Foundation SDK — public entrypoint.
///
/// This library groups all game-agnostic domain systems that are candidates for
/// a future package split into `packages/game_foundation`.
///
/// ## What belongs here
///
/// - Persistence and save/load abstractions.
/// - Data-driven content loading and validation.
/// - Economy: currencies, prices, trade rules.
/// - Reputation, factions, standings, relationship modifiers.
/// - Inventory, cargo, item stacks, capacity, transfer rules.
/// - Status effects, modifiers, timers, and conditions.
/// - ID / value-object types used as stable content references.
///
/// ## Import boundary (enforced by convention until package split)
///
/// Files inside `lib/domain/foundation/` MUST NOT import from:
/// - `package:flutter_application_1/app/`
/// - `package:flutter_application_1/features/`
/// - `package:flutter_application_1/shared/`
/// - Flutter asset paths, themes, or route constants.
///
/// They MAY import from:
/// - `package:flutter_application_1/core/` (cross-cutting types: Result,
///   GameFailure, ValidationResult).
/// - `dart:*` libraries.
///
/// Reusable Flutter UI widgets go into a separate `ui/` sub-library when they
/// are added; they follow the same boundary but are allowed to import Flutter.
///
/// ## Future package split path
///
/// When the project is ready to extract into packages, the migration is:
///
/// 1. Create `packages/game_foundation/` as a `dart` package (no Flutter dep).
/// 2. Copy `lib/domain/foundation/src/` → `packages/game_foundation/lib/src/`.
/// 3. Copy `lib/domain/foundation/foundation.dart` →
///    `packages/game_foundation/lib/game_foundation.dart`; adjust the package
///    URI (`package:game_foundation/game_foundation.dart`).
/// 4. In the app `pubspec.yaml`, add a path dependency:
///    `game_foundation: { path: ../packages/game_foundation }`.
/// 5. Do a project-wide replace of the old import URI with the new package URI.
///    No domain logic needs rewriting because the public API is unchanged.
/// 6. Repeat for `game_persistence` and `game_ui_kit` when those grow.
///
/// API stability guarantee: public symbols exported from this file must keep
/// their names and signatures stable across the intra-monorepo phase so that
/// the search-and-replace migration above requires zero logic changes.
library;

// Identifiers and value objects (SDK-001 / SDK-002).
export 'src/ids/entity_id.dart';
export 'src/ids/typed_ids.dart';
export 'src/value_objects/currency.dart';
export 'src/value_objects/game_duration.dart';
export 'src/value_objects/level_range.dart';
export 'src/value_objects/quantity.dart';
export 'src/value_objects/weight.dart';
// Content validation pipeline (SDK-002 / SDK-006).
export 'src/validation/content_validator.dart';
export 'src/validation/duplicate_id_validator.dart';
export 'src/validation/id_validation_result.dart';
export 'src/validation/id_validator.dart';
export 'src/validation/probability_validator.dart';
export 'src/validation/range_validator.dart';
export 'src/validation/reference_validator.dart';
export 'src/validation/schema_validator.dart';
export 'src/validation/validation_context.dart';
export 'src/validation/validation_issue.dart';
export 'src/validation/validation_pipeline.dart';
export 'src/validation/validation_report.dart';
// Inventory contracts (SDK-003).
export 'src/inventory/inventory_capacity.dart';
export 'src/inventory/item_instance.dart';
export 'src/inventory/item_stack.dart';
export 'src/inventory/transfer_result.dart';
// Economy contracts (SDK-003).
export 'src/economy/limited_stock.dart';
export 'src/economy/price_quote.dart';
export 'src/economy/restock_schedule.dart';
export 'src/economy/trade_request.dart';
// Persistence contracts (SDK-004).
export 'src/persistence/persistence.dart';
// Status effects, modifiers, duration & stacking policies (SDK-005).
export 'src/effects/duration_policy.dart';
export 'src/effects/effect_target.dart';
export 'src/effects/modifier.dart';
export 'src/effects/stacking_policy.dart';
export 'src/effects/status_effect.dart';
// Time abstractions: Clock, SystemClock, FakeClock, TimerService (SDK-005).
export 'src/time/clock.dart';
export 'src/time/fake_clock.dart';
export 'src/time/game_time_calculator.dart';
export 'src/time/system_clock.dart';
export 'src/time/timer_entry.dart';
export 'src/time/timer_service.dart';
