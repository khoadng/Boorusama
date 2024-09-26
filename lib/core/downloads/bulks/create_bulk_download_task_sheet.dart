// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:oktoast/oktoast.dart';

// Project imports:
import 'package:boorusama/boorus/providers.dart';
import 'package:boorusama/core/downloads/downloads.dart';
import 'package:boorusama/core/search_histories/search_histories.dart';
import 'package:boorusama/flutter.dart';
import 'package:boorusama/foundation/android.dart';
import 'package:boorusama/foundation/animations.dart';
import 'package:boorusama/foundation/i18n.dart';
import 'package:boorusama/foundation/picker.dart';
import 'package:boorusama/foundation/platform.dart';
import 'package:boorusama/foundation/theme.dart';
import 'package:boorusama/router.dart';

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
      _EditSavedSearchSheetState();
}

class _EditSavedSearchSheetState
    extends ConsumerState<CreateBulkDownloadTaskSheetInternal> {
  var advancedOptions = false;

  @override
  Widget build(BuildContext context) {
    final notifier = ref.watch(createBulkDownloadProvider.notifier);
    final task = ref.watch(createBulkDownloadProvider);
    final androidSdkInt = ref.watch(deviceInfoProvider
        .select((value) => value.androidDeviceInfo?.version.sdkInt));

    return Material(
      color: context.colorScheme.secondaryContainer,
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
                    style: context.textTheme.titleLarge,
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
                  'download.bulk_download_save_to_folder'.tr().toUpperCase(),
                  style: context.theme.textTheme.titleSmall?.copyWith(
                    color: context.theme.hintColor,
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
              // show advanced options
              SwitchListTile(
                title: const Text('Show advanced options'),
                value: advancedOptions,
                onChanged: (value) {
                  setState(() {
                    advancedOptions = value;
                  });
                },
              ),
              if (advancedOptions) ...[
                SwitchListTile(
                  title: const Text('Enable notification'),
                  value: task.options.notications,
                  onChanged: (value) {
                    notifier.setOptions(
                      task.options.copyWith(notications: value),
                    );
                  },
                ),
                SwitchListTile(
                  title: const Text('Ignore files that already exist'),
                  value: task.options.skipIfExists,
                  onChanged: (value) {
                    notifier.setOptions(
                      task.options.copyWith(skipIfExists: value),
                    );
                  },
                ),
              ],
              Container(
                margin: const EdgeInsets.only(
                  top: 12,
                  bottom: 28,
                ),
                child: OverflowBar(
                  alignment: MainAxisAlignment.spaceAround,
                  children: [
                    FilledButton(
                      style: FilledButton.styleFrom(
                        foregroundColor: context.iconTheme.color,
                        backgroundColor:
                            context.colorScheme.surfaceContainerHighest,
                        shape: const RoundedRectangleBorder(
                          borderRadius: BorderRadius.all(Radius.circular(16)),
                        ),
                      ),
                      onPressed: task.valid(androidSdkInt: androidSdkInt)
                          ? () {
                              notifier.queue();
                              widget.onSubmitted(context, true);
                              context.navigator.pop();
                            }
                          : null,
                      child: const Text('Add to queue'),
                    ),
                    FilledButton(
                      style: FilledButton.styleFrom(
                        foregroundColor: context.colorScheme.onPrimary,
                        shape: const RoundedRectangleBorder(
                          borderRadius: BorderRadius.all(Radius.circular(16)),
                        ),
                      ),
                      onPressed: task.valid(androidSdkInt: androidSdkInt)
                          ? () {
                              notifier.start();
                              widget.onSubmitted(context, false);
                              context.navigator.pop();
                            }
                          : null,
                      child: const Text('Download'),
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
                color: context.colorScheme.surfaceContainerHighest,
                border: Border.fromBorderSide(
                  BorderSide(color: context.theme.hintColor),
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
                        'download.bulk_download_select_a_folder'.tr(),
                        overflow: TextOverflow.fade,
                        style: context.theme.textTheme.titleMedium!
                            .copyWith(color: context.theme.hintColor),
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
  showMaterialModalBottomSheet(
    context: context,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(
        top: Radius.circular(16),
      ),
    ),
    backgroundColor: context.colorScheme.secondaryContainer,
    builder: (_) => CreateBulkDownloadTaskSheet(
      initialValue: initialValue,
      title: 'New download',
      onSubmitted: (_, isQueue) {
        showToast(
          isQueue ? 'Added' : 'Download started',
          position: ToastPosition.bottom,
          textPadding: const EdgeInsets.all(8),
          duration: AppDurations.shortToast,
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
                  context.theme.colorScheme.surfaceContainerHighest,
              label: Text(e.replaceAll('_', ' ')),
              deleteIcon: Icon(
                Symbols.close,
                size: 16,
                color: context.theme.colorScheme.error,
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
                                context.navigator.pop();
                                notifier.addFromSearchHistory(history);
                              },
                            ),
                            orElse: () => const SizedBox.shrink(),
                          )
                      : const SizedBox.shrink(),
                ),
                onSubmitted: (context, text) {
                  context.navigator.pop();
                  notifier.addTag(text);
                },
                onSelected: (tag) {
                  notifier.addTag(tag.value);
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
