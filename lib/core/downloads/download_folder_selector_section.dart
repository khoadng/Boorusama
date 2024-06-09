// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:material_symbols_icons/symbols.dart';

// Project imports:
import 'package:boorusama/core/downloads/downloads.dart';
import 'package:boorusama/foundation/android.dart';
import 'package:boorusama/foundation/device_info_service.dart';
import 'package:boorusama/foundation/i18n.dart';
import 'package:boorusama/foundation/picker.dart';
import 'package:boorusama/foundation/platform.dart';
import 'package:boorusama/foundation/theme/theme.dart';

class DownloadFolderSelectorSection extends StatefulWidget {
  const DownloadFolderSelectorSection({
    super.key,
    required this.storagePath,
    required this.deviceInfo,
    required this.onPathChanged,
    this.hint,
    this.title,
  });

  final String? storagePath;
  final void Function(String path) onPathChanged;
  final DeviceInfo deviceInfo;

  final String? hint;
  final String? title;

  @override
  State<DownloadFolderSelectorSection> createState() =>
      _DownloadFolderSelectorSectionState();
}

class _DownloadFolderSelectorSectionState
    extends State<DownloadFolderSelectorSection> with DownloadMixin {
  @override
  late String? storagePath = widget.storagePath;

  @override
  void didUpdateWidget(covariant DownloadFolderSelectorSection oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.storagePath != widget.storagePath) {
      setState(() {
        storagePath = widget.storagePath;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SizedBox(height: 16),
        Text(
          widget.title ?? 'settings.download.path'.tr(),
        ),
        const SizedBox(height: 4),
        Material(
          color: context.colorScheme.surfaceVariant,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(4),
            side: BorderSide(
              color: context.theme.hintColor,
            ),
          ),
          child: InkWell(
            customBorder: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(4),
            ),
            onTap: () => _pickFolder(),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(
                      left: 12,
                      top: 8,
                      bottom: 8,
                    ),
                    child: showPath()
                        ? Text(
                            storagePath!,
                            overflow: TextOverflow.fade,
                          )
                        : Text(
                            widget.hint ??
                                'settings.download.select_a_folder'.tr(),
                            overflow: TextOverflow.fade,
                            style: context.textTheme.titleMedium!
                                .copyWith(color: context.theme.hintColor),
                          ),
                  ),
                ),
                !showPath()
                    ? IconButton(
                        onPressed: () => _pickFolder(),
                        icon: const Icon(Symbols.folder),
                      )
                    : IconButton(
                        onPressed: () => widget.onPathChanged(''),
                        icon: const Icon(Symbols.clear),
                      ),
              ],
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
                  padding: const EdgeInsets.only(
                    top: 12,
                    bottom: 4,
                  ),
                  releaseName:
                      widget.deviceInfo.androidDeviceInfo?.version.release ??
                          'Unknown',
                  allowedFolders: allowedFolders,
                )
              : const SizedBox.shrink(),
      ],
    );
  }

  bool showPath() => storagePath != null && storagePath!.isNotEmpty;

  Future<void> _pickFolder() => pickDirectoryPathToastOnError(
        onPick: (path) => widget.onPathChanged(path),
      );
}
