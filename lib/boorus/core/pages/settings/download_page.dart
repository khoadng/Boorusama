// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:file_picker/file_picker.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import 'package:boorusama/boorus/core/feats/downloads/downloads.dart';
import 'package:boorusama/boorus/core/feats/settings/settings.dart';
import 'package:boorusama/boorus/core/pages/downloads/widgets/download_tag_selection_view.dart';
import 'package:boorusama/boorus/core/pages/settings/widgets/settings_tile.dart';
import 'package:boorusama/boorus/core/pages/widgets/conditional_parent_widget.dart';
import 'package:boorusama/boorus/core/provider.dart';
import 'package:boorusama/foundation/android.dart';
import 'package:boorusama/foundation/i18n.dart';
import 'package:boorusama/foundation/platform.dart';

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
                style: Theme.of(context).textTheme.titleSmall!.copyWith(
                      color: Theme.of(context).hintColor,
                      fontWeight: FontWeight.w800,
                    ),
              ),
            ),
            const SizedBox(height: 4),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Material(
                child: Ink(
                  decoration: BoxDecoration(
                    color: Theme.of(context).cardColor,
                    border: Border.fromBorderSide(
                      BorderSide(color: Theme.of(context).hintColor),
                    ),
                    borderRadius: const BorderRadius.all(Radius.circular(4)),
                  ),
                  child: ListTile(
                    visualDensity: VisualDensity.compact,
                    minVerticalPadding: 0,
                    onTap: () => _pickFolder(settings),
                    title: storagePath != null && storagePath!.isNotEmpty
                        ? Text(
                            storagePath!,
                            overflow: TextOverflow.fade,
                          )
                        : Text(
                            'settings.download.select_a_folder'.tr(),
                            overflow: TextOverflow.fade,
                            style: Theme.of(context)
                                .textTheme
                                .titleMedium!
                                .copyWith(color: Theme.of(context).hintColor),
                          ),
                    trailing: IconButton(
                      onPressed: () => _pickFolder(settings),
                      icon: const Icon(Icons.folder),
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
            SettingsTile<DownloadQuality>(
              title: const Text('settings.download.quality').tr(),
              selectedOption: settings.downloadQuality,
              items: DownloadQuality.values,
              onChanged: (value) =>
                  ref.updateSettings(settings.copyWith(downloadQuality: value)),
              optionBuilder: (value) =>
                  Text('settings.download.qualities.${value.name}').tr(),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _pickFolder(Settings settings) async {
    final selectedDirectory = await FilePicker.platform.getDirectoryPath();

    if (selectedDirectory != null) {
      ref.updateSettings(settings.copyWith(downloadPath: selectedDirectory));
    }
  }

  @override
  String? get storagePath => ref.read(settingsProvider).downloadPath;
}
