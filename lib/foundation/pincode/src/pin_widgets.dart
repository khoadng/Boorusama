// Dart imports:
import 'dart:async';

// Flutter imports:
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:i18n/i18n.dart';
import 'package:material_symbols_icons/symbols.dart';

// Project imports:
import 'pin_credential.dart';

const _pinMinLength = 4;
const _pinLength = 4;

Future<bool> showPinSetupDialog(
  BuildContext context,
  WidgetRef ref,
) async {
  final repository = ref.read(pinCredentialRepositoryProvider);

  return await showGeneralDialog<bool>(
        context: context,
        barrierColor: Theme.of(context).colorScheme.scrim,
        pageBuilder: (context, animation, secondaryAnimation) =>
            _PinFullscreenScaffold(
              child: PinSetupPanel(
                title: context.t.settings.privacy.app_lock.set_pin,
                onCancel: () => Navigator.of(context).pop(false),
                onSubmit: (pin) async {
                  await repository.setPin(pin);
                  if (context.mounted) Navigator.of(context).pop(true);
                },
              ),
            ),
      ) ??
      false;
}

class _PinFullscreenScaffold extends StatelessWidget {
  const _PinFullscreenScaffold({
    required this.child,
  });

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Material(
      color: colorScheme.surface,
      child: SafeArea(
        child: Align(
          alignment: Alignment.topCenter,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 32, 20, 24),
            child: child,
          ),
        ),
      ),
    );
  }
}

Future<bool> showPinVerifyDialog(
  BuildContext context,
  WidgetRef ref, {
  String? title,
}) async {
  final repository = ref.read(pinCredentialRepositoryProvider);

  return await showGeneralDialog<bool>(
        context: context,
        barrierColor: Theme.of(context).colorScheme.scrim,
        pageBuilder: (context, animation, secondaryAnimation) =>
            _PinFullscreenScaffold(
              child: PinUnlockPanel(
                title:
                    title ??
                    context.t.settings.privacy.app_lock.enter_current_pin,
                onCancel: () => Navigator.of(context).pop(false),
                onSubmit: repository.verifyPin,
                onUnlocked: () => Navigator.of(context).pop(true),
              ),
            ),
      ) ??
      false;
}

class PinSetupPanel extends StatefulWidget {
  const PinSetupPanel({
    required this.title,
    required this.onSubmit,
    super.key,
    this.onCancel,
  });

  final String title;
  final VoidCallback? onCancel;
  final Future<void> Function(String pin) onSubmit;

  @override
  State<PinSetupPanel> createState() => _PinSetupPanelState();
}

class _PinSetupPanelState extends State<PinSetupPanel> {
  var _step = _PinSetupStep.create;
  var _pin = '';
  String? _firstPin;
  var _saving = false;
  String? _error;

  void _appendDigit(String digit) {
    if (_saving || _pin.length >= _pinLength) return;

    unawaited(HapticFeedback.selectionClick());

    setState(() {
      _pin += digit;
      _error = null;
    });

    if (_pin.length == _pinLength) {
      unawaited(_completeStep());
    }
  }

  void _deleteDigit() {
    if (_saving || _pin.isEmpty) return;

    unawaited(HapticFeedback.selectionClick());

    setState(() {
      _pin = _pin.substring(0, _pin.length - 1);
      _error = null;
    });
  }

