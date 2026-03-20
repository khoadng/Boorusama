// Dart imports:
import 'dart:async';

// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:i18n/i18n.dart';

// Project imports:
import '../../../../foundation/keyboard/keyboard.dart';
import '../../../widgets/settings_card.dart';
import '../providers/settings_notifier.dart';
import '../widgets/key_capture_overlay.dart';
import '../widgets/settings_page_scaffold.dart';
import '../widgets/shortcut_binding_tile.dart';

class KeyboardShortcutsPage extends ConsumerWidget {
  const KeyboardShortcutsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final registry = ref.watch(shortcutRegistryProvider);
    final config = ref.watch(shortcutBindingConfigProvider);
    final hasCustomBindings = ref.watch(
      settingsNotifierProvider.select((s) => s.shortcutBindings != null),
    );
    final grouped = registry.grouped;

    return SettingsPageScaffold(
      title: Text(context.t.settings.keybinds.keybinds),
      padding: const EdgeInsets.symmetric(horizontal: 4),
      children: [
        for (final shortcutCtx in ShortcutContext.values)
          if (grouped[shortcutCtx] case final actions?)
            SettingsCard(
              title: shortcutCtx.label(context),
              child: Column(
                children: [
                  for (var i = 0; i < actions.length; i++) ...[
                    ShortcutBindingTile(
                      label: actions[i].labelBuilder(context),
                      binding: config.bindingFor(actions[i].id),
                      onTap: () => _onBindingTap(
                        context: context,
                        ref: ref,
                        actionId: actions[i].id,
                      ),
                    ),
                    if (i < actions.length - 1) const Divider(height: 1),
                  ],
                ],
              ),
            ),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
          child: Center(
            child: FilledButton(
              onPressed: hasCustomBindings
                  ? () => _confirmReset(context, ref)
                  : null,
              child: Text(context.t.settings.keybinds.reset_all),
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _onBindingTap({
    required BuildContext context,
    required WidgetRef ref,
    required String actionId,
  }) async {
    final newBinding = await showKeyCaptureDialog(context);
    if (newBinding == null) return;

    final registry = ref.read(shortcutRegistryProvider);
    final config = ref.read(shortcutBindingConfigProvider);

    final conflictAction = registry.findConflict(actionId, newBinding, config);
    var updated = config.withBinding(actionId, newBinding);
    if (conflictAction != null) {
      updated = updated.removeBinding(conflictAction);
    }

    unawaited(
      ref
          .read(settingsNotifierProvider.notifier)
          .updateWith((s) => s.copyWith(shortcutBindings: () => updated)),
    );
  }

  Future<void> _confirmReset(BuildContext context, WidgetRef ref) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(context.t.settings.keybinds.reset_all),
        content: Text(context.t.settings.keybinds.reset_confirm),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(context.t.generic.action.cancel),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(context.t.generic.action.reset),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    unawaited(
      ref
          .read(settingsNotifierProvider.notifier)
          .updateWith(
            (s) => s.copyWith(shortcutBindings: () => null),
          ),
    );
  }
}

extension on ShortcutContext {
  String label(BuildContext context) {
    final t = context.t.settings.keybinds.contexts;
    return switch (this) {
      ShortcutContext.global => t.global,
      ShortcutContext.postDetails => t.post_details,
      ShortcutContext.home => t.home,
    };
  }
}
