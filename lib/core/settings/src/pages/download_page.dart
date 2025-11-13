// Flutter imports:
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:i18n/i18n.dart';

// Project imports:
import '../../../../foundation/info/device_info.dart';
import '../../../configs/config/providers.dart';
import '../../../configs/config/widgets.dart';
import '../../../configs/create/routes.dart';
import '../../../configs/manage/providers.dart';
import '../../../downloads/configs/widgets.dart';
import '../../../downloads/downloader/types.dart';
import '../../widgets.dart';
import '../providers/settings_notifier.dart';
import '../providers/settings_provider.dart';
import '../widgets/settings_page_scaffold.dart';

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
      title: Text(context.t.settings.download.title),
      children: [
        DownloadSettingsInteractionBlocker(
          child: DownloadFolderSelectorSection(
            storagePath: settings.downloadPath,
            onPathChanged: (path) =>
                notifer.updateSettings(settings.copyWith(downloadPath: path)),
            deviceInfo: ref.watch(deviceInfoProvider),
          ),
        ),
        const SizedBox(height: 12),
        SettingsTile(
          title: Text(context.t.settings.download.quality),
          selectedOption: settings.downloadQuality,
          items: DownloadQuality.values,
          onChanged: (value) =>
              notifer.updateSettings(settings.copyWith(downloadQuality: value)),
          optionBuilder: (value) => switch (value) {
            DownloadQuality.original => Text(
              context.t.settings.download.qualities.original,
            ),
            DownloadQuality.sample => Text(
              context.t.settings.download.qualities.sample,
            ),
            DownloadQuality.preview => Text(
              context.t.settings.download.qualities.preview,
            ),
          },
        ),
        const SizedBox(height: 4),
        ListTile(
          title: Text(context.t.settings.download.skip_existing_files),
          subtitle: Text(
            context.t.settings.download.skip_existing_files_explanation,
          ),
          trailing: Switch(
            value: settings.downloadFileExistedBehavior.skipDownloadIfExists,
            onChanged: (value) async {
              await notifer.updateSettings(
                settings.copyWith(
                  downloadFileExistedBehavior: value
                      ? DownloadFileExistedBehavior.skip
                      : DownloadFileExistedBehavior.appDecide,
                ),
              );
            },
          ),
        ),
        const BooruConfigMoreSettingsRedirectCard.download(),
      ],
    );
  }
}

class DownloadSettingsInteractionBlocker extends ConsumerWidget {
  const DownloadSettingsInteractionBlocker({
    required this.child,
    super.key,
    this.padding,
    this.onNavigateAway,
  });

  final Widget child;
  final EdgeInsetsGeometry? padding;
  final void Function()? onNavigateAway;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final hasCustomDownload = ref.watch(
      currentReadOnlyBooruConfigDownloadProvider.select(
        (value) => switch (value.location) {
          final location? when location.isNotEmpty => true,
          _ => false,
        },
      ),
    );
    final config = ref.watchConfig;
    final theme = Theme.of(context);

    return SettingsInteractionBlocker(
      padding: padding,
      block: hasCustomDownload,
      description: RichText(
        text: TextSpan(
          style: theme.textTheme.titleSmall?.copyWith(
            color: theme.hintColor,
            fontSize: 12,
            fontWeight: FontWeight.w400,
          ),
          children: [
            const TextSpan(
              text: 'This setting is overridden. Go to ',
            ),
            TextSpan(
              text: 'Download',
              recognizer: TapGestureRecognizer()
                ..onTap = () {
                  goToUpdateBooruConfigPage(
                    ref,
                    config: config,
                    initialTab: 'download',
                  );

                  onNavigateAway?.call();
                },
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.primary,
              ),
            ),
            const TextSpan(
              text: ' page instead.',
            ),
          ],
        ),
      ),
      child: child,
    );
  }
}
