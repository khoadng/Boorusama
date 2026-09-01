// Dart imports:
import 'dart:async';

// Flutter imports:
import 'package:flutter/services.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:i18n/i18n.dart';
import 'package:kurumi/material.dart';
import 'package:material_symbols_icons/symbols.dart';

// Project imports:
import 'pin_controller.dart';
import 'pin_credential.dart';

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
              onBack: () => Navigator.of(context).pop(false),
              child: PinSetupPanel(
                title: context.t.settings.privacy.app_lock.set_pin,
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
    required this.onBack,
  });

  final Widget child;
  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Material(
      color: colorScheme.surface,
      child: SafeArea(
        child: Stack(
          children: [
            Positioned.fill(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  const padding = EdgeInsets.fromLTRB(20, 64, 20, 24);
                  final minimumContentHeight = constraints.maxHeight > 88
                      ? constraints.maxHeight - 88
                      : 0.0;

                  return SingleChildScrollView(
                    padding: padding,
                    child: ConstrainedBox(
                      constraints: BoxConstraints(
                        minHeight: minimumContentHeight,
                      ),
                      child: Center(child: child),
                    ),
                  );
                },
              ),
            ),
            PositionedDirectional(
              start: 8,
              top: 8,
              child: BackButton(onPressed: onBack),
            ),
          ],
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
              onBack: () => Navigator.of(context).pop(false),
              child: PinUnlockPanel(
                title:
                    title ??
                    context.t.settings.privacy.app_lock.enter_current_pin,
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
  });

  final String title;
  final Future<void> Function(String pin) onSubmit;

  @override
  State<PinSetupPanel> createState() => _PinSetupPanelState();
}

class _PinSetupPanelState extends State<PinSetupPanel> {
  late final PinSetupController _controller;

  @override
  void initState() {
    super.initState();
    _controller = PinSetupController()..addListener(_controllerChanged);
  }

  @override
  void dispose() {
    _controller
      ..removeListener(_controllerChanged)
      ..dispose();
    super.dispose();
  }

  void _controllerChanged() {
    if (mounted) setState(() {});
  }

  void _appendDigit(String digit) {
    if (!_controller.canEdit) return;

    unawaited(HapticFeedback.selectionClick());

    unawaited(
      _controller.enterDigit(digit, widget.onSubmit).then((result) {
        if (result == PinSetupResult.mismatch) {
          unawaited(HapticFeedback.heavyImpact());
        }
      }),
    );
  }

  void _deleteDigit() {
    if (_controller.deleteDigit() != PinSetupResult.ignored) {
      unawaited(HapticFeedback.selectionClick());
    }
  }

  String? _errorText(BuildContext context) {
    final error = _controller.error;
    if (error == null) return null;

    final appLock = context.t.settings.privacy.app_lock;
    return switch (error) {
      PinSetupError.tooShort => appLock.pin_too_short(
        length: _controller.pinMinLength,
      ),
      PinSetupError.mismatch => appLock.pin_mismatch,
    };
  }

  @override
  Widget build(BuildContext context) {
    final appLock = context.t.settings.privacy.app_lock;
    final createStep = _controller.step == PinSetupStep.create;

    return _PinPadSurface(
      title: createStep ? appLock.create_pin_title : appLock.confirm_pin_title,
      subtitle: createStep
          ? appLock.choose_four_digit_pin
          : appLock.enter_pin_again,
      pinLength: _controller.pinLength,
      enteredLength: _controller.enteredLength,
      errorText: _errorText(context),
      busy: _controller.saving,
      onDigit: _appendDigit,
      onDelete: _deleteDigit,
    );
  }
}

class PinUnlockPanel extends StatefulWidget {
  const PinUnlockPanel({
    required this.title,
    required this.onSubmit,
    required this.onUnlocked,
    super.key,
    this.onDeviceUnlock,
  });

  final String title;
  final VoidCallback? onDeviceUnlock;
  final Future<bool> Function(String pin) onSubmit;
  final VoidCallback onUnlocked;

  @override
  State<PinUnlockPanel> createState() => _PinUnlockPanelState();
}

class _PinUnlockPanelState extends State<PinUnlockPanel> {
  late final PinUnlockController _controller;
  Timer? _errorTimer;

  @override
  void initState() {
    super.initState();
    _controller = PinUnlockController()..addListener(_controllerChanged);
  }

  @override
  void dispose() {
    _errorTimer?.cancel();
    _controller
      ..removeListener(_controllerChanged)
      ..dispose();
    super.dispose();
  }

  void _controllerChanged() {
    if (mounted) setState(() {});
  }

  void _appendDigit(String digit) {
    if (!_controller.canEdit) return;

    unawaited(HapticFeedback.selectionClick());

    unawaited(
      _controller.enterDigit(digit, widget.onSubmit).then((result) {
        if (!mounted) return;

        switch (result) {
          case PinUnlockResult.unlocked:
            widget.onUnlocked();
          case PinUnlockResult.incorrect || PinUnlockResult.retryLocked:
            unawaited(HapticFeedback.heavyImpact());
            _scheduleErrorClear();
          case PinUnlockResult.ignored || PinUnlockResult.digitEntered:
            break;
        }
      }),
    );
  }

