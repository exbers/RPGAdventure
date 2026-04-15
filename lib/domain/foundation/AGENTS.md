# AGENTS.md — lib/domain/foundation

This directory is the **game-agnostic SDK namespace** inside the RPG Adventure
monorepo. It is a candidate for extraction into `packages/game_foundation` after
the MVP.

## Import boundary rules

Code in `lib/domain/foundation/` (including all `src/` sub-folders):

**ALLOWED imports:**
- `dart:*` core libraries.
- `package:flutter_application_1/core/` — cross-cutting types (`Result`,
  `GameFailure`, `ValidationResult`).
- Other files within `lib/domain/foundation/` itself.

**FORBIDDEN imports — will break the future package split:**
- `package:flutter_application_1/app/` — app wiring, routes, theme.
- `package:flutter_application_1/features/` — game-specific screens.
- `package:flutter_application_1/shared/` — app-level shared widgets.
- `package:flutter_application_1/data/` — concrete repository implementations.
- Any asset path (`assets/`), route constant (`AppRoutes`), or theme class
  (`GameTheme`).
- Flutter SDK (`package:flutter/`) in pure-Dart domain files.
  Flutter is allowed only in `ui/` sub-library files.

## No game-specific names

Foundation files must not reference concrete content such as:
- Town names (Arendor, Velmoor, …)
- Monster names (Goblin, Dragon, …)
- Screen names or route paths.

Use IDs, config objects, callbacks, and adapters instead.

## Directory layout

```
lib/domain/foundation/
  foundation.dart          ← public barrel (the only import consumers use)
  AGENTS.md                ← this file
  src/
    ids/
      entity_id.dart       ← generic EntityId base
      typed_ids.dart       ← ItemId, MonsterId, QuestId, ZoneId, TownId, …
    value_objects/
      currency.dart        ← Currency(currencyId, amount)
      quantity.dart        ← Quantity (non-negative count)
      level_range.dart     ← LevelRange(min, max)
    persistence/           ← added in SDK-004
    economy/               ← added in SDK-003
    status_effects/        ← added in SDK-005
    content_validation/    ← added in SDK-006
    ui/                    ← reusable Flutter widgets (Flutter dep allowed)
```

## Future package split path

See `foundation.dart` top-level doc comment for the step-by-step migration
guide. The summary is: copy `src/` verbatim, update the package URI, no API
changes required.
