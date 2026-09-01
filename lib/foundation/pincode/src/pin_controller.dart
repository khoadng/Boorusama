// Dart imports:
import 'dart:async';

// Flutter imports:
import 'package:flutter/foundation.dart';

const defaultPinMinLength = 4;
const defaultPinLength = 4;

enum PinSetupStep {
  create,
  confirm,
}

enum PinSetupError {
  tooShort,
  mismatch,
}

enum PinSetupResult {
  ignored,
  digitEntered,
  confirmPin,
  mismatch,
  saved,
}

class PinSetupController extends ChangeNotifier {
  PinSetupController({
    this.pinLength = defaultPinLength,
    this.pinMinLength = defaultPinMinLength,
  });

  final int pinLength;
  final int pinMinLength;

  PinSetupStep _step = PinSetupStep.create;
  var _pin = '';
  String? _firstPin;
  var _saving = false;
  PinSetupError? _error;

  PinSetupStep get step => _step;
  int get enteredLength => _pin.length;
  bool get saving => _saving;
  PinSetupError? get error => _error;
  bool get canEdit => !_saving;

  Future<PinSetupResult> enterDigit(
    String digit,
    Future<void> Function(String pin) savePin,
  ) async {
    if (!_isSingleDigit(digit) || _saving || _pin.length >= pinLength) {
      return PinSetupResult.ignored;
    }

    _pin += digit;
    _error = null;
    notifyListeners();

    if (_pin.length < pinLength) return PinSetupResult.digitEntered;

    return _completeStep(savePin);
  }

  PinSetupResult deleteDigit() {
    if (_saving || _pin.isEmpty) return PinSetupResult.ignored;

    _pin = _pin.substring(0, _pin.length - 1);
    _error = null;
    notifyListeners();

    return PinSetupResult.digitEntered;
  }

  Future<PinSetupResult> _completeStep(
    Future<void> Function(String pin) savePin,
  ) async {
    if (_pin.length < pinMinLength) {
      _error = PinSetupError.tooShort;
      notifyListeners();
      return PinSetupResult.ignored;
    }

    if (_step == PinSetupStep.create) {
      _firstPin = _pin;
      _pin = '';
      _step = PinSetupStep.confirm;
      _error = null;
      notifyListeners();
      return PinSetupResult.confirmPin;
    }

    final pin = _firstPin;
    if (pin == null || _pin != pin) {
      _pin = '';
      _error = PinSetupError.mismatch;
      notifyListeners();
      return PinSetupResult.mismatch;
    }

    _saving = true;
    _error = null;
    notifyListeners();

    try {
      await savePin(pin);
      return PinSetupResult.saved;
    } finally {
      _saving = false;
      notifyListeners();
    }
  }
}

enum PinUnlockResult {
  ignored,
  digitEntered,
  unlocked,
  incorrect,
  retryLocked,
}

class PinUnlockController extends ChangeNotifier {
  PinUnlockController({
    DateTime Function()? now,
    this.pinLength = defaultPinLength,
    this.maxFreeAttempts = 4,
    this.retryStep = const Duration(seconds: 5),
    this.errorDisplayDuration = const Duration(milliseconds: 900),
  }) : _now = now ?? DateTime.now;

  final DateTime Function() _now;
  final int pinLength;
  final int maxFreeAttempts;
  final Duration retryStep;
  final Duration errorDisplayDuration;

  var _pin = '';
  var _failedAttempts = 0;
  var _checking = false;
  var _showErrorState = false;
  DateTime? _retryAfter;
  int? _retrySeconds;

  int get enteredLength => _showErrorState ? pinLength : _pin.length;
  int get failedAttempts => _failedAttempts;
  bool get checking => _checking;
  bool get showErrorState => _showErrorState;
  bool get showKeypad => !_showErrorState;
  int? get retrySeconds => _retrySeconds;
  bool get canEdit => !_checking && !_showErrorState;

  Future<PinUnlockResult> enterDigit(
    String digit,
    Future<bool> Function(String pin) verifyPin,
  ) async {
    if (!_isSingleDigit(digit) || !canEdit || _pin.length >= pinLength) {
      return PinUnlockResult.ignored;
    }

    final remainingSeconds = retrySecondsRemaining();
    if (remainingSeconds != null) {
      _showRetryError(remainingSeconds);
      return PinUnlockResult.retryLocked;
    }

    _pin += digit;
    _retrySeconds = null;
    notifyListeners();

    if (_pin.length < pinLength) return PinUnlockResult.digitEntered;

    return _submit(verifyPin);
  }

  PinUnlockResult deleteDigit() {
    if (!canEdit || _pin.isEmpty) return PinUnlockResult.ignored;

    _pin = _pin.substring(0, _pin.length - 1);
    _retrySeconds = null;
    notifyListeners();

    return PinUnlockResult.digitEntered;
  }

  void clearError() {
    if (!_showErrorState) return;

    _showErrorState = false;
    _retrySeconds = null;
    notifyListeners();
  }

  int? retrySecondsRemaining() {
    final retryAfter = _retryAfter;
    if (retryAfter == null) return null;

    final remaining = retryAfter.difference(_now());
    if (remaining <= Duration.zero) {
      _retryAfter = null;
      return null;
    }

    return remaining.inSeconds + 1;
  }

  Future<PinUnlockResult> _submit(
    Future<bool> Function(String pin) verifyPin,
  ) async {
    _checking = true;
    _retrySeconds = null;
    notifyListeners();

    late final bool ok;
    try {
      ok = await verifyPin(_pin);
    } catch (_) {
      _pin = '';
      _checking = false;
      _showErrorState = false;
      _retrySeconds = null;
      notifyListeners();
      rethrow;
    }
    if (ok) {
      _pin = '';
      _failedAttempts = 0;
      _showErrorState = false;
      _retryAfter = null;
      _retrySeconds = null;
      _checking = false;
      notifyListeners();
      return PinUnlockResult.unlocked;
    }

    _failedAttempts += 1;
    final locked = _failedAttempts > maxFreeAttempts;
    final retryDuration = locked
        ? retryStep * (_failedAttempts - maxFreeAttempts)
        : null;

    if (retryDuration != null) {
      _retryAfter = _now().add(retryDuration);
      _showRetryError(retryDuration.inSeconds);
    } else {
      _showIncorrectError();
    }

    _checking = false;
    notifyListeners();

    return locked ? PinUnlockResult.retryLocked : PinUnlockResult.incorrect;
  }

  void _showIncorrectError() {
    _pin = '';
    _showErrorState = true;
    _retrySeconds = null;
  }

  void _showRetryError(int seconds) {
    _pin = '';
    _showErrorState = true;
    _retrySeconds = seconds;
    notifyListeners();
  }
}

bool _isSingleDigit(String digit) =>
    digit.length == 1 && digit.codeUnitAt(0) >= 48 && digit.codeUnitAt(0) <= 57;
