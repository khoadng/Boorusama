// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import 'package:boorusama/boorus/providers.dart';
import 'package:boorusama/core/feats/settings/settings.dart';
import 'package:boorusama/foundation/i18n.dart';
import 'package:boorusama/widgets/widgets.dart';

class PrivacyPage extends ConsumerWidget {
  const PrivacyPage({
    super.key,
    this.hasAppBar = true,
  });

  final bool hasAppBar;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);

    return ConditionalParentWidget(
      condition: hasAppBar,
      conditionalBuilder: (child) => Scaffold(
        appBar: AppBar(
          title: const Text('settings.privacy.privacy').tr(),
        ),
        body: child,
      ),
      child: SafeArea(
        child: Column(
          children: [
            ListTile(
              title: const Text('settings.privacy.send_error_data_notice').tr(),
              trailing: Switch(
                value:
                    settings.dataCollectingStatus == DataCollectingStatus.allow,
                onChanged: (value) {
                  ref.updateSettings(settings.copyWith(
                    dataCollectingStatus: value
                        ? DataCollectingStatus.allow
                        : DataCollectingStatus.prohibit,
                  ));
                },
              ),
            ),
            ListTile(
              title: const Text('Enable incognito mode for keyboard'),
              subtitle: const Text(
                'Whether to enable that the IME update personalized data such as typing history and user dictionary data. Only affects Android.',
              ),
              trailing: Switch(
                value: settings.enableIncognitoModeForKeyboard,
                onChanged: (value) {
                  ref.updateSettings(settings.copyWith(
                    enableIncognitoModeForKeyboard: value,
                  ));
                },
              ),
            ),
            ListTile(
              title: const Text('Enable biometric lock'),
              subtitle: const Text(
                'Only works on devices with biometrics support and has been set up.',
              ),
              trailing: Switch(
                value: settings.appLockType == AppLockType.biometrics,
                onChanged: (value) {
                  ref.updateSettings(
                    settings.copyWith(
                      appLockType:
                          value ? AppLockType.biometrics : AppLockType.none,
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
