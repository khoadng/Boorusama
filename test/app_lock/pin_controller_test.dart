// Flutter imports:
import 'package:flutter_test/flutter_test.dart';

// Project imports:
import 'package:boorusama/foundation/pincode/src/pin_controller.dart';

void main() {
  group('PinSetupController', () {
    test('moves from create to confirm and saves matching PIN', () async {
      final controller = PinSetupController();
      String? savedPin;

      expect(
        await _enterSetupPin(controller, '1234'),
        PinSetupResult.confirmPin,
      );
      expect(controller.step, PinSetupStep.confirm);
      expect(controller.enteredLength, 0);

      expect(
        await _enterSetupPin(
          controller,
          '1234',
          savePin: (pin) async => savedPin = pin,
        ),
        PinSetupResult.saved,
      );

      expect(savedPin, '1234');
      expect(controller.saving, isFalse);
      expect(controller.error, isNull);
    });

    test('keeps confirm step and clears entered PIN on mismatch', () async {
      final controller = PinSetupController();

      await _enterSetupPin(controller, '1234');

      expect(await _enterSetupPin(controller, '4321'), PinSetupResult.mismatch);
      expect(controller.step, PinSetupStep.confirm);
      expect(controller.enteredLength, 0);
      expect(controller.error, PinSetupError.mismatch);
    });
  });

  group('PinUnlockController', () {
    test('unlocks after a matching PIN', () async {
      final controller = PinUnlockController();
      final submittedPins = <String>[];

      final result = await _enterUnlockPin(
        controller,
        '1234',
        verifyPin: (pin) async {
          submittedPins.add(pin);
          return pin == '1234';
        },
      );

      expect(result, PinUnlockResult.unlocked);
      expect(submittedPins, ['1234']);
      expect(controller.enteredLength, 0);
      expect(controller.failedAttempts, 0);
      expect(controller.checking, isFalse);
      expect(controller.showErrorState, isFalse);
    });

    test('shows incorrect state after a wrong PIN', () async {
      final controller = PinUnlockController();

      final result = await _enterUnlockPin(
        controller,
        '0000',
        verifyPin: (_) async => false,
      );

      expect(result, PinUnlockResult.incorrect);
      expect(controller.failedAttempts, 1);
      expect(controller.showErrorState, isTrue);
      expect(controller.showKeypad, isFalse);
      expect(controller.enteredLength, controller.pinLength);

      controller.clearError();

      expect(controller.showErrorState, isFalse);
      expect(controller.enteredLength, 0);
    });

    test('locks retries after repeated wrong PINs', () async {
      var now = DateTime(2026);
      final controller = PinUnlockController(now: () => now);

      for (var i = 0; i < 4; i++) {
        expect(
          await _enterUnlockPin(
            controller,
            '0000',
            verifyPin: (_) async => false,
          ),
          PinUnlockResult.incorrect,
        );
        controller.clearError();
      }

      expect(
        await _enterUnlockPin(
          controller,
          '0000',
          verifyPin: (_) async => false,
        ),
        PinUnlockResult.retryLocked,
      );
      expect(controller.retrySeconds, 5);

      controller.clearError();
      now = now.add(const Duration(seconds: 3));

      expect(
        await controller.enterDigit('1', (_) async => true),
        PinUnlockResult.retryLocked,
      );
      expect(controller.retrySeconds, 3);
      expect(controller.showErrorState, isTrue);
    });

    test('verification failure restores an editable controller', () async {
      final controller = PinUnlockController();

      await expectLater(
        _enterUnlockPin(
          controller,
          '1234',
          verifyPin: (_) => Future<bool>.error(StateError('storage failed')),
        ),
        throwsStateError,
      );

      expect(controller.checking, isFalse);
      expect(controller.canEdit, isTrue);
      expect(controller.enteredLength, 0);
    });
  });
}

Future<PinSetupResult> _enterSetupPin(
  PinSetupController controller,
  String pin, {
  Future<void> Function(String pin)? savePin,
}) async {
  var result = PinSetupResult.ignored;
  for (final digit in pin.split('')) {
    result = await controller.enterDigit(digit, savePin ?? (_) async {});
  }
  return result;
}

Future<PinUnlockResult> _enterUnlockPin(
  PinUnlockController controller,
  String pin, {
  required Future<bool> Function(String pin) verifyPin,
}) async {
  var result = PinUnlockResult.ignored;
  for (final digit in pin.split('')) {
    result = await controller.enterDigit(digit, verifyPin);
  }
  return result;
}
