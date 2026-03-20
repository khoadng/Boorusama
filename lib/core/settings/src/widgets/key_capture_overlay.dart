// Flutter imports:
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// Package imports:
import 'package:i18n/i18n.dart';

// Project imports:
import '../../../../foundation/keyboard/keyboard.dart';

final _modifierKeyIds = {
  LogicalKeyboardKey.controlLeft.keyId,
  LogicalKeyboardKey.controlRight.keyId,
  LogicalKeyboardKey.shiftLeft.keyId,
  LogicalKeyboardKey.shiftRight.keyId,
  LogicalKeyboardKey.altLeft.keyId,
  LogicalKeyboardKey.altRight.keyId,
  LogicalKeyboardKey.metaLeft.keyId,
  LogicalKeyboardKey.metaRight.keyId,
};

Future<KeyBinding?> showKeyCaptureDialog(BuildContext context) {
  return showDialog<KeyBinding>(
    context: context,
    barrierDismissible: false,
    builder: (_) => const _KeyCaptureDialog(),
  );
}

class _KeyCaptureDialog extends StatefulWidget {
  const _KeyCaptureDialog();

  @override
  State<_KeyCaptureDialog> createState() => _KeyCaptureDialogState();
}

class _KeyCaptureDialogState extends State<_KeyCaptureDialog> {
  KeyBinding? _captured;

  KeyEventResult _handleKeyEvent(FocusNode node, KeyEvent event) {
    if (event is! KeyDownEvent) return KeyEventResult.handled;
    if (_modifierKeyIds.contains(event.logicalKey.keyId)) {
      return KeyEventResult.handled;
    }

    setState(() {
      _captured = KeyBinding.fromKeyEvent(event, HardwareKeyboard.instance);
    });
    return KeyEventResult.handled;
  }

  @override
  Widget build(BuildContext context) {
    final captured = _captured;

    return PopScope(
      canPop: false,
      child: AlertDialog(
        title: Text(context.t.settings.keybinds.record_shortcut),
        content: Focus(
          autofocus: true,
          onKeyEvent: _handleKeyEvent,
          child: captured == null
              ? Text(context.t.settings.keybinds.press_any_key)
              : Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    for (
                      var i = 0;
                      i < captured.displayParts().length;
                      i++
                    ) ...[
                      _KeyCapPreview(label: captured.displayParts()[i]),
                      if (i < captured.displayParts().length - 1)
                        const SizedBox(width: 4),
                    ],
                  ],
                ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(context.t.generic.action.cancel),
          ),
          if (captured != null)
            FilledButton(
              onPressed: () => Navigator.of(context).pop(captured),
              child: Text(context.t.generic.action.save),
            ),
        ],
      ),
    );
  }
}

class _KeyCapPreview extends StatelessWidget {
  const _KeyCapPreview({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      constraints: const BoxConstraints(minWidth: 36),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: colorScheme.outlineVariant),
      ),
      child: Text(
        label,
        textAlign: TextAlign.center,
        style: TextStyle(
          fontSize: 16,
          color: colorScheme.onSurface,
        ),
      ),
    );
  }
}
