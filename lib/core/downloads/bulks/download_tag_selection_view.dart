// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_symbols_icons/symbols.dart';

// Project imports:
import 'package:boorusama/boorus/providers.dart';
import 'package:boorusama/core/configs/configs.dart';
import 'package:boorusama/core/downloads/downloads.dart';
import 'package:boorusama/core/router.dart';
import 'package:boorusama/flutter.dart';
import 'package:boorusama/foundation/android.dart';
import 'package:boorusama/foundation/html.dart';
import 'package:boorusama/foundation/i18n.dart';
import 'package:boorusama/foundation/picker.dart';
import 'package:boorusama/foundation/platform.dart';
import 'package:boorusama/foundation/theme.dart';
import 'package:boorusama/string.dart';
import 'package:boorusama/widgets/widgets.dart';

class DownloadTagSelectionView extends ConsumerStatefulWidget {
  const DownloadTagSelectionView({
    super.key,
  });

  @override
  ConsumerState<DownloadTagSelectionView> createState() =>
      _DownloadTagSelectionViewState();
}

class _DownloadTagSelectionViewState
    extends ConsumerState<DownloadTagSelectionView> {
  final textEditingController = TextEditingController();

  @override
  void dispose() {
    textEditingController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final config = ref.watchConfig;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          splashRadius: 18,
          onPressed: () {
            ref.read(bulkDownloadSelectedTagsProvider.notifier).clear();
            ref.watch(bulkDownloadManagerStatusProvider.notifier).state =
                BulkDownloadManagerStatus.initial;
          },
          icon: const Icon(Symbols.arrow_back),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 12,
              ),
              child: Text(
                'download.bulk_download_tag_confirmation',
                textAlign: TextAlign.center,
                style: context.textTheme.headlineSmall!
                    .copyWith(fontWeight: FontWeight.w900),
              ).tr(),
            ),
            _buildTagList(),
            const Divider(
              thickness: 2,
              endIndent: 16,
              indent: 16,
            ),
            const SizedBox(height: 8),
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
            _buildPathSelector(),
            if (isAndroid())
              Builder(
                builder: (context) {
                  final options = ref.watch(bulkDownloadOptionsProvider);

                  return options.shouldDisplayWarning(
                    hasScopeStorage: hasScopedStorage(ref
                            .read(deviceInfoProvider)
                            .androidDeviceInfo
                            ?.version
                            .sdkInt) ??
                        true,
                  )
                      ? DownloadPathWarning(
                          releaseName: ref
                                  .read(deviceInfoProvider)
                                  .androidDeviceInfo
                                  ?.version
                                  .release ??
                              'Unknown',
                          allowedFolders: options.allowedFolders,
                        )
                      : const SizedBox.shrink();
                },
              ),
            // _buildIgnoreBlacklist(),
            _buildDownloadButton(config),
          ],
        ),
      ),
    );
  }

  // Widget _buildIgnoreBlacklist() {
  //   final options = ref.watch(bulkDownloadOptionsProvider);

  //   return ListTile(
  //     title: const Text("Ignore images you've blacklisted"),
  //     trailing: Switch(
  //       value: options.ignoreBlacklistedTags,
  //       onChanged: (value) {
  //         ref.read(bulkDownloadOptionsProvider.notifier).state =
  //             options.copyWith(ignoreBlacklistedTags: value);
  //       },
  //     ),
  //   );
  // }

  Widget _buildDownloadButton(BooruConfig config) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 8,
      ),
      child: Builder(
        builder: (context) {
          final allowDownloadd = ref.watch(isValidToStartDownloadProvider);
          final selectedTags = ref.watch(bulkDownloadSelectedTagsProvider);

          return FilledButton(
            onPressed: allowDownloadd
                ? () => ref
                    .read(bulkDownloaderManagerProvider(config).notifier)
                    .download(context: context, tags: selectedTags.join(' '))
                : null,
            child: const Text('download.download').tr(),
          );
        },
      ),
    );
  }

  Widget _buildPathSelector() {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 8,
      ),
      child: Builder(
        builder: (context) {
          final options = ref.watch(bulkDownloadOptionsProvider);

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
                onTap: () => _pickFolder(context, options),
                title: options.storagePath.isNotEmpty
                    ? Text(
                        options.storagePath,
                        overflow: TextOverflow.fade,
                      )
                    : Text(
                        'download.bulk_download_select_a_folder'.tr(),
                        overflow: TextOverflow.fade,
                        style: context.theme.textTheme.titleMedium!
                            .copyWith(color: context.theme.hintColor),
                      ),
                trailing: IconButton(
                  onPressed: () => _pickFolder(context, options),
                  icon: const Icon(Symbols.folder),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildTagList() {
    return Padding(
      padding: const EdgeInsets.only(
        top: 18,
        left: 16,
        right: 16,
      ),
      child: Builder(
        builder: (context) {
          final selectedTags = ref.watch(bulkDownloadSelectedTagsProvider);

          return Wrap(
            spacing: 5,
            children: [
              ...selectedTags.map((e) => Chip(
                    backgroundColor:
                        context.theme.colorScheme.surfaceContainerHighest,
                    label: Text(e.replaceUnderscoreWithSpace()),
                    deleteIcon: Icon(
                      Symbols.close,
                      size: 16,
                      color: context.theme.colorScheme.error,
                    ),
                    onDeleted: () => ref
                        .read(bulkDownloadSelectedTagsProvider.notifier)
                        .removeTag(e),
                  )),
              IconButton(
                iconSize: 28,
                splashRadius: 20,
                onPressed: () {
                  goToQuickSearchPage(
                    context,
                    ref: ref,
                    onSubmitted: (context, text) {
                      context.navigator.pop();
                      ref
                          .read(bulkDownloadSelectedTagsProvider.notifier)
                          .addTag(text);
                    },
                    onSelected: (tag) {
                      ref
                          .read(bulkDownloadSelectedTagsProvider.notifier)
                          .addTag(tag.value);
                    },
                  );
                },
                icon: const Icon(Symbols.add),
              ),
            ],
          );
        },
      ),
    );
  }

  Future<void> _pickFolder(
    BuildContext context,
    DownloadOptions options,
  ) =>
      pickDirectoryPathToastOnError(
        context: context,
        onPick: (path) {
          final state = ref.read(bulkDownloadOptionsProvider);
          ref.read(bulkDownloadOptionsProvider.notifier).state = state.copyWith(
            storagePath: path,
          );
        },
      );
}

class DownloadPathWarning extends StatelessWidget {
  const DownloadPathWarning({
    super.key,
    required this.releaseName,
    required this.allowedFolders,
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
        data:
            "The app can only download files inside public directories <b>({0})</b> for Android 11+. <br><br> Valid location examples:<br><b>[Internal]</b> /storage/emulated/0/Download <br><b>[SD card]</b> /storage/A1B2-C3D4/Download<br><br>Please choose another directory or create a new one if it doesn't exist. <br>This device's version is <b>{1}</b>."
                .replaceAll('{0}', allowedFolders.join(', '))
                .replaceAll('{1}', releaseName),
      ),
    );
  }
}
