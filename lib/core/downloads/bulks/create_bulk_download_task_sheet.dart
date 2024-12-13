// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:foundation/foundation.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';

// Project imports:
import '../../boorus/booru/booru.dart';
import '../../configs/ref.dart';
import '../../foundation/picker.dart';
import '../../foundation/platform.dart';
import '../../foundation/toast.dart';
import '../../info/device_info.dart';
import '../../router.dart';
import '../../search/history_providers.dart';
import '../../search/history_widgets.dart';
import '../../settings/settings.dart';
import '../../settings/widgets.dart';
import '../../theme.dart';
import '../downloader/download_utils.dart';
import '../l10n.dart';
import '../widgets/download_folder_selector_section.dart';
import 'bulk_download_task.dart';
import 'create_bulk_download_notifier.dart';
import 'providers.dart';

class CreateBulkDownloadTaskSheet extends ConsumerWidget {
  const CreateBulkDownloadTaskSheet({
    super.key,
    required this.title,
    required this.initialValue,
    required this.onSubmitted,
  });

  final List<String>? initialValue;
  final String title;
  final void Function(BuildContext context, bool isQueue) onSubmitted;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ProviderScope(
      overrides: [
        createBulkDownloadInitialProvider.overrideWithValue(initialValue),
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
    super.key,
    required this.title,
    required this.onSubmitted,
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

    return Material(
      color: Theme.of(context).colorScheme.surfaceContainer,
      child: Container(
        margin: EdgeInsets.only(
          bottom: MediaQuery.viewInsetsOf(context).bottom,
        ),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    widget.title,
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                ],
              ),
              const SizedBox(height: 8),
              const CreateBulkDownloadTagList(),
              const Divider(
                thickness: 1,
                endIndent: 16,
                indent: 16,
              ),
              const SizedBox(height: 16),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Text(
                  DownloadTranslations.bulkDownloadSaveToFolder
                      .tr()
                      .toUpperCase(),
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        color: Theme.of(context).colorScheme.hintColor,
                        fontWeight: FontWeight.w800,
                      ),
                ),
              ),
              _buildPathSelector(task),
              if (isAndroid())
                Builder(
                  builder: (context) {
                    return task.shouldDisplayWarning(
                      hasScopeStorage: hasScopedStorage(androidSdkInt) ?? true,
                    )
                        ? DownloadPathWarning(
                            releaseName: ref
                                    .read(deviceInfoProvider)
                                    .androidDeviceInfo
                                    ?.version
                                    .release ??
                                'Unknown',
                            allowedFolders: task.allowedFolders,
                          )
                        : const SizedBox.shrink();
                  },
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
                  value: task.options.notications,
                  onChanged: (value) {
                    notifier.setOptions(
                      task.options.copyWith(notications: value),
                    );
                  },
                ),
                SwitchListTile(
                  title: const Text(DownloadTranslations.skipDownloadIfExists)
                      .tr(),
                  value: task.options.skipIfExists,
                  onChanged: (value) {
                    notifier.setOptions(
                      task.options.copyWith(skipIfExists: value),
                    );
                  },
                ),
                SettingsTile(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  title: const Text('settings.download.quality').tr(),
                  selectedOption:
                      task.options.quality ?? DownloadQuality.original,
                  items: DownloadQuality.values,
                  onChanged: (value) {
                    notifier.setOptions(
                      task.options.copyWith(quality: () => value),
                    );
                  },
                  optionBuilder: (value) =>
                      Text('settings.download.qualities.${value.name}').tr(),
                ),
              ],
              Container(
                margin: const EdgeInsets.only(
                  top: 12,
                  bottom: 28,
                ),
                child: Row(
                  children: [
                    // FilledButton(
                    //   style: FilledButton.styleFrom(
                    //     foregroundColor: context.iconTheme.color,
                    //     backgroundColor:
                    //         Theme.of(context).colorScheme.surfaceContainerHighest,
                    //     shape: const RoundedRectangleBorder(
                    //       borderRadius: BorderRadius.all(Radius.circular(16)),
                    //     ),
                    //   ),
                    //   onPressed: task.valid(androidSdkInt: androidSdkInt)
                    //       ? () {
                    //           notifier.queue();
                    //           widget.onSubmitted(context, true);
                    //           Navigator.of(context).pop();
                    //         }
                    //       : null,
                    //   child: const Text(
                    //           DownloadTranslations.bulkDownloadAddToQueue)
                    //       .tr(),
                    // ),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: FilledButton(
                          style: FilledButton.styleFrom(
                            foregroundColor:
                                Theme.of(context).colorScheme.onPrimary,
                            shape: const RoundedRectangleBorder(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(16)),
                            ),
                          ),
                          onPressed: task.valid(androidSdkInt: androidSdkInt)
                              ? () {
                                  final success = notifier.start();
                                  if (success) {
                                    widget.onSubmitted(context, false);
                                    Navigator.of(context).pop();
                                  }
                                }
                              : null,
                          child: const Text(
                            DownloadTranslations.bulkDownloadDownload,
                          ).tr(),
                        ),
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

  Future<void> _pickFolder(
    BuildContext context,
  ) =>
      pickDirectoryPathToastOnError(
        context: context,
        onPick: (path) {
          ref.read(createBulkDownloadProvider.notifier).setPath(path);
        },
      );

  Widget _buildPathSelector(BulkDownloadTask task) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 8,
      ),
      child: Builder(
        builder: (context) {
          return Material(
            child: Ink(
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surfaceContainerHighest,
                border: Border.fromBorderSide(
                  BorderSide(color: Theme.of(context).colorScheme.hintColor),
                ),
                borderRadius: const BorderRadius.all(Radius.circular(4)),
              ),
              child: ListTile(
                visualDensity: VisualDensity.compact,
                minVerticalPadding: 0,
                onTap: () => _pickFolder(context),
                title: task.path.isNotEmpty
                    ? Text(
                        task.path,
                        overflow: TextOverflow.fade,
                      )
                    : Text(
                        DownloadTranslations.bulkDownloadSelectFolder.tr(),
                        overflow: TextOverflow.fade,
                        style: Theme.of(context)
                            .textTheme
                            .titleMedium!
                            .copyWith(
                              color: Theme.of(context).colorScheme.hintColor,
                            ),
                      ),
                trailing: IconButton(
                  onPressed: () => _pickFolder(context),
                  icon: const Icon(Symbols.folder),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

void goToNewBulkDownloadTaskPage(
  WidgetRef ref,
  BuildContext context, {
  required List<String>? initialValue,
}) {
  final config = ref.readConfigAuth;

  if (!config.booruType.canDownloadMultipleFiles) {
    showBulkDownloadUnsupportErrorToast(context);
    return;
  }

  showMaterialModalBottomSheet(
    context: context,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(
        top: Radius.circular(16),
      ),
    ),
    builder: (_) => CreateBulkDownloadTaskSheet(
      initialValue: initialValue,
      title: DownloadTranslations.bulkDownloadNewDownloadTitle.tr(),
      onSubmitted: (_, isQueue) {
        showSimpleSnackBar(
          context: context,
          content: Text(
            isQueue ? 'Added' : 'Download started',
          ),
          action: SnackBarAction(
            label: 'View',
            onPressed: () {
              context.pushNamed(kBulkdownload);
            },
          ),
        );
      },
    ),
  );
}

class CreateBulkDownloadTagList extends ConsumerStatefulWidget {
  const CreateBulkDownloadTagList({
    super.key,
  });

  @override
  ConsumerState<CreateBulkDownloadTagList> createState() =>
      _CreateBulkDownloadTagListState();
}

class _CreateBulkDownloadTagListState
    extends ConsumerState<CreateBulkDownloadTagList> {
  @override
  Widget build(BuildContext context) {
    final notifier = ref.watch(createBulkDownloadProvider.notifier);
    final tags =
        ref.watch(createBulkDownloadProvider.select((value) => value.tags));

    return Container(
      margin: const EdgeInsets.symmetric(
        horizontal: 12,
      ),
      child: Wrap(
        runAlignment: WrapAlignment.center,
        spacing: 5,
        runSpacing: isMobilePlatform() ? -4 : 8,
        children: [
          ...tags.map(
            (e) => Chip(
              backgroundColor:
                  Theme.of(context).colorScheme.surfaceContainerHighest,
              label: Text(e.replaceAll('_', ' ')),
              deleteIcon: Icon(
                Symbols.close,
                size: 16,
                color: Theme.of(context).colorScheme.error,
              ),
              onDeleted: () => notifier.removeTag(e),
            ),
          ),
          IconButton(
            iconSize: 28,
            splashRadius: 20,
            onPressed: () {
              goToQuickSearchPage(
                context,
                ref: ref,
                emptyBuilder: (controller) => ValueListenableBuilder(
                  valueListenable: controller,
                  builder: (_, value, __) => value.text.isEmpty
                      ? ref.watch(searchHistoryProvider).maybeWhen(
                            data: (data) => SearchHistorySection(
                              maxHistory: 20,
                              showTime: true,
                              histories: data.histories,
                              onHistoryTap: (history) {
                                Navigator.of(context).pop();
                                notifier.addFromSearchHistory(history);
                              },
                            ),
                            orElse: () => const SizedBox.shrink(),
                          )
                      : const SizedBox.shrink(),
                ),
                onSubmitted: (context, text, _) {
                  Navigator.of(context).pop();
                  notifier.addTag(text);
                },
                onSelected: (tag, _) {
                  notifier.addTag(tag);
                },
              );
            },
            icon: const Icon(Symbols.add),
          ),
        ],
      ),
    );
  }
}
