// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:foundation/foundation.dart';
import 'package:material_symbols_icons/symbols.dart';

// Project imports:
import '../../../foundation/picker.dart';
import '../../../foundation/platform.dart';
import '../../../foundation/toast.dart';
import '../../../info/device_info.dart';
import '../../../search/histories/providers.dart';
import '../../../search/histories/widgets.dart';
import '../../../search/search/routes.dart';
import '../../../settings/settings.dart';
import '../../../settings/widgets.dart';
import '../../../theme.dart';
import '../../l10n.dart';
import '../../widgets/download_folder_selector_section.dart';
import '../providers/create_bulk_download_notifier.dart';
import '../providers/providers.dart';
import '../types/bulk_download_error.dart';
import '../types/download_options.dart';

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

  Widget _buildPathSelector(DownloadOptions options) {
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
                title: options.path.isNotEmpty
                    ? Text(
                        options.path,
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
