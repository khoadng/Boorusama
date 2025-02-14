// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:foundation/foundation.dart';

// Project imports:
import '../../../foundation/toast.dart';
import '../../../info/device_info.dart';
import '../../../settings/settings.dart';
import '../../../settings/widgets.dart';
import '../../../theme.dart';
import '../../../widgets/drag_line.dart';
import '../../l10n.dart';
import '../../widgets/download_folder_selector_section.dart';
import '../providers/create_bulk_download_notifier.dart';
import '../providers/providers.dart';
import '../types/bulk_download_error.dart';
import '../types/download_options.dart';
import '../widgets/bulk_download_tag_list.dart';

class CreateBulkDownloadTaskSheet extends ConsumerWidget {
  const CreateBulkDownloadTaskSheet({
    required this.title,
    required this.initialValue,
    required this.onSubmitted,
    super.key,
  });

  final List<String>? initialValue;
  final String title;
  final void Function(BuildContext context, bool isQueue) onSubmitted;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ProviderScope(
      overrides: [
        createBulkDownloadInitialTagsProvider.overrideWithValue(initialValue),
      ],
      child: CreateBulkDownloadTaskSheetInternal(
        title: title,
        onSubmitted: onSubmitted,
      ),
    );
  }
}

class CreateBulkDownloadTaskSheetInternal extends ConsumerStatefulWidget {
  const CreateBulkDownloadTaskSheetInternal({
    required this.title,
    required this.onSubmitted,
    super.key,
  });

  final String title;
  final void Function(BuildContext context, bool isQueue) onSubmitted;

  @override
  ConsumerState<CreateBulkDownloadTaskSheetInternal> createState() =>
      _CreateBulkDownloadTaskSheetState();
}

class _CreateBulkDownloadTaskSheetState
    extends ConsumerState<CreateBulkDownloadTaskSheetInternal> {
  var advancedOptions = false;

  @override
  Widget build(BuildContext context) {
    final notifier = ref.watch(createBulkDownloadProvider.notifier);
    final task = ref.watch(createBulkDownloadProvider);
    final androidSdkInt = ref.watch(
      deviceInfoProvider
          .select((value) => value.androidDeviceInfo?.version.sdkInt),
    );
    final validTask = task.valid(androidSdkInt: androidSdkInt);
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainer,
        borderRadius: const BorderRadius.vertical(
          top: Radius.circular(16),
        ),
      ),
      child: SafeArea(
        top: false,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    DragLine(),
                  ],
                ),
              ),
              BulkDownloadTagList(
                tags: task.tags,
                onSubmit: notifier.addTag,
                onRemove: notifier.removeTag,
                onHistoryTap: notifier.addFromSearchHistory,
              ),
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                ),
                child: DownloadFolderSelectorSection(
                  title: Text(
                    DownloadTranslations.bulkDownloadSaveToFolder
                        .tr()
                        .toUpperCase(),
                    style: textTheme.titleSmall?.copyWith(
                      color: colorScheme.hintColor,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  backgroundColor: colorScheme.surfaceContainerHigh,
                  storagePath: task.path,
                  deviceInfo: ref.watch(deviceInfoProvider),
                  onPathChanged: (path) {
                    ref.read(createBulkDownloadProvider.notifier).setPath(path);
                  },
                  hint: DownloadTranslations.bulkDownloadSelectFolder.tr(),
                ),
              ),
              SwitchListTile(
                title: const Text(
                  DownloadTranslations.bulkdDownloadShowAdvancedOptions,
                ).tr(),
                value: advancedOptions,
                onChanged: (value) {
                  setState(() {
                    advancedOptions = value;
                  });
                },
              ),
              if (advancedOptions) ...[
                SwitchListTile(
                  title: const Text(
                    DownloadTranslations.bulkDownloadEnableNotifications,
                  ).tr(),
                  value: task.notifications,
                  onChanged: (value) {
                    notifier.setNotifications(value);
                  },
                ),
                SwitchListTile(
                  title: const Text(DownloadTranslations.skipDownloadIfExists)
                      .tr(),
                  value: task.skipIfExists,
                  onChanged: (value) {
                    notifier.setSkipIfExists(value);
                  },
                ),
                SettingsTile(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  title: const Text('settings.download.quality').tr(),
                  selectedOption: task.quality ?? DownloadQuality.original.name,
                  items: DownloadQuality.values.map((e) => e.name).toList(),
                  onChanged: (value) {
                    notifier.setQuality(value);
                  },
                  optionBuilder: (value) =>
                      Text('settings.download.qualities.$value').tr(),
                ),
              ],
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                ),
                child: Row(
                  spacing: 16,
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        style: FilledButton.styleFrom(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                            side: validTask
                                ? BorderSide(
                                    color: colorScheme.outline,
                                  )
                                : BorderSide.none,
                          ),
                        ),
                        onPressed: validTask
                            ? () {
                                notifier.startLater();
                                widget.onSubmitted(context, true);
                                Navigator.of(context).pop();
                              }
                            : null,
                        child: const Text(
                          DownloadTranslations.bulkDownloadAddToQueue,
                        ).tr(),
                      ),
                    ),
                    Expanded(
                      child: FilledButton(
                        style: FilledButton.styleFrom(
                          foregroundColor:
                              Theme.of(context).colorScheme.onPrimary,
                          shape: const RoundedRectangleBorder(
                            borderRadius: BorderRadius.all(Radius.circular(16)),
                          ),
                        ),
                        onPressed: validTask
                            ? () {
                                try {
                                  notifier.start();
                                  widget.onSubmitted(context, false);
                                  Navigator.of(context).pop();
                                } on BulkDownloadOptionsError catch (e) {
                                  showErrorToast(context, e.message);
                                }
                              }
                            : null,
                        child: const Text(
                          DownloadTranslations.bulkDownloadDownload,
                        ).tr(),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