  Future<void> _completeStep() async {
    final appLock = context.t.settings.privacy.app_lock;

    if (_pin.length < _pinMinLength) {
      setState(() => _error = appLock.pin_too_short(length: _pinMinLength));
      return;
    }

    if (_step == _PinSetupStep.create) {
      setState(() {
        _firstPin = _pin;
        _pin = '';
        _step = _PinSetupStep.confirm;
        _error = null;
      });
      return;
    }

    final pin = _firstPin;
    if (pin == null || _pin != pin) {
      unawaited(HapticFeedback.heavyImpact());
      setState(() {
        _pin = '';
        _error = appLock.pin_mismatch;
      });
      return;
    }

    setState(() {
      _saving = true;
      _error = null;
    });

    try {
      await widget.onSubmit(pin);
    } finally {
      if (mounted) {
        setState(() => _saving = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final appLock = context.t.settings.privacy.app_lock;
    final createStep = _step == _PinSetupStep.create;

    return _PinPadSurface(
      title: createStep ? appLock.create_pin_title : appLock.confirm_pin_title,
      subtitle: createStep
          ? appLock.choose_four_digit_pin
          : appLock.enter_pin_again,
      pinLength: _pinLength,
      enteredLength: _pin.length,
      errorText: _error,
      busy: _saving,
      onDigit: _appendDigit,
      onDelete: _deleteDigit,
      onBack: _saving ? null : widget.onCancel,
    );
  }
}

enum _PinSetupStep {
  create,
  confirm,
}

class PinUnlockPanel extends StatefulWidget {
  const PinUnlockPanel({
    required this.title,
    required this.onSubmit,
    required this.onUnlocked,
    super.key,
    this.onCancel,
    this.onDeviceUnlock,
  });

  final String title;
  final VoidCallback? onCancel;
  final VoidCallback? onDeviceUnlock;
  final Future<bool> Function(String pin) onSubmit;
  final VoidCallback onUnlocked;

  @override
  State<PinUnlockPanel> createState() => _PinUnlockPanelState();
}

class _PinUnlockPanelState extends State<PinUnlockPanel> {
  Timer? _errorTimer;
  var _pin = '';
  var _failedAttempts = 0;
  var _checking = false;
  var _showErrorState = false;
  DateTime? _retryAfter;
  String? _error;

  @override
  void dispose() {
    _errorTimer?.cancel();
    super.dispose();
  }

  void _appendDigit(String digit) {
    if (_checking || _showErrorState || _pin.length >= _pinLength) return;

    final retryAfter = _retryAfter;
    if (retryAfter != null && DateTime.now().isBefore(retryAfter)) {
      setState(() {
        _showErrorState = true;
        _error = context.t.settings.privacy.app_lock.try_again_in(
          seconds: retryAfter.difference(DateTime.now()).inSeconds + 1,
        );
      });
      return;
    }

    unawaited(HapticFeedback.selectionClick());

    setState(() {
      _pin += digit;
      _error = null;
    });

    if (_pin.length == _pinLength) {
      unawaited(_submit());
    }
  }

  void _deleteDigit() {
    if (_checking || _showErrorState || _pin.isEmpty) return;

    unawaited(HapticFeedback.selectionClick());

    setState(() {
      _pin = _pin.substring(0, _pin.length - 1);
      _error = null;
    });
  }

  Future<void> _submit() async {
    final appLock = context.t.settings.privacy.app_lock;
    final retryAfter = _retryAfter;
    if (retryAfter != null && DateTime.now().isBefore(retryAfter)) {
      setState(() {
        _error = appLock.try_again_in(
          seconds: retryAfter.difference(DateTime.now()).inSeconds + 1,
        );
      });
      return;
    }

    setState(() {
      _checking = true;
      _error = null;
    });

    try {
      final ok = await widget.onSubmit(_pin);
      if (ok) {
        widget.onUnlocked();
        return;
      }

      unawaited(HapticFeedback.heavyImpact());

      _failedAttempts += 1;
      if (_failedAttempts >= 5) {
        final seconds = (_failedAttempts - 4) * 5;
        _retryAfter = DateTime.now().add(Duration(seconds: seconds));
        _showError(seconds: seconds);
      } else {
        _showError();
      }
    } finally {
      if (mounted) {
        setState(() => _checking = false);
      }
    }
  }

  void _showError({int? seconds}) {
    _errorTimer?.cancel();

    setState(() {
      _pin = '';
      _showErrorState = true;
      _error = seconds != null
          ? context.t.settings.privacy.app_lock.try_again_in(seconds: seconds)
          : null;
    });

    _errorTimer = Timer(
      Duration(milliseconds: seconds == null ? 900 : seconds * 1000),
      () {
        if (!mounted) return;

        setState(() {
          _showErrorState = false;
          _error = null;
        });
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final appLock = context.t.settings.privacy.app_lock;

    return _PinPadSurface(
      title: _showErrorState ? appLock.incorrect_pin : widget.title,
      subtitle: _showErrorState ? _error : appLock.enter_your_pin,
      pinLength: _pinLength,
      enteredLength: _showErrorState ? _pinLength : _pin.length,
      busy: _checking,
      errorState: _showErrorState,
      showLockIcon: true,
      showKeypad: !_showErrorState,
      onDigit: _appendDigit,
      onDelete: _deleteDigit,
      onBack: _checking ? null : widget.onCancel,
      onDeviceUnlock: widget.onDeviceUnlock,
    );
  }
}

class _PinPadSurface extends StatelessWidget {
  const _PinPadSurface({
    required this.title,
    required this.subtitle,
    required this.pinLength,
    required this.enteredLength,
    required this.onDigit,
    required this.onDelete,
    this.errorText,
    this.busy = false,
    this.errorState = false,
    this.showLockIcon = false,
    this.showKeypad = true,
    this.onBack,
    this.onDeviceUnlock,
  });

  final String title;
  final String? subtitle;
  final int pinLength;
  final int enteredLength;
  final String? errorText;
  final bool busy;
  final bool errorState;
  final bool showLockIcon;
  final bool showKeypad;
  final VoidCallback? onBack;
  final VoidCallback? onDeviceUnlock;
  final ValueChanged<String> onDigit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final contentColor = errorState ? colorScheme.error : colorScheme.onSurface;
    final accentColor = errorState ? colorScheme.error : colorScheme.primary;
    final secondaryTextColor = colorScheme.onSurfaceVariant;

    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 380),
      child: Stack(
        children: [
          if (onBack != null)
            Align(
              alignment: Alignment.topLeft,
              child: IconButton(
                onPressed: busy ? null : onBack,
                icon: const Icon(Icons.arrow_back_ios_new_rounded),
              ),
            ),
          Padding(
            padding: const EdgeInsets.fromLTRB(8, 8, 8, 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (showLockIcon) ...[
                  Icon(
                    Symbols.lock,
                    size: 64,
                    color: accentColor,
                  ),
                  const SizedBox(height: 20),
                ] else if (onBack != null) ...[
                  const SizedBox(height: 44),
                ],
                Text(
                  title,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    color: contentColor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                if (subtitle case final subtitle?) ...[
                  const SizedBox(height: 8),
                  Text(
                    subtitle,
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: secondaryTextColor,
                    ),
                  ),
                ],
                const SizedBox(height: 34),
                _PinDots(
                  length: pinLength,
                  enteredLength: enteredLength,
                  color: accentColor,
                  errorState: errorState,
                ),
                if (errorText case final error?) ...[
                  const SizedBox(height: 12),
                  Text(
                    error,
                    textAlign: TextAlign.center,
                    style: TextStyle(color: colorScheme.error),
                  ),
                ],
                const SizedBox(height: 36),
                if (showKeypad)
                  _PinKeypad(
                    enabled: !busy,
                    onDigit: onDigit,
                    onDelete: onDelete,
                  )
                else
                  const SizedBox(height: 304),
                if (busy) ...[
                  const SizedBox(height: 20),
                  const SizedBox.square(
                    dimension: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                ],
                if (onDeviceUnlock != null) ...[
                  const SizedBox(height: 20),
                  TextButton(
                    onPressed: busy ? null : onDeviceUnlock,
                    child: Text(
                      context.t.settings.privacy.app_lock.use_device_unlock,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _PinDots extends StatelessWidget {
  const _PinDots({
    required this.length,
    required this.enteredLength,
    required this.color,
    required this.errorState,
  });

  final int length;
  final int enteredLength;
  final Color color;
  final bool errorState;

  @override
  Widget build(BuildContext context) {
    final outlineColor = errorState
        ? color
        : Theme.of(context).colorScheme.outlineVariant;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (var i = 0; i < length; i++) ...[
          AnimatedContainer(
            duration: const Duration(milliseconds: 120),
            width: 16,
            height: 16,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: i < enteredLength
                  ? color
                  : Theme.of(context).colorScheme.surface.withAlpha(0),
              border: Border.all(
                color: i < enteredLength ? color : outlineColor,
                width: 1.5,
              ),
            ),
          ),
          if (i != length - 1) const SizedBox(width: 34),
        ],
      ],
    );
  }
}

class _PinKeypad extends StatelessWidget {
  const _PinKeypad({
    required this.enabled,
    required this.onDigit,
    required this.onDelete,
  });

  final bool enabled;
  final ValueChanged<String> onDigit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 340,
      child: Column(
        children: [
          _PinKeypadRow(
            values: const ['1', '2', '3'],
            enabled: enabled,
            onDigit: onDigit,
          ),
          _PinKeypadRow(
            values: const ['4', '5', '6'],
            enabled: enabled,
            onDigit: onDigit,
          ),
          _PinKeypadRow(
            values: const ['7', '8', '9'],
            enabled: enabled,
            onDigit: onDigit,
          ),
          SizedBox(
            height: 76,
            child: Row(
              children: [
                const Expanded(child: SizedBox.shrink()),
                Expanded(
                  child: _PinDigitButton(
                    value: '0',
                    enabled: enabled,
                    onPressed: () => onDigit('0'),
                  ),
                ),
                Expanded(
                  child: IconButton(
                    onPressed: enabled ? onDelete : null,
                    icon: const Icon(Icons.backspace_outlined),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _PinKeypadRow extends StatelessWidget {
  const _PinKeypadRow({
    required this.values,
    required this.enabled,
    required this.onDigit,
  });

  final List<String> values;
  final bool enabled;
  final ValueChanged<String> onDigit;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 76,
      child: Row(
        children: [
          for (final value in values)
            Expanded(
              child: _PinDigitButton(
                value: value,
                enabled: enabled,
                onPressed: () => onDigit(value),
              ),
            ),
        ],
      ),
    );
  }
}

class _PinDigitButton extends StatelessWidget {
  const _PinDigitButton({
    required this.value,
    required this.enabled,
    required this.onPressed,
  });

  final String value;
  final bool enabled;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: enabled ? onPressed : null,
      style: TextButton.styleFrom(
        foregroundColor: Theme.of(context).colorScheme.onSurface,
        textStyle: Theme.of(context).textTheme.displaySmall,
        shape: const CircleBorder(),
        minimumSize: const Size.square(72),
      ),
      child: Text(value),
    );
  }
}
