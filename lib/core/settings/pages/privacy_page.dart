// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:foundation/foundation.dart';

// Project imports:
import '../data/settings_providers.dart';
import '../types.dart';
import '../widgets/settings_page_scaffold.dart';

class PrivacyPage extends ConsumerWidget {
  const PrivacyPage({
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);
    final notifer = ref.watch(settingsNotifierProvider.notifier);

    return SettingsPageScaffold(
      title: const Text('settings.privacy.privacy').tr(),
      children: [
        ListTile(
          title: const Text('settings.privacy.send_error_data_notice').tr(),
          trailing: Switch(
            value: settings.dataCollectingStatus == DataCollectingStatus.allow,
            onChanged: (value) {
              notifer.updateSettings(
                settings.copyWith(
                  dataCollectingStatus: value
                      ? DataCollectingStatus.allow
                      : DataCollectingStatus.prohibit,
                ),
              );
            },
          ),
        ),
        ListTile(
          title: const Text('settings.privacy.enable_incognito_keyboard').tr(),
          subtitle: const Text(
            'settings.privacy.enable_incognito_keyboard_notice',
          ).tr(),
          trailing: Switch(
            value: settings.enableIncognitoModeForKeyboard,
            onChanged: (value) {
              notifer.updateSettings(
                settings.copyWith(
                  enableIncognitoModeForKeyboard: value,
                ),
              );
            },
          ),
        ),
        ListTile(
          title: const Text('settings.privacy.enable_biometric_lock').tr(),
          subtitle: const Text(
            'settings.privacy.enable_biometric_lock_notice',
          ).tr(),
          trailing: Switch(
            value: settings.appLockType == AppLockType.biometrics,
            onChanged: (value) {
              notifer.updateSettings(
                settings.copyWith(
                  appLockType:
                      value ? AppLockType.biometrics : AppLockType.none,
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
