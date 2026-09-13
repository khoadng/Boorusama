// Package imports:
import 'package:flutter/gestures.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:foundation/foundation.dart';
import 'package:i18n/i18n.dart';
import 'package:kurumi/kurumi.dart';
import 'package:kurumi/material.dart';

// Project imports:
import '../../../../foundation/info/device_info.dart';
import '../../../../foundation/platform.dart';
import '../../../configs/config/providers.dart';
import '../../../configs/config/widgets.dart';
import '../../../configs/create/routes.dart';
import '../../../configs/manage/providers.dart';
import '../../../downloads/configs/widgets.dart';
import '../../../downloads/downloader/providers.dart';
import '../../../downloads/downloader/types.dart';
import '../../../downloads/sidecar/widgets.dart';
import '../../widgets.dart';
import '../generated/settings_index.g.dart';
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
    final wifiDownloadConstraintSupported = ref.watch(
      wifiDownloadConstraintSupportedProvider,
    );

    return SettingsPageScaffold(
      title: Text(context.t.settings.download.title),
      children: [
        DownloadSettingsInteractionBlocker(
          child: SettingAnchor(
            id: SettingsIndex.downloads.folder.id,
            child: DownloadFolderSelectorSection(
              storagePath: settings.downloadPath,
              onPathChanged: (path) =>
                  notifer.updateSettings(settings.copyWith(downloadPath: path)),
              deviceInfo: ref.watch(deviceInfoProvider),
            ),
          ),
        ),
        const SizedBox(height: 12),
        SettingAnchor(
          id: SettingsIndex.downloads.quality.id,
          child: KurumiSettingsTile(
            title: Text(SettingsIndex.downloads.quality.title(context)),
            selectedOption: settings.downloadQuality,
            items: DownloadQuality.values,
            onChanged: (value) => notifer.updateSettings(
              settings.copyWith(downloadQuality: value),
            ),
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
        ),
        const SizedBox(height: 4),
        if (isAndroid() || isIOS()) ...[
          SettingAnchor(
            id: SettingsIndex.downloads.network.id,
            child: KurumiSettingsTile(
              title: Text(SettingsIndex.downloads.network.title(context)),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(context.t.settings.download.network.description),
                  if (!wifiDownloadConstraintSupported)
                    Text(
                      context.t.generic.requirement.android.version_or_later(
                        version: AndroidVersions.android9.release,
                      ),
                    ),
                ],
              ),
              selectedOption: settings.downloadNetworkPolicy,
              items: DownloadNetworkPolicy.values,
              onChanged: (value) => notifer.updateSettings(
                settings.copyWith(downloadNetworkPolicy: value),
              ),
              isOptionEnabled: (value) =>
                  value != DownloadNetworkPolicy.wifiOnly ||
                  wifiDownloadConstraintSupported,
              optionBuilder: (value) {
                final label = switch (value) {
                  DownloadNetworkPolicy.anyNetwork =>
                    context.t.settings.download.network.any_network,
                  DownloadNetworkPolicy.wifiOnly =>
                    context.t.settings.download.network.wifi_only,
                  DownloadNetworkPolicy.askOnMobileData =>
                    context.t.settings.download.network.ask_on_mobile_data,
                };

                if (value != DownloadNetworkPolicy.wifiOnly ||
                    wifiDownloadConstraintSupported) {
                  return Text(label);
                }

                return Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(label),
                    Text(
                      context.t.generic.requirement.android.version_or_later(
                        version: AndroidVersions.android9.release,
                      ),
                      style: Theme.of(context).textTheme.labelSmall,
                    ),
                  ],
                );
              },
            ),
          ),
          const SizedBox(height: 4),
        ],
        SettingAnchor(
          id: SettingsIndex.downloads.notifications.id,
          child: KurumiSwitchListTile(
            title: Text(
              SettingsIndex.downloads.notifications.title(context),
            ),
            value: settings.downloadNotificationsEnabled,
            onChanged: (value) async {
              await notifer.updateSettings(
                settings.copyWith(downloadNotificationsEnabled: value),
              );
            },
          ),
        ),
        const SizedBox(height: 4),
        SettingAnchor(
          id: SettingsIndex.downloads.skipExistingFiles.id,
          child: KurumiSwitchListTile(
            title: Text(
              SettingsIndex.downloads.skipExistingFiles.title(context),
            ),
            subtitle: Text(
              context.t.settings.download.skip_existing_files_explanation,
            ),
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
        SidecarFormatTile(
          value: settings.downloadSidecarFormat,
          onChanged: (value) => notifer.updateSettings(
            settings.copyWith(downloadSidecarFormat: value),
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
    final theme = Kurumi.themeOf(context);

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
