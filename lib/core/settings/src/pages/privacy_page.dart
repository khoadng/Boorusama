// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:i18n/i18n.dart';

// Project imports:
import '../../../tracking/providers.dart';
import '../../../widgets/widgets.dart';
import '../providers/settings_notifier.dart';
import '../providers/settings_provider.dart';
import '../types/types.dart';
import '../widgets/settings_page_scaffold.dart';

class PrivacyPage extends ConsumerWidget {
  const PrivacyPage({
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);
    final notifer = ref.watch(settingsNotifierProvider.notifier);
    final tracker = ref.watch(trackerProvider);

    return SettingsPageScaffold(
      title: Text(context.t.settings.privacy.privacy),
      children: [
        tracker.maybeWhen(
          data: (_) => BooruSwitchListTile(
            title: Text(context.t.settings.privacy.enable_incognito_keyboard),
            subtitle: Text(
              context.t.settings.privacy.enable_incognito_keyboard_notice,
            ),
            value: settings.enableIncognitoModeForKeyboard,
            onChanged: (value) {
              notifer.updateSettings(
                settings.copyWith(
                  enableIncognitoModeForKeyboard: value,
                ),
              );
            },
          ),
          orElse: () => const SizedBox.shrink(),
        ),
        BooruSwitchListTile(
          title: Text(context.t.settings.privacy.enable_biometric_lock),
          subtitle: Text(
            context.t.settings.privacy.enable_biometric_lock_notice,
          ),
          value: settings.appLockType == AppLockType.biometrics,
          onChanged: (value) {
            notifer.updateSettings(
              settings.copyWith(
                appLockType: value ? AppLockType.biometrics : AppLockType.none,
              ),
            );
          },
        ),
      ],
    );
  }
}
