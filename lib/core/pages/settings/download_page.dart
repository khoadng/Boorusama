// Flutter imports:
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

// Package imports:
import 'package:file_picker/file_picker.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_symbols_icons/symbols.dart';

// Project imports:
import 'package:boorusama/boorus/providers.dart';
import 'package:boorusama/core/downloads/downloads.dart';
import 'package:boorusama/core/feats/settings/settings.dart';
import 'package:boorusama/core/pages/settings/widgets/settings_tile.dart';
import 'package:boorusama/foundation/android.dart';
import 'package:boorusama/foundation/i18n.dart';
import 'package:boorusama/foundation/platform.dart';
import 'package:boorusama/foundation/theme/theme.dart';
import 'package:boorusama/widgets/widgets.dart';

class DownloadPage extends ConsumerStatefulWidget {
  const DownloadPage({
    super.key,
    this.hasAppBar = true,
  });

  final bool hasAppBar;

  @override
  ConsumerState<DownloadPage> createState() => _DownloadPageState();
}

class _DownloadPageState extends ConsumerState<DownloadPage>
    with DownloadMixin {
  @override
  Widget build(BuildContext context) {
    final settings = ref.watch(settingsProvider);

    return ConditionalParentWidget(
      condition: widget.hasAppBar,
      conditionalBuilder: (child) => Scaffold(
        appBar: AppBar(
          title: const Text('download.download').tr(),
        ),
        body: child,
      ),
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                'settings.download.path'.tr().toUpperCase(),
                style: context.textTheme.titleSmall?.copyWith(
                  color: context.theme.hintColor,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Material(
                child: Ink(
                  decoration: BoxDecoration(
                    color: context.colorScheme.surfaceVariant,
                    border: Border.fromBorderSide(
                      BorderSide(color: context.theme.hintColor),
                    ),
                    borderRadius: const BorderRadius.all(Radius.circular(4)),
                  ),
                  child: ListTile(
                    visualDensity: VisualDensity.compact,
                    minVerticalPadding: 0,
                    onTap: () => _pickFolder(settings),
                    title: showPath()
                        ? Text(
                            storagePath!,
                            overflow: TextOverflow.fade,
                          )
                        : Text(
                            'settings.download.select_a_folder'.tr(),
                            overflow: TextOverflow.fade,
                            style: context.textTheme.titleMedium!
                                .copyWith(color: context.theme.hintColor),
                          ),
                    trailing: !showPath()
                        ? IconButton(
                            onPressed: () => _pickFolder(settings),
                            icon: const Icon(Symbols.folder),
                          )
                        : IconButton(
                            onPressed: () => ref.updateSettings(
                              settings.copyWith(downloadPath: ''),
                            ),
                            icon: const Icon(Symbols.clear),
                          ),
                  ),
                ),
              ),
            ),
            if (isAndroid())
              shouldDisplayWarning(
                hasScopeStorage: hasScopedStorage(ref
                        .read(deviceInfoProvider)
                        .androidDeviceInfo
                        ?.version
                        .sdkInt) ??
                    true,
              )
                  ? DownloadPathWarning(
                      releaseName: ref
                              .read(deviceInfoProvider)
                              .androidDeviceInfo
                              ?.version
                              .release ??
                          'Unknown',
                      allowedFolders: allowedFolders,
                    )
                  : const SizedBox.shrink(),
            const SizedBox(height: 16),
            SettingsTile<DownloadQuality>(
              title: const Text('settings.download.quality').tr(),
              selectedOption: settings.downloadQuality,
              items: DownloadQuality.values,
              onChanged: (value) =>
                  ref.updateSettings(settings.copyWith(downloadQuality: value)),
              optionBuilder: (value) =>
                  Text('settings.download.qualities.${value.name}').tr(),
            ),
            const SizedBox(height: 16),
            ListTile(
              title: const Text('Ignore files that already downloaded'),
              subtitle: const Text(
                'This will prevent downloading files that already exist in the folder. This is useful when you don\'t want to download the same file multiple times.',
              ),
              trailing: Switch(
                value: settings.skipDownloadIfExists,
                onChanged: settings.useLegacyDownloader
                    ? null
                    : (value) async {
                        await ref.updateDownloadFileExistedBehavior(
                            settings, value);
                      },
              ),
            ),
            const SizedBox(height: 16),
            ListTile(
              title: const Text('Use legacy downloader'),
              subtitle: const Text(
                'This may be useful if you are experiencing issues with the new download manager. It will be removed in the future when the new download manager is stable.',
              ),
              trailing: Switch(
                value: settings.useLegacyDownloader,
                onChanged: (value) async {
                  await ref.updateDownloaderStatus(settings, value);
                  // Don't allow the user to enable the skipDownloadIfExists
                  if (value) {
                    WidgetsBinding.instance.addPostFrameCallback((_) {
                      ref.updateDownloadFileExistedBehavior(
                        ref.read(settingsProvider),
                        false,
                      );
                    });
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  bool showPath() => storagePath != null && storagePath!.isNotEmpty;

  Future<void> _pickFolder(Settings settings) async {
    final selectedDirectory = await FilePicker.platform.getDirectoryPath();

    if (selectedDirectory != null) {
      ref.updateSettings(settings.copyWith(downloadPath: selectedDirectory));
    }
  }

  @override
  String? get storagePath => ref.read(settingsProvider).downloadPath;
}

Future<void> openDownloadSettingsPage(BuildContext context) {
  return Navigator.of(context).push(
    CupertinoPageRoute(
      builder: (context) => const DownloadPage(),
    ),
  );
}
