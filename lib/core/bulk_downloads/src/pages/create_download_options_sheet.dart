// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:i18n/i18n.dart';
import 'package:kurumi/kurumi.dart';
import 'package:kurumi/material.dart';
import 'package:material_symbols_icons/symbols.dart';

// Project imports:
import '../../../../foundation/info/device_info.dart';
import '../../../../foundation/utils/collection_utils.dart';
import '../../../blacklists/providers.dart';
import '../../../configs/config/providers.dart';
import '../../../configs/search/types.dart';
import '../../../downloads/configs/widgets/download_folder_selector_section.dart';
import '../../../downloads/downloader/types.dart' as d;
import '../../../downloads/sidecar/widgets.dart';
import '../../../navigation/app_navigation.dart';
import '../../../router.dart';
import '../../../search/search/routes.dart';
import '../../../search/selected_tags/types.dart' hide queryAsList;
import '../../../settings/providers.dart';
import '../providers/bulk_download_notifier.dart';
import '../providers/create_download_options_notifier.dart';
import '../routes/route_utils.dart';
import '../types/download_configs.dart';
import '../types/download_options.dart';
import '../types/download_options_validator.dart';
import '../widgets/bulk_download_tag_list.dart';

class CreateDownloadOptionsSheet extends ConsumerWidget {
  const CreateDownloadOptionsSheet({
    required this.initialValue,
    super.key,
    this.showStartNotification = true,
  });

  final List<String>? initialValue;
  final bool showStartNotification;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colorScheme = Kurumi.themeOf(context).colorScheme;
    final navigatorContext = ref
        .read(appNavigationProvider)
        .navigatorKey
        .currentContext;

    void showSnackBar(BuildContext context, String message) {
      if (showStartNotification) {
        Kurumi.showSimpleSnackBar(
          context: context,
          content: Text(message),
          action: SnackBarAction(
            label: context.t.generic.action.view,
            textColor: colorScheme.surface,
            onPressed: () {
              goToBulkDownloadManagerPage(ref);
            },
          ),
        );
      }
    }

    final notifier = ref.watch(bulkDownloadProvider.notifier);
    final quality = ref.watch(
      settingsProvider.select((e) => e.downloadQuality),
    );
    final initial = DownloadOptions.initial(
      quality: quality.name,
      tags: initialValue,
    );
    final options = ref.watch(createDownloadOptionsProvider(initial));
    final deviceInfo = ref.watch(deviceInfoProvider);
    final validOptions = validDownloadOptions(
      options: options,
      deviceInfo: deviceInfo,
    );
    final navigator = Navigator.of(context);

    final startedMessage = context.t.download.notification.started;

    return CreateDownloadOptionsRawSheet(
      initial: initial,
      actions: KurumiBottomSheetActionButtons(
        secondaryChild: Text(
          context.t.bulk_downloads.actions.add_to_queue,
        ),
        primaryChild: Text(context.t.download.download),
        onSecondaryPressed: validOptions
            ? () {
                notifier.queueDownloadLater(
                  options,
                  onOptionsError: (e) {
                    Kurumi.showErrorToast(context, e.message);
                  },
                );

                if (navigatorContext != null && navigatorContext.mounted) {
                  showSnackBar(navigatorContext, 'Created');
                }

                navigator.pop();
              }
            : null,
        onPrimaryPressed: validOptions
            ? () {
                notifier.downloadFromOptions(
                  options,
                  downloadConfigs: DownloadConfigs(
                    onDownloadStart: () {
                      if (navigatorContext != null) {
                        showSnackBar(
                          navigatorContext,
                          startedMessage,
                        );
                      }
                    },
                  ),
                  onOptionsError: (e) {
                    Kurumi.showErrorToast(context, e.message);
                  },
                );

                navigator.pop();
              }
            : null,
      ),
    );
  }
}

class CreateDownloadOptionsRawSheet extends ConsumerStatefulWidget {
  const CreateDownloadOptionsRawSheet({
    required this.initial,
    required this.actions,
    super.key,
    this.advancedToggle = true,
  });

  final DownloadOptions initial;
  final Widget actions;
  final bool advancedToggle;

  @override
  ConsumerState<CreateDownloadOptionsRawSheet> createState() =>
      _CreateDownloadOptionsRawSheetState();
}

