// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:i18n/i18n.dart';
import 'package:kurumi/kurumi.dart';
import 'package:kurumi/material.dart';

// Project imports:
import '../../../tracking/providers.dart';
import '../providers/settings_notifier.dart';
import '../providers/settings_provider.dart';
import '../widgets/settings_page_scaffold.dart';
import 'app_lock_settings_page.dart';

class PrivacyPage extends ConsumerWidget {
  const PrivacyPage({
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);
    final notifier = ref.watch(settingsNotifierProvider.notifier);
    final tracker = ref.watch(trackerProvider);
    final appLock = context.t.settings.privacy.app_lock;

    return SettingsPageScaffold(
      title: Text(context.t.settings.privacy.privacy),
      children: [
        ListTile(
          contentPadding: EdgeInsets.zero,
          title: Text(appLock.title),
          subtitle: Text(appLockSummary(context, settings)),
          trailing: const Icon(Icons.chevron_right),
          onTap: () => SettingsPageNavigationScope.of(context).openContent(
            context,
            SettingEntry(
              id: 'app_lock',
              name: '/settings/privacy/app_lock',
              title: appLock.title,
              icon: Icons.lock,
              content: const AppLockSettingsPage(),
            ),
          ),
        ),
        KurumiSwitchListTile(
          title: Text(appLock.hide_app_preview),
          subtitle: Text(appLock.hide_app_preview_description),
          value: settings.hideAppPreviewWhenBackgrounded,
          onChanged: (value) {
            notifier.updateWith(
              (settings) => settings.copyWith(
                hideAppPreviewWhenBackgrounded: value,
              ),
            );
          },
        ),
        tracker.maybeWhen(
          data: (_) => KurumiSwitchListTile(
            title: Text(context.t.settings.privacy.enable_incognito_keyboard),
            subtitle: Text(
              context.t.settings.privacy.enable_incognito_keyboard_notice,
            ),
            value: settings.enableIncognitoModeForKeyboard,
            onChanged: (value) {
              notifier.updateSettings(
                settings.copyWith(
                  enableIncognitoModeForKeyboard: value,
                ),
              );
            },
          ),
          orElse: () => const SizedBox.shrink(),
        ),
      ],
    );
  }
}
