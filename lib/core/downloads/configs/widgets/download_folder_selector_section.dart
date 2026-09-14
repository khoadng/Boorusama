// Flutter imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Package imports:
import 'package:i18n/i18n.dart';
import 'package:kurumi/kurumi.dart';
import 'package:kurumi/material.dart';
import 'package:material_symbols_icons/symbols.dart';

// Project imports:
import '../../../../foundation/html.dart';
import '../../../../foundation/info/device_info.dart';
import '../../../../foundation/picker.dart';
import '../../path/types.dart';

class DownloadFolderSelectorSection extends ConsumerStatefulWidget {
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
  ConsumerState<DownloadFolderSelectorSection> createState() =>
      _DownloadFolderSelectorSectionState();
}

class _DownloadFolderSelectorSectionState
    extends ConsumerState<DownloadFolderSelectorSection> {
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

  bool _shouldDisplayWarning() {
    return switch (PathInfo.from(storagePath)) {
      InvalidPath() => true,
      final AndroidPathInfo info => info.requiresPublicDirectory(
        widget.deviceInfo.androidDeviceInfo?.version.sdkInt,
      ),
      _ => false,
    };
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Kurumi.themeOf(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SizedBox(height: 16),
        widget.title ??
            Text(
              context.t.settings.download.path,
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
                                context.t.settings.download.select_a_folder,
                            overflow: TextOverflow.fade,
                            style: Kurumi.themeOf(context).textTheme.titleMedium
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
        if (_shouldDisplayWarning())
          DownloadPathWarning(
            padding: const EdgeInsets.only(
              top: 12,
              bottom: 4,
            ),
            releaseName:
                widget.deviceInfo.androidDeviceInfo?.version.release ??
                'Unknown',
            allowedFolders: AndroidPathInfo.allowedDownloadFolders,
          ),
      ],
    );
  }

  bool showPath() => storagePath != null && storagePath!.isNotEmpty;

  Future<void> _pickFolder() => pickDirectoryPathToastOnError(
    context: context,
    picker: ref.read(appFilePickerProvider),
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
    return KurumiWarningContainer(
      margin: padding,
      contentBuilder: (context) => AppHtml(
        data: context.t.download.folder_select_warning
            .replaceAll('{0}', allowedFolders.join(', '))
            .replaceAll('{1}', releaseName),
      ),
    );
  }
}
