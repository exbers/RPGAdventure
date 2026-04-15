import 'package:flutter_application_1/domain/foundation/foundation.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('TransferResult', () {
    group('TransferSuccess', () {
      test('holds movedQuantity', () {
        const result = TransferSuccess(movedQuantity: 5);
        expect(result.movedQuantity, equals(5));
      });

      test('toString includes movedQuantity', () {
        expect(
          const TransferSuccess(movedQuantity: 3).toString(),
          contains('3'),
        );
      });
    });

    group('TransferFailure', () {
      test('holds reason', () {
        const result = TransferFailure(
          reason: TransferFailureReason.destinationFull,
        );
        expect(result.reason, equals(TransferFailureReason.destinationFull));
        expect(result.partialQuantity, isNull);
      });

      test('holds partial quantity when supplied', () {
        const result = TransferFailure(
          reason: TransferFailureReason.weightLimitExceeded,
          partialQuantity: 2,
        );
        expect(result.partialQuantity, equals(2));
      });

      test('toString includes reason', () {
        const result = TransferFailure(
          reason: TransferFailureReason.itemNotFound,
        );
        expect(result.toString(), contains('itemNotFound'));
      });
    });

    group('exhaustive sealed class handling', () {
      test('switch covers success and failure without default', () {
        // This test verifies that the sealed class hierarchy is exhaustive
        // at the type level — if a new subtype is added without being handled
        // in this switch, the Dart analyser will flag it as an error.
        const TransferResult result = TransferSuccess(movedQuantity: 10);

        final label = switch (result) {
          TransferSuccess(:final movedQuantity) => 'moved $movedQuantity',
          TransferFailure(:final reason) => 'failed: $reason',
        };

        expect(label, equals('moved 10'));
      });

      test('switch on failure path extracts reason', () {
        const TransferResult result = TransferFailure(
          reason: TransferFailureReason.insufficientQuantity,
        );

        final label = switch (result) {
          TransferSuccess() => 'success',
          TransferFailure(:final reason) => reason.name,
        };

        expect(label, equals('insufficientQuantity'));
      });
    });

    group('TransferFailureReason values', () {
      test('all expected values are present', () {
        final names = TransferFailureReason.values.map((r) => r.name).toSet();
        expect(
          names,
          containsAll([
            'destinationFull',
            'weightLimitExceeded',
            'insufficientQuantity',
            'itemLocked',
            'sameInventory',
            'itemNotFound',
            'unknown',
          ]),
        );
      });
    });
  });
}
