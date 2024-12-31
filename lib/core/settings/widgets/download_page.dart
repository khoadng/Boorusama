// Flutter imports:
import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import 'package:boorusama/boorus/providers.dart';
import 'package:boorusama/core/configs/configs.dart';
import 'package:boorusama/core/downloads/downloads.dart';
import 'package:boorusama/core/downloads/l10n.dart';
import 'package:boorusama/core/settings/settings.dart';
import 'package:boorusama/core/settings/widgets/widgets/settings_tile.dart';
import 'package:boorusama/router.dart';
import '../../configs/manage/manage.dart';
import 'widgets.dart';
import 'widgets/settings_page_scaffold.dart';

class DownloadPage extends ConsumerStatefulWidget {
  const DownloadPage({
    super.key,
    this.hasAppBar = true,
  });

  final bool hasAppBar;

  @override
  ConsumerState<DownloadPage> createState() => _DownloadPageState();
}

class _DownloadPageState extends ConsumerState<DownloadPage> {
  @override
  Widget build(BuildContext context) {
    final settings = ref.watch(settingsProvider);

    return SettingsPageScaffold(
      hasAppBar: widget.hasAppBar,
      title: const Text('settings.download.title').tr(),
      children: [
        DownloadSettingsInteractionBlocker(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: DownloadFolderSelectorSection(
              storagePath: settings.downloadPath,
              onPathChanged: (path) =>
                  ref.updateSettings(settings.copyWith(downloadPath: path)),
              deviceInfo: ref.watch(deviceInfoProvider),
            ),
          ),
        ),
        const SizedBox(height: 12),
        SettingsTile<DownloadQuality>(
          title: const Text('settings.download.quality').tr(),
          selectedOption: settings.downloadQuality,
          items: DownloadQuality.values,
          onChanged: (value) =>
              ref.updateSettings(settings.copyWith(downloadQuality: value)),
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
              await ref.updateDownloadFileExistedBehavior(settings, value);
            },
          ),
        ),
      ],
    );
  }
}

Future<void> openDownloadSettingsPage(BuildContext context) {
  return Navigator.of(context).push(
    CupertinoPageRoute(
      builder: (context) => const DownloadPage(),
    ),
  );
}

class DownloadSettingsInteractionBlocker extends ConsumerWidget {
  const DownloadSettingsInteractionBlocker({
    super.key,
    this.padding,
    this.onNavigateAway,
    required this.child,
  });

  final Widget child;
  final EdgeInsetsGeometry? padding;
  final void Function()? onNavigateAway;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final hasCustomDownload = ref.watch(currentBooruConfigProvider
        .select((value) => value.hasCustomDownloadLocation));
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
              text: "Download",
              recognizer: TapGestureRecognizer()
                ..onTap = () {
                  goToUpdateBooruConfigPage(
                    context,
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