  void _deleteDigit() {
    if (_controller.deleteDigit() != PinUnlockResult.ignored) {
      unawaited(HapticFeedback.selectionClick());
    }
  }

  void _scheduleErrorClear() {
    _errorTimer?.cancel();

    final seconds = _controller.retrySeconds;
    final duration = seconds == null
        ? _controller.errorDisplayDuration
        : Duration(seconds: seconds);

    _errorTimer = Timer(duration, _controller.clearError);
  }

  String? _subtitle(BuildContext context) {
    final appLock = context.t.settings.privacy.app_lock;
    final seconds = _controller.retrySeconds;

    if (!_controller.showErrorState) return appLock.enter_your_pin;
    if (seconds == null) return null;

    return appLock.try_again_in(seconds: seconds);
  }

  @override
  Widget build(BuildContext context) {
    final appLock = context.t.settings.privacy.app_lock;

    return _PinPadSurface(
      title: _controller.showErrorState ? appLock.incorrect_pin : widget.title,
      subtitle: _subtitle(context),
      pinLength: _controller.pinLength,
      enteredLength: _controller.enteredLength,
      busy: _controller.checking,
      errorState: _controller.showErrorState,
      showLockIcon: true,
      showKeypad: _controller.showKeypad,
      onDigit: _appendDigit,
      onDelete: _deleteDigit,
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
  final VoidCallback? onDeviceUnlock;
  final ValueChanged<String> onDigit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final contentColor = errorState ? colorScheme.error : colorScheme.onSurface;
    final accentColor = errorState ? colorScheme.error : colorScheme.primary;
    final secondaryTextColor = colorScheme.onSurfaceVariant;
    final viewport = MediaQuery.sizeOf(context);
    final useColumns =
        viewport.width >= 600 &&
        (viewport.height < 600 || viewport.width >= 840);
    final keypadRowHeight = useColumns && viewport.height < 600
        ? ((viewport.height - 96) / 4).clamp(56.0, 76.0)
        : 76.0;

    final status = Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (showLockIcon) ...[
          Icon(
            Symbols.lock,
            size: 64,
            color: accentColor,
          ),
          const SizedBox(height: 20),
        ],
        Text(
          title,
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
            color: contentColor,
            fontWeight: FontWeight.w600,
          ),
        ),
        SizedBox(
          height: 48,
          child: subtitle == null
              ? null
              : Center(
                  child: Text(
                    subtitle!,
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: secondaryTextColor,
                    ),
                  ),
                ),
        ),
        SizedBox(height: useColumns ? 16 : 20),
        _PinDots(
          length: pinLength,
          enteredLength: enteredLength,
          color: accentColor,
          errorState: errorState,
        ),
        SizedBox(
          height: 36,
          child: busy
              ? const Center(
                  child: SizedBox.square(
                    dimension: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                )
              : errorText == null
              ? null
              : Center(
                  child: Text(
                    errorText!,
                    textAlign: TextAlign.center,
                    style: TextStyle(color: colorScheme.error),
                  ),
                ),
        ),
      ],
    );

    final controls = ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 340),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (showKeypad)
            _PinKeypad(
              enabled: !busy,
              rowHeight: keypadRowHeight,
              onDigit: onDigit,
              onDelete: onDelete,
            )
          else
            SizedBox(height: keypadRowHeight * 4),
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
    );

    return Focus(
      autofocus: true,
      onKeyEvent: (node, event) {
        if (event is! KeyDownEvent || busy) return KeyEventResult.ignored;

        final character = event.character;
        if (character != null && RegExp(r'^\d$').hasMatch(character)) {
          onDigit(character);
          return KeyEventResult.handled;
        }
        if (event.logicalKey == LogicalKeyboardKey.backspace ||
            event.logicalKey == LogicalKeyboardKey.delete) {
          onDelete();
          return KeyEventResult.handled;
        }

        return KeyEventResult.ignored;
      },
      child: Align(
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: useColumns ? 760 : 380),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(8, 8, 8, 16),
            child: useColumns
                ? Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Expanded(child: status),
                      const SizedBox(width: 48),
                      Expanded(child: controls),
                    ],
                  )
                : Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      status,
                      controls,
                    ],
                  ),
          ),
        ),
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
    required this.rowHeight,
    required this.onDigit,
    required this.onDelete,
  });

  final bool enabled;
  final double rowHeight;
  final ValueChanged<String> onDigit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: Column(
        children: [
          _PinKeypadRow(
            values: const ['1', '2', '3'],
            enabled: enabled,
            height: rowHeight,
            onDigit: onDigit,
          ),
          _PinKeypadRow(
            values: const ['4', '5', '6'],
            enabled: enabled,
            height: rowHeight,
            onDigit: onDigit,
          ),
          _PinKeypadRow(
            values: const ['7', '8', '9'],
            enabled: enabled,
            height: rowHeight,
            onDigit: onDigit,
          ),
          SizedBox(
            height: rowHeight,
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
    required this.height,
    required this.onDigit,
  });

  final List<String> values;
  final bool enabled;
  final double height;
  final ValueChanged<String> onDigit;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
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
