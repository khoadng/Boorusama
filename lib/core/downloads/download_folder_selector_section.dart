// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:file_picker/file_picker.dart';
import 'package:material_symbols_icons/symbols.dart';

// Project imports:
import 'package:boorusama/core/downloads/downloads.dart';
import 'package:boorusama/core/feats/settings/settings.dart';
import 'package:boorusama/foundation/android.dart';
import 'package:boorusama/foundation/device_info_service.dart';
import 'package:boorusama/foundation/i18n.dart';
import 'package:boorusama/foundation/platform.dart';
import 'package:boorusama/foundation/theme/theme.dart';

class DownloadFolderSelectorSection extends StatefulWidget {
  const DownloadFolderSelectorSection({
    super.key,
    required this.storagePath,
    required this.settings,
    required this.deviceInfo,
    required this.onPathChanged,
  });

  final String? Function() storagePath;
  final void Function(String path) onPathChanged;
  final Settings settings;
  final DeviceInfo deviceInfo;

  @override
  State<DownloadFolderSelectorSection> createState() =>
      _DownloadFolderSelectorSectionState();
}

class _DownloadFolderSelectorSectionState
    extends State<DownloadFolderSelectorSection> with DownloadMixin {
  late Settings settings = widget.settings;

  @override
  void didUpdateWidget(covariant DownloadFolderSelectorSection oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.settings != widget.settings) {
      setState(() {
        settings = widget.settings;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
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
                        onPressed: () => widget.onPathChanged(''),
                        icon: const Icon(Symbols.clear),
                      ),
              ),
            ),
          ),
        ),
        if (isAndroid())
          shouldDisplayWarning(
            hasScopeStorage: hasScopedStorage(
                  widget.deviceInfo.androidDeviceInfo?.version.sdkInt,
                ) ??
                true,
          )
              ? DownloadPathWarning(
                  releaseName:
                      widget.deviceInfo.androidDeviceInfo?.version.release ??
                          'Unknown',
                  allowedFolders: allowedFolders,
                )
              : const SizedBox.shrink(),
        const SizedBox(height: 16),
      ],
    );
  }

  bool showPath() => storagePath != null && storagePath!.isNotEmpty;

  Future<void> _pickFolder(Settings settings) async {
    final selectedDirectory = await FilePicker.platform.getDirectoryPath();

    if (selectedDirectory != null) {
      widget.onPathChanged(selectedDirectory);
    }
  }

  @override
  String? get storagePath => widget.storagePath();
}
