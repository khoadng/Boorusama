// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:foundation/foundation.dart';
import 'package:material_symbols_icons/symbols.dart';

// Project imports:
import '../../../blacklists/providers.dart';
import '../../../configs/ref.dart';
import '../../../configs/search/search.dart';
import '../../../downloads/l10n.dart' as d;
import '../../../downloads/widgets/download_folder_selector_section.dart';
import '../../../foundation/toast.dart';
import '../../../info/device_info.dart';
import '../../../router.dart';
import '../../../search/search/routes.dart';
import '../../../settings/providers.dart';
import '../../../settings/settings.dart';
import '../../../settings/widgets.dart';
import '../../../theme.dart';
import '../../../utils/collection_utils.dart';
import '../providers/bulk_download_notifier.dart';
import '../providers/create_download_options_notifier.dart';
import '../routes/route_utils.dart';
import '../types/download_configs.dart';
import '../types/download_options.dart';
import '../types/l10n.dart';
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
    final colorScheme = Theme.of(context).colorScheme;
    final navigatorContext = navigatorKey.currentContext;

    void showSnackBar(BuildContext context, String message) {
      if (showStartNotification) {
        showSimpleSnackBar(
          context: context,
          content: Text(message),
          action: SnackBarAction(
            label: 'generic.view'.tr(),
            textColor: colorScheme.surface,
            onPressed: () {
              goToBulkDownloadManagerPage(context);
            },
          ),
        );
      }
    }

    final notifier = ref.watch(bulkDownloadProvider.notifier);
    final quality =
        ref.watch(settingsProvider.select((e) => e.downloadQuality));
    final initial = DownloadOptions.initial(
      quality: quality.name,
      tags: initialValue,
    );
    final options = ref.watch(createDownloadOptionsProvider(initial));
    final androidSdkInt = ref.watch(
      deviceInfoProvider
          .select((value) => value.androidDeviceInfo?.version.sdkInt),
    );
    final validOptions = options.valid(androidSdkInt: androidSdkInt);
    final navigator = Navigator.of(context);

    return CreateDownloadOptionsRawSheet(
      initial: initial,
      actions: Row(
        spacing: 16,
        children: [
          Expanded(
            flex: 3,
            child: ElevatedButton(
              style: FilledButton.styleFrom(
                disabledBackgroundColor: Colors.transparent,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                  side: BorderSide(
                    color: colorScheme.outline,
                  ),
                ),
              ),
              onPressed: validOptions
                  ? () {
                      notifier.queueDownloadLater(
                        options,
                        onOptionsError: (e) {
                          showErrorToast(context, e.message);
                        },
                      );

                      if (navigatorContext != null &&
                          navigatorContext.mounted) {
                        showSnackBar(navigatorContext, 'Created');
                      }

                      navigator.pop();
                    }
                  : null,
              child: const Text(
                DownloadTranslations.addToQueue,
              ).tr(),
            ),
          ),
          Expanded(
            flex: 5,
            child: FilledButton(
              style: FilledButton.styleFrom(
                foregroundColor: Theme.of(context).colorScheme.onPrimary,
                shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(Radius.circular(16)),
                ),
              ),
              onPressed: validOptions
                  ? () {
                      notifier.downloadFromOptions(
                        options,
                        downloadConfigs: DownloadConfigs(
                          onDownloadStart: () {
                            if (navigatorContext != null) {
                              showSnackBar(
                                navigatorContext,
                                'Download started',
                              );
                            }
                          },
                        ),
                        onOptionsError: (e) {
                          showErrorToast(context, e.message);
                        },
                      );

                      navigator.pop();
                    }
                  : null,
              child: const Text(
                DownloadTranslations.download,
              ).tr(),
            ),
          ),
        ],
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

    final theme = Theme.of(context);
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
          onSubmit: notifier.addTag,
          onRemove: notifier.removeTag,
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
              DownloadTranslations.saveToFolder.tr().toUpperCase(),
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
            hint: DownloadTranslations.selectFolder.tr(),
          ),
        ),
        if (widget.advancedToggle)
          Column(
            children: [
              SwitchListTile(
                title: const Text(
                  DownloadTranslations.showAdvancedOptions,
                ).tr(),
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
          SettingsCard(
            title: 'Other options',
            child: Column(
              children: [
                SwitchListTile(
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 4,
                  ),
                  title: const Text(
                    DownloadTranslations.enableNotifications,
                  ).tr(),
                  value: options.notifications,
                  onChanged: (value) {
                    notifier.setNotifications(value);
                  },
                ),
                SwitchListTile(
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 4,
                  ),
                  title: const Text(d.DownloadTranslations.skipDownloadIfExists)
                      .tr(),
                  value: options.skipIfExists,
                  onChanged: (value) {
                    notifier.setSkipIfExists(value);
                  },
                ),
                SettingsTile(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  title: const Text('settings.download.quality').tr(),
                  selectedOption:
                      options.quality ?? DownloadQuality.original.name,
                  items: DownloadQuality.values.map((e) => e.name).toList(),
                  onChanged: (value) {
                    notifier.setQuality(value);
                  },
                  optionBuilder: (value) =>
                      Text('settings.download.qualities.$value').tr(),
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
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    final extraTags = queryAsList(options.blacklistedTags);
    final config = ref.watchConfigAuth;

    return ref.watch(blacklistTagEntriesProvider(ref.watchConfigFilter)).when(
          data: (tags) => SettingsCard(
            title: 'Excluded tags',
            trailing: Tooltip(
              message: _buildTitle(tags),
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
                        'Select additional tags to exclude from this batch',
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
                            (e) => Chip(
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

  String _buildTitle(Set<BlacklistedTagEntry> tags) {
    if (tags.isEmpty) {
      return 'No blacklisted tags';
    }

    final grouped = tags.groupBy((e) => e.source);
    final sb = StringBuffer()
      ..write(
        'Default blacklisted tags from the following sources:\n',
      );

    for (final entry in grouped.entries) {
      sb.write(
        '• ${entry.value.length} tags from ${entry.key.displayString}\n',
      );
    }

    return sb.toString().trim();
  }
}

class SettingsCard extends StatelessWidget {
  const SettingsCard({
    required this.child,
    super.key,
    this.onTap,
    this.margin,
    this.padding,
    this.title,
    this.trailing,
  });

  final Widget child;
  final void Function()? onTap;
  final EdgeInsetsGeometry? margin;
  final EdgeInsetsGeometry? padding;
  final String? title;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;
    final title = this.title;

    return Container(
      margin: margin ??
          const EdgeInsets.only(
            left: 16,
            right: 16,
            top: 16,
          ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (title != null)
            Padding(
              padding: const EdgeInsets.only(
                bottom: 8,
              ),
              child: Row(
                children: [
                  Text(
                    title.toUpperCase(),
                    style: textTheme.titleSmall?.copyWith(
                      color: colorScheme.hintColor,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  if (trailing != null) ...[
                    trailing!,
                  ],
                ],
              ),
            ),
          Material(
            color: colorScheme.surfaceContainerHigh,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: InkWell(
              customBorder: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              onTap: onTap,
              child: Container(
                padding: padding ??
                    const EdgeInsets.symmetric(
                      horizontal: 8,
                    ),
                child: child,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