class _CreateDownloadOptionsRawSheetState
    extends ConsumerState<CreateDownloadOptionsRawSheet> {
  var advancedOptions = false;

  @override
  Widget build(BuildContext context) {
    final params = widget.initial;
    final notifier = ref.watch(createDownloadOptionsProvider(params).notifier);
    final options = ref.watch(createDownloadOptionsProvider(params));

    final theme = Kurumi.themeOf(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    final showAll = switch (widget.advancedToggle) {
      true => advancedOptions,
      false => true,
    };

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        BulkDownloadTagList(
          tags: options.tags,
          onSubmit: (value) {
            notifier.addTag(TagSearchItem.fromString(value));
          },
          onRemove: (tag) {
            notifier.removeTag(TagSearchItem.fromString(tag));
          },
          onHistoryTap: notifier.addFromSearchHistory,
        ),
        if (!widget.advancedToggle)
          const Divider(
            height: 16,
          ),
        Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: 16,
          ),
          child: DownloadFolderSelectorSection(
            title: Text(
              context.t.bulk_downloads.options.save_to_folder.toUpperCase(),
              style: textTheme.titleSmall?.copyWith(
                color: colorScheme.hintColor,
                fontWeight: FontWeight.w800,
              ),
            ),
            backgroundColor: colorScheme.surfaceContainerHigh,
            storagePath: options.path,
            deviceInfo: ref.watch(deviceInfoProvider),
            onPathChanged: (path) {
              notifier.setPath(path);
            },
            hint: context.t.settings.download.select_a_folder,
          ),
        ),
        if (widget.advancedToggle)
          Column(
            children: [
              KurumiSwitchListTile(
                title: Text(
                  context.t.bulk_downloads.options.show_advanced_options,
                ),
                value: advancedOptions,
                onChanged: (value) {
                  setState(() {
                    advancedOptions = value;
                  });
                },
              ),
              if (showAll) const Divider(),
            ],
          ),
        if (showAll || advancedOptions) ...[
          _ExcludedTagsSection(
            options: options,
            notifier: notifier,
          ),
          KurumiSettingsCard(
            title: context.t.bulk_downloads.options.other_options,
            surface: KurumiSettingsCardSurface.high,
            child: Column(
              children: [
                KurumiSwitchListTile(
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 4,
                  ),
                  title: Text(
                    context.t.settings.download.skip_existing_files,
                  ),
                  value: options.skipIfExists,
                  onChanged: (value) {
                    notifier.setSkipIfExists(value);
                  },
                ),
                KurumiSettingsTile(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  title: Text(context.t.settings.download.quality),
                  selectedOption:
                      options.quality ?? d.DownloadQuality.original.name,
                  items: d.DownloadQuality.values.map((e) => e.name).toList(),
                  onChanged: (value) {
                    notifier.setQuality(value);
                  },
                  optionBuilder: (value) => Text(
                    switch (value) {
                      'original' =>
                        context.t.settings.download.qualities.original,
                      'sample' => context.t.settings.download.qualities.sample,
                      'preview' =>
                        context.t.settings.download.qualities.preview,
                      _ => value,
                    },
                  ),
                ),
                SidecarFormatTile(
                  allowDefault: true,
                  value: options.sidecarFormat,
                  onChanged: notifier.setSidecarFormat,
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
        ],
        Container(
          padding: const EdgeInsets.symmetric(
            horizontal: 12,
            vertical: 8,
          ),
          child: widget.actions,
        ),
      ],
    );
  }
}

class _ExcludedTagsSection extends ConsumerWidget {
  const _ExcludedTagsSection({
    required this.options,
    required this.notifier,
  });

  final DownloadOptions options;
  final CreateDownloadOptionsNotifier notifier;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colorScheme = Kurumi.themeOf(context).colorScheme;
    final textTheme = Kurumi.themeOf(context).textTheme;

    final extraTags = queryAsList(options.blacklistedTags);
    final config = ref.watchConfigAuth;

    return ref
        .watch(blacklistTagEntriesProvider(ref.watchConfigFilter))
        .when(
          data: (tags) => KurumiSettingsCard(
            title: context.t.bulk_downloads.options.excluded_tags,
            surface: KurumiSettingsCardSurface.high,
            trailing: Tooltip(
              message: _buildTitle(context, tags),
              triggerMode: TooltipTriggerMode.tap,
              showDuration: const Duration(seconds: 5),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: Icon(
                  Symbols.info,
                  size: 16,
                  color: colorScheme.hintColor,
                ),
              ),
            ),
            padding: const EdgeInsets.only(
              left: 12,
              right: 12,
              bottom: 8,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Padding(
                  padding: const EdgeInsets.only(
                    top: 8,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        context
                            .t
                            .bulk_downloads
                            .options
                            .excluded_tags_description,
                        style: textTheme.titleSmall?.copyWith(
                          color: colorScheme.hintColor,
                          fontSize: 13,
                        ),
                      ),
                      Wrap(
                        runAlignment: WrapAlignment.center,
                        spacing: 5,
                        runSpacing: 5,
                        children: [
                          ...extraTags.map(
                            (e) => KurumiMaterialChip(
                              backgroundColor: colorScheme.surfaceContainer,
                              label: Text(e.replaceAll('_', ' ')),
                              deleteIcon: Icon(
                                Symbols.close,
                                size: 16,
                                color: colorScheme.error,
                              ),
                              onDeleted: () {
                                notifier.removeBlacklistedTag(e);
                              },
                            ),
                          ),
                          IconButton(
                            iconSize: 28,
                            splashRadius: 20,
                            onPressed: () {
                              goToQuickSearchPage(
                                context,
                                ref: ref,
                                initialConfig: config,
                                onSubmitted: (context, text, _) {
                                  Navigator.of(context).pop();
                                  notifier.addBlacklistedTag(text);
                                },
                                onSelected: (tag, _) {
                                  notifier.addBlacklistedTag(tag);
                                },
                              );
                            },
                            icon: const Icon(Symbols.add),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          error: (error, _) => Text(
            error.toString(),
            style: TextStyle(
              color: colorScheme.error,
            ),
          ),
          loading: () => const CircularProgressIndicator(),
        );
  }

  String _buildTitle(BuildContext context, Set<BlacklistedTagEntry> tags) {
    if (tags.isEmpty) {
      return context.t.blacklist.manage.empty_blacklist;
    }

    final grouped = tags.groupBy((e) => e.source);
    final sb = StringBuffer()
      ..write(
        '${context.t.bulk_downloads.options.default_excluded_tags_from_source_list}\n',
      );

    for (final entry in grouped.entries) {
      sb.write(
        '${context.t.bulk_downloads.options.source_list(
          n: entry.value.length,
          count: entry.value.length,
          source: entry.key.displayString,
        )}\n',
      );
    }

    return sb.toString().trim();
  }
}
