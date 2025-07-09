// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:foundation/foundation.dart';
import 'package:material_symbols_icons/symbols.dart';

// Project imports:
import '../../../../foundation/html.dart';
import '../../../../foundation/info/device_info.dart';
import '../../../../foundation/picker.dart';
import '../../../../foundation/platform.dart';
import '../../../theme.dart';
import '../../../widgets/widgets.dart';
import '../../l10n.dart';
import '../../path/validator.dart';

class DownloadFolderSelectorSection extends StatefulWidget {
  const DownloadFolderSelectorSection({
    required this.storagePath,
    required this.deviceInfo,
    required this.onPathChanged,
    super.key,
    this.hint,
    this.title,
    this.backgroundColor,
  });

  final String? storagePath;
  final void Function(String path) onPathChanged;
  final DeviceInfo deviceInfo;

  final String? hint;
  final Widget? title;
  final Color? backgroundColor;

  @override
  State<DownloadFolderSelectorSection> createState() =>
      _DownloadFolderSelectorSectionState();
}

class _DownloadFolderSelectorSectionState
    extends State<DownloadFolderSelectorSection>
    with DownloadPathValidatorMixin {
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
    final colorScheme = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SizedBox(height: 16),
        widget.title ??
            Text(
              DownloadTranslations.downloadPath(context),
            ),
        const SizedBox(height: 4),
        Material(
          color: widget.backgroundColor ?? colorScheme.surfaceContainer,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: InkWell(
            customBorder: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            onTap: () => _pickFolder(),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: showPath()
                        ? Text(
                            storagePath!,
                            overflow: TextOverflow.fade,
                          )
                        : Text(
                            widget.hint ??
                                DownloadTranslations.downloadSelectFolder(
                                  context,
                                ),
                            overflow: TextOverflow.fade,
                            style: Theme.of(context).textTheme.titleMedium
                                ?.copyWith(
                                  color: colorScheme.hintColor,
                                ),
                          ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(right: 4),
                  child: !showPath()
                      ? IconButton(
                          onPressed: () => _pickFolder(),
                          icon: const Icon(Symbols.folder),
                        )
                      : IconButton(
                          onPressed: () => widget.onPathChanged(''),
                          icon: const Icon(Symbols.clear),
                        ),
                ),
              ],
            ),
          ),
        ),
        if (isAndroid())
          shouldDisplayWarning(
                hasScopeStorage:
                    hasScopedStorage(
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
    context: context,
    onPick: (path) => widget.onPathChanged(path),
  );
}

class DownloadPathWarning extends StatelessWidget {
  const DownloadPathWarning({
    required this.releaseName,
    required this.allowedFolders,
    super.key,
    this.padding,
  });

  final String releaseName;
  final List<String> allowedFolders;
  final EdgeInsetsGeometry? padding;

  @override
  Widget build(BuildContext context) {
    return WarningContainer(
      margin: padding,
      contentBuilder: (context) => AppHtml(
        data: DownloadTranslations.downloadSelectFolderWarning(context)
            .replaceAll('{0}', allowedFolders.join(', '))
            .replaceAll('{1}', releaseName),
      ),
    );
  }
}
