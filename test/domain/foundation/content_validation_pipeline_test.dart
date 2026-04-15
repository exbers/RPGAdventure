import 'package:flutter_application_1/core/errors/game_failure.dart';
import 'package:flutter_application_1/domain/foundation/foundation.dart';
import 'package:flutter_test/flutter_test.dart';

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

List<Map<String, Object?>> _monsters(List<Map<String, Object?>> overrides) =>
    overrides;

// ---------------------------------------------------------------------------
// ValidationIssue
// ---------------------------------------------------------------------------

void main() {
  group('ValidationIssue', () {
    const issue = ValidationIssue(
      severity: IssueSeverity.error,
      path: 'monsters[0].hp',
      message: 'value -5 must not be negative',
    );

    test('toString includes severity tag, path, and message', () {
      final s = issue.toString();
      expect(s, contains('[ERROR]'));
      expect(s, contains('monsters[0].hp'));
      expect(s, contains('must not be negative'));
    });

    test('equality uses all fields', () {
      const same = ValidationIssue(
        severity: IssueSeverity.error,
        path: 'monsters[0].hp',
        message: 'value -5 must not be negative',
      );
      expect(issue, equals(same));
      expect(issue.hashCode, equals(same.hashCode));
    });

    test('detail is included in toString when present', () {
      const withDetail = ValidationIssue(
        severity: IssueSeverity.warning,
        path: 'items[1]',
        message: 'unusual weight',
        detail: 'weight=9999',
      );
      expect(withDetail.toString(), contains('weight=9999'));
    });
  });

  // -------------------------------------------------------------------------
  // ValidationReport
  // -------------------------------------------------------------------------

  group('ValidationReport', () {
    test('empty report is valid', () {
      const report = ValidationReport.empty();
      expect(report.isValid, isTrue);
      expect(report.issues, isEmpty);
    });

    test('report with only warnings is still valid', () {
      final report = ValidationReport([
        const ValidationIssue(
          severity: IssueSeverity.warning,
          path: 'items[0]',
          message: 'unusual value',
        ),
      ]);
      expect(report.isValid, isTrue);
      expect(report.warnings, hasLength(1));
      expect(report.errors, isEmpty);
    });

    test('report with an error is not valid', () {
      final report = ValidationReport([
        const ValidationIssue(
          severity: IssueSeverity.error,
          path: 'monsters[0].hp',
          message: 'negative hp',
        ),
      ]);
      expect(report.isValid, isFalse);
      expect(report.errors, hasLength(1));
    });

    test('toLog for empty report says valid', () {
      expect(const ValidationReport.empty().toLog(), contains('valid'));
    });

    test('toLog for non-empty report includes counts and paths', () {
      final report = ValidationReport([
        const ValidationIssue(
          severity: IssueSeverity.error,
          path: 'monsters[2].loot[0].chance',
          message: 'chance exceeds 1',
        ),
        const ValidationIssue(
          severity: IssueSeverity.warning,
          path: 'items[0]',
          message: 'unusual value',
        ),
      ]);
      final log = report.toLog();
      expect(log, contains('1 error'));
      expect(log, contains('1 warning'));
      expect(log, contains('monsters[2].loot[0].chance'));
    });

    test('merge combines issues from both reports', () {
      final a = ValidationReport([
        const ValidationIssue(
          severity: IssueSeverity.error,
          path: 'a',
          message: 'error a',
        ),
      ]);
      final b = ValidationReport([
        const ValidationIssue(
          severity: IssueSeverity.warning,
          path: 'b',
          message: 'warning b',
        ),
      ]);
      final merged = a.merge(b);
      expect(merged.issues, hasLength(2));
      expect(merged.errors, hasLength(1));
      expect(merged.warnings, hasLength(1));
    });

    test('toValidationFailure returns ValidationFailure with detail', () {
      final report = ValidationReport([
        const ValidationIssue(
          severity: IssueSeverity.error,
          path: 'monsters[0]',
          message: 'bad entry',
        ),
      ]);
      final failure = report.toValidationFailure('Content load failed');
      expect(failure, isA<ValidationFailure>());
      expect(failure.message, 'Content load failed');
      expect(failure.detail, isNotNull);
      expect(failure.detail, contains('monsters[0]'));
    });
  });

  // -------------------------------------------------------------------------
  // ValidationContext
  // -------------------------------------------------------------------------

  group('ValidationContext', () {
    test('currentPath is empty when stack is empty', () {
      final ctx = ValidationContext();
      expect(ctx.currentPath, isEmpty);
    });

    test('currentPath uses root if provided', () {
      final ctx = ValidationContext(root: 'monsters');
      expect(ctx.currentPath, 'monsters');
    });

    test('pushSegment and popSegment build and shrink path', () {
      final ctx = ValidationContext(root: 'monsters');
      ctx.pushSegment('monsters[2]');
      ctx.pushSegment('loot[0]');
      expect(ctx.currentPath, 'monsters.monsters[2].loot[0]');
      ctx.popSegment();
      expect(ctx.currentPath, 'monsters.monsters[2]');
    });

    test('scoped restores path after fn', () {
      final ctx = ValidationContext();
      ctx.scoped('monsters[0]', () {
        ctx.scoped('loot[0]', () {
          ctx.addError('bad chance');
        });
      });
      expect(ctx.currentPath, isEmpty);
      expect(ctx.issues, hasLength(1));
      expect(ctx.issues.first.path, 'monsters[0].loot[0]');
    });

    test('scoped restores path even when fn throws', () {
      final ctx = ValidationContext();
      expect(
        () => ctx.scoped('seg', () => throw Exception('oops')),
        throwsException,
      );
      expect(ctx.currentPath, isEmpty);
    });

    test('addError records error at currentPath', () {
      final ctx = ValidationContext(root: 'items[1]');
      ctx.addError('negative weight');
      expect(ctx.issues.first.severity, IssueSeverity.error);
      expect(ctx.issues.first.path, 'items[1]');
    });

    test('addWarning records warning at currentPath', () {
      final ctx = ValidationContext(root: 'items[1]');
      ctx.addWarning('unusual weight');
      expect(ctx.issues.first.severity, IssueSeverity.warning);
    });

    test('pathOverride overrides currentPath', () {
      final ctx = ValidationContext(root: 'root');
      ctx.addError('bad', pathOverride: 'custom.path');
      expect(ctx.issues.first.path, 'custom.path');
    });

    test('popSegment on empty stack does not throw', () {
      final ctx = ValidationContext();
      expect(() => ctx.popSegment(), returnsNormally);
    });
  });

  // -------------------------------------------------------------------------
  // DuplicateIdValidator
  // -------------------------------------------------------------------------

  group('DuplicateIdValidator', () {
    const validator = DuplicateIdValidator(listName: 'monsters');

    test('valid: no duplicates', () {
      final report = validator.run(['goblin', 'orc', 'troll']);
      expect(report.isValid, isTrue);
    });

    test('invalid: duplicate id records error at second occurrence', () {
      final report = validator.run(['goblin', 'orc', 'goblin']);
      expect(report.isValid, isFalse);
      expect(report.errors, hasLength(1));
      expect(report.errors.first.path, 'monsters[2]');
      expect(report.errors.first.message, contains('goblin'));
    });

    test('invalid: multiple distinct duplicates records one error each', () {
      final report = validator.run(['a', 'b', 'a', 'b']);
      expect(report.errors, hasLength(2));
    });

    test('valid: empty list', () {
      expect(validator.run([]).isValid, isTrue);
    });

    test('detail mentions first occurrence index', () {
      final report = validator.run(['x', 'x']);
      expect(report.errors.first.detail, contains('monsters[0]'));
    });
  });

  // -------------------------------------------------------------------------
  // ReferenceValidator
  // -------------------------------------------------------------------------

  group('ReferenceValidator', () {
    const validator = ReferenceValidator();

    test('valid: all references resolve', () {
      final input = ReferenceValidatorInput(
        listName: 'monsters',
        references: [
          {'id': 'goblin', 'zoneId': 'forest'},
          {'id': 'orc', 'zoneId': 'dungeon'},
        ],
        checks: [
          const ReferenceCheck(
            field: 'zoneId',
            knownIds: {'forest', 'dungeon'},
          ),
        ],
      );
      expect(validator.run(input).isValid, isTrue);
    });

    test('invalid: unknown reference id', () {
      final input = ReferenceValidatorInput(
        listName: 'monsters',
        references: [
          {'id': 'goblin', 'zoneId': 'unknown_zone'},
        ],
        checks: [
          const ReferenceCheck(
            field: 'zoneId',
            knownIds: {'forest', 'dungeon'},
          ),
        ],
      );
      final report = validator.run(input);
      expect(report.isValid, isFalse);
      expect(report.errors.first.path, 'monsters[0].zoneId');
      expect(report.errors.first.message, contains('unknown_zone'));
    });

    test('invalid: missing required reference field', () {
      final input = ReferenceValidatorInput(
        listName: 'monsters',
        references: [
          {'id': 'goblin'}, // zoneId absent
        ],
        checks: [
          const ReferenceCheck(field: 'zoneId', knownIds: {'forest'}),
        ],
      );
      final report = validator.run(input);
      expect(report.isValid, isFalse);
      expect(report.errors.first.path, 'monsters[0].zoneId');
      expect(report.errors.first.message, contains('missing'));
    });

    test('valid: empty entries list', () {
      final input = ReferenceValidatorInput(
        listName: 'monsters',
        references: [],
        checks: [
          const ReferenceCheck(field: 'zoneId', knownIds: {'forest'}),
        ],
      );
      expect(validator.run(input).isValid, isTrue);
    });
  });

  // -------------------------------------------------------------------------
  // RangeValidator
  // -------------------------------------------------------------------------

  group('RangeValidator', () {
    const validator = RangeValidator();

    test('valid: all numeric fields in range', () {
      final input = RangeValidatorInput(
        listName: 'monsters',
        entries: [
          {'id': 'goblin', 'hp': 10, 'attack': 3},
        ],
        checks: [
          const NumericFieldCheck(field: 'hp', allowNegative: false),
          const NumericFieldCheck(field: 'attack', min: 0, max: 9999),
        ],
      );
      expect(validator.run(input).isValid, isTrue);
    });

    test('invalid: negative hp when allowNegative is false', () {
      final input = RangeValidatorInput(
        listName: 'monsters',
        entries: [
          {'id': 'goblin', 'hp': -5},
        ],
        checks: [const NumericFieldCheck(field: 'hp', allowNegative: false)],
      );
      final report = validator.run(input);
      expect(report.isValid, isFalse);
      expect(report.errors.first.path, 'monsters[0].hp');
      expect(report.errors.first.message, contains('must not be negative'));
    });

    test('invalid: value below minimum', () {
      final input = RangeValidatorInput(
        listName: 'items',
        entries: [
          {'id': 'sword', 'level': -1},
        ],
        checks: [const NumericFieldCheck(field: 'level', min: 1)],
      );
      final report = validator.run(input);
      expect(report.isValid, isFalse);
      expect(report.errors.first.message, contains('below minimum'));
    });

    test('invalid: value above maximum', () {
      final input = RangeValidatorInput(
        listName: 'items',
        entries: [
          {'id': 'sword', 'level': 200},
        ],
        checks: [const NumericFieldCheck(field: 'level', max: 100)],
      );
      final report = validator.run(input);
      expect(report.isValid, isFalse);
      expect(report.errors.first.message, contains('exceeds maximum'));
    });

    test('invalid: non-numeric value for numeric field', () {
      final input = RangeValidatorInput(
        listName: 'monsters',
        entries: [
          {'id': 'goblin', 'hp': 'not_a_number'},
        ],
        checks: [const NumericFieldCheck(field: 'hp', allowNegative: false)],
      );
      final report = validator.run(input);
      expect(report.isValid, isFalse);
      expect(report.errors.first.message, contains('must be a number'));
    });

    test('skips absent fields (schema check is separate)', () {
      final input = RangeValidatorInput(
        listName: 'monsters',
        entries: [
          {'id': 'ghost'}, // hp absent
        ],
        checks: [const NumericFieldCheck(field: 'hp', allowNegative: false)],
      );
      expect(validator.run(input).isValid, isTrue);
    });
  });

  // -------------------------------------------------------------------------
  // ProbabilityValidator
  // -------------------------------------------------------------------------

  group('ProbabilityValidator', () {
    const validator = ProbabilityValidator();

    test('valid: individual chances in range, sum <= 1', () {
      final input = ProbabilityValidatorInput(
        groups: [
          ProbabilityGroup(path: 'monsters[0].loot', chances: [0.3, 0.2, 0.4]),
        ],
      );
      expect(validator.run(input).isValid, isTrue);
    });

    test('invalid: individual chance > 1', () {
      final input = ProbabilityValidatorInput(
        groups: [
          ProbabilityGroup(path: 'monsters[0].loot', chances: [1.5]),
        ],
      );
      final report = validator.run(input);
      expect(report.isValid, isFalse);
      expect(report.errors.first.path, 'monsters[0].loot[0].chance');
      expect(report.errors.first.message, contains('<= 1.0'));
    });

    test('invalid: individual chance < 0', () {
      final input = ProbabilityValidatorInput(
        groups: [
          ProbabilityGroup(path: 'monsters[0].loot', chances: [-0.1]),
        ],
      );
      final report = validator.run(input);
      expect(report.isValid, isFalse);
      expect(report.errors.first.message, contains('>= 0'));
    });

    test('invalid: sum of chances exceeds 1', () {
      final input = ProbabilityValidatorInput(
        groups: [
          ProbabilityGroup(path: 'monsters[0].loot', chances: [0.4, 0.4, 0.4]),
        ],
      );
      final report = validator.run(input);
      expect(report.isValid, isFalse);
      expect(report.errors.any((e) => e.path == 'monsters[0].loot'), isTrue);
    });

    test('valid: sum exactly 1.0 (within epsilon)', () {
      final input = ProbabilityValidatorInput(
        groups: [
          ProbabilityGroup(path: 'loot', chances: [0.5, 0.5]),
        ],
      );
      expect(validator.run(input).isValid, isTrue);
    });

    test('valid: sum > 1 allowed when groupSumMustNotExceedOne is false', () {
      final input = ProbabilityValidatorInput(
        groups: [
          ProbabilityGroup(
            path: 'loot',
            chances: [0.6, 0.6],
            groupSumMustNotExceedOne: false,
          ),
        ],
      );
      expect(validator.run(input).isValid, isTrue);
    });

    test('valid: empty groups', () {
      final input = ProbabilityValidatorInput(groups: []);
      expect(validator.run(input).isValid, isTrue);
    });
  });

  // -------------------------------------------------------------------------
  // SchemaValidator
  // -------------------------------------------------------------------------

  group('SchemaValidator', () {
    const validator = SchemaValidator();

    test('valid: all required fields present', () {
      final input = SchemaValidatorInput(
        schema: const ContentSchema(
          listName: 'monsters',
          requiredFields: ['id', 'hp', 'attack'],
        ),
        entries: [
          {'id': 'goblin', 'hp': 5, 'attack': 2},
        ],
      );
      expect(validator.run(input).isValid, isTrue);
    });

    test('invalid: missing id field', () {
      final input = SchemaValidatorInput(
        schema: const ContentSchema(
          listName: 'monsters',
          requiredFields: ['id', 'hp'],
        ),
        entries: [
          {'hp': 5}, // id absent
        ],
      );
      final report = validator.run(input);
      expect(report.isValid, isFalse);
      expect(report.errors.first.path, 'monsters[0].id');
      expect(report.errors.first.message, contains('missing'));
    });

    test('invalid: empty id field value', () {
      final input = SchemaValidatorInput(
        schema: const ContentSchema(
          listName: 'monsters',
          requiredFields: ['id'],
        ),
        entries: [
          {'id': ''},
        ],
      );
      final report = validator.run(input);
      expect(report.isValid, isFalse);
    });

    test('invalid: missing required non-id field', () {
      final input = SchemaValidatorInput(
        schema: const ContentSchema(
          listName: 'monsters',
          requiredFields: ['id', 'hp'],
        ),
        entries: [
          {'id': 'goblin'}, // hp missing
        ],
      );
      final report = validator.run(input);
      expect(report.isValid, isFalse);
      expect(report.errors.first.path, 'monsters[0].hp');
    });

    test('invalid: null required field value', () {
      final input = SchemaValidatorInput(
        schema: const ContentSchema(
          listName: 'monsters',
          requiredFields: ['id', 'hp'],
        ),
        entries: [
          {'id': 'goblin', 'hp': null},
        ],
      );
      expect(validator.run(input).isValid, isFalse);
    });

    test('valid: empty entries list', () {
      final input = SchemaValidatorInput(
        schema: const ContentSchema(
          listName: 'monsters',
          requiredFields: ['id', 'hp'],
        ),
        entries: [],
      );
      expect(validator.run(input).isValid, isTrue);
    });

    test('custom idField is checked separately', () {
      final input = SchemaValidatorInput(
        schema: const ContentSchema(
          listName: 'items',
          requiredFields: ['item_id', 'name'],
          idField: 'item_id',
        ),
        entries: [
          {'name': 'sword'}, // item_id absent
        ],
      );
      final report = validator.run(input);
      expect(report.isValid, isFalse);
      expect(report.errors.any((e) => e.path.contains('item_id')), isTrue);
    });
  });

  // -------------------------------------------------------------------------
  // ValidationPipeline
  // -------------------------------------------------------------------------

  group('ValidationPipeline', () {
    test('empty pipeline produces valid empty report', () {
      final pipeline = ValidationPipeline<List<String>>([]);
      expect(pipeline.run([]).isValid, isTrue);
    });

    test('pipeline runs all validators and collects all issues', () {
      // Two DuplicateIdValidators with different list names used as a
      // stand-in for a multi-validator pipeline.
      final pipeline = ValidationPipeline<List<String>>([
        const DuplicateIdValidator(listName: 'pass1'),
        const DuplicateIdValidator(listName: 'pass2'),
      ]);
      final report = pipeline.run(['a', 'b', 'a']);
      // Both validators fire on the same list — 2 errors total.
      expect(report.errors, hasLength(2));
    });

    test('pipeline stops on later validator even if earlier had errors', () {
      // Ensures the pipeline is non-short-circuiting.
      final pipeline = ValidationPipeline<List<String>>([
        const DuplicateIdValidator(listName: 'first'),
        const DuplicateIdValidator(listName: 'second'),
      ]);
      // 'x' duplicated twice, each validator records one error.
      final report = pipeline.run(['x', 'y', 'x']);
      expect(report.errors, hasLength(2));
    });
  });

  // -------------------------------------------------------------------------
  // Integration: full pipeline on sample content
  // -------------------------------------------------------------------------

  group('Integration — sample monster content', () {
    // Sample content registry.
    const knownZones = {'forest', 'dungeon', 'cave'};

    final validEntries = _monsters([
      {
        'id': 'goblin',
        'zoneId': 'forest',
        'hp': 10,
        'attack': 3,
        'lootChances': [0.3, 0.2],
      },
      {
        'id': 'orc',
        'zoneId': 'dungeon',
        'hp': 25,
        'attack': 7,
        'lootChances': [0.5],
      },
    ]);

    SchemaValidator schemaValidator() => const SchemaValidator();
    RangeValidator rangeValidator() => const RangeValidator();
    ReferenceValidator refValidator() => const ReferenceValidator();
    DuplicateIdValidator dupValidator() =>
        const DuplicateIdValidator(listName: 'monsters');

    test('valid sample content passes all validators', () {
      final ids = validEntries.map((e) => e['id'] as String).toList();
      final dupReport = dupValidator().run(ids);

      final schemaInput = SchemaValidatorInput(
        schema: const ContentSchema(
          listName: 'monsters',
          requiredFields: ['id', 'hp', 'attack'],
        ),
        entries: validEntries,
      );
      final schemaReport = schemaValidator().run(schemaInput);

      final rangeInput = RangeValidatorInput(
        listName: 'monsters',
        entries: validEntries,
        checks: [
          const NumericFieldCheck(field: 'hp', allowNegative: false),
          const NumericFieldCheck(field: 'attack', allowNegative: false),
        ],
      );
      final rangeReport = rangeValidator().run(rangeInput);

      final refInput = ReferenceValidatorInput(
        listName: 'monsters',
        references: validEntries,
        checks: [ReferenceCheck(field: 'zoneId', knownIds: knownZones)],
      );
      final refReport = refValidator().run(refInput);

      final combined = dupReport
          .merge(schemaReport)
          .merge(rangeReport)
          .merge(refReport);

      expect(combined.isValid, isTrue, reason: combined.toLog());
    });

    test('invalid content: duplicate id + negative stat + bad reference', () {
      final badEntries = _monsters([
        {
          'id': 'goblin',
          'zoneId': 'forest',
          'hp': -1, // negative hp
          'attack': 3,
        },
        {
          'id': 'goblin', // duplicate id
          'zoneId': 'void_zone', // unknown zone
          'hp': 5,
          'attack': 2,
        },
      ]);

      final ids = badEntries.map((e) => e['id'] as String).toList();
      final dupReport = dupValidator().run(ids);

      final rangeInput = RangeValidatorInput(
        listName: 'monsters',
        entries: badEntries,
        checks: [const NumericFieldCheck(field: 'hp', allowNegative: false)],
      );
      final rangeReport = rangeValidator().run(rangeInput);

      final refInput = ReferenceValidatorInput(
        listName: 'monsters',
        references: badEntries,
        checks: [ReferenceCheck(field: 'zoneId', knownIds: knownZones)],
      );
      final refReport = refValidator().run(refInput);

      final combined = dupReport.merge(rangeReport).merge(refReport);

      expect(combined.isValid, isFalse);
      // Duplicate id error.
      expect(combined.errors.any((e) => e.message.contains('goblin')), isTrue);
      // Negative stat error.
      expect(combined.errors.any((e) => e.path.contains('hp')), isTrue);
      // Unknown reference error.
      expect(
        combined.errors.any((e) => e.message.contains('void_zone')),
        isTrue,
      );
    });

    test('ValidationFailure contains path information in detail', () {
      final badEntries = _monsters([
        {'id': 'goblin', 'hp': -99, 'attack': 3, 'zoneId': 'forest'},
      ]);
      final rangeInput = RangeValidatorInput(
        listName: 'monsters',
        entries: badEntries,
        checks: [const NumericFieldCheck(field: 'hp', allowNegative: false)],
      );
      final report = const RangeValidator().run(rangeInput);
      final failure = report.toValidationFailure('Content load failed');
      expect(failure, isA<ValidationFailure>());
      expect(failure.detail, contains('monsters[0].hp'));
    });
  });
}
