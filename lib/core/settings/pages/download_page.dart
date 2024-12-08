// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:foundation/foundation.dart';

// Project imports:
import 'package:boorusama/core/configs/redirect.dart';
import 'package:boorusama/core/downloads/l10n.dart';
import 'package:boorusama/core/downloads/widgets.dart';
import 'package:boorusama/core/settings.dart';
import 'package:boorusama/foundation/device_info.dart';
import 'package:boorusama/router.dart';
import '../data/settings_providers.dart';
import '../widgets/settings_page_scaffold.dart';
import '../widgets/settings_tile.dart';

class DownloadPage extends ConsumerStatefulWidget {
  const DownloadPage({
    super.key,
  });

  @override
  ConsumerState<DownloadPage> createState() => _DownloadPageState();
}

class _DownloadPageState extends ConsumerState<DownloadPage> {
  @override
  Widget build(BuildContext context) {
    final settings = ref.watch(settingsProvider);
    final notifer = ref.watch(settingsNotifierProvider.notifier);

    return SettingsPageScaffold(
      title: const Text('settings.download.title').tr(),
      children: [
        DownloadFolderSelectorSection(
          storagePath: settings.downloadPath,
          onPathChanged: (path) =>
              notifer.updateSettings(settings.copyWith(downloadPath: path)),
          deviceInfo: ref.watch(deviceInfoProvider),
        ),
        const SizedBox(height: 12),
        SettingsTile(
          title: const Text('settings.download.quality').tr(),
          selectedOption: settings.downloadQuality,
          items: DownloadQuality.values,
          onChanged: (value) =>
              notifer.updateSettings(settings.copyWith(downloadQuality: value)),
          optionBuilder: (value) =>
              Text('settings.download.qualities.${value.name}').tr(),
        ),
        const SizedBox(height: 4),
        ListTile(
          title: const Text(DownloadTranslations.skipDownloadIfExists).tr(),
          subtitle: const Text(
            DownloadTranslations.skipDownloadIfExistsExplanation,
          ).tr(),
          trailing: Switch(
            value: settings.skipDownloadIfExists,
            onChanged: (value) async {
              await notifer.updateSettings(settings.copyWith(
                downloadFileExistedBehavior: value
                    ? DownloadFileExistedBehavior.skip
                    : DownloadFileExistedBehavior.appDecide,
              ));
            },
          ),
        ),
        const BooruConfigMoreSettingsRedirectCard.download(),
      ],
    );
  }
}

Future<void> openDownloadSettingsPage(BuildContext context) {
  return context.push(
    Uri(
      path: '/settings',
      queryParameters: {
        'initial': 'download',
      },
    ).toString(),
  );
}
