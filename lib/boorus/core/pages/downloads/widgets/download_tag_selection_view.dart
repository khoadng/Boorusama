// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:file_picker/file_picker.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import 'package:boorusama/boorus/core/feats/downloads/downloads.dart';
import 'package:boorusama/boorus/core/provider.dart';
import 'package:boorusama/boorus/core/router.dart';
import 'package:boorusama/dart.dart';
import 'package:boorusama/flutter.dart';
import 'package:boorusama/foundation/android.dart';
import 'package:boorusama/foundation/i18n.dart';
import 'package:boorusama/foundation/platform.dart';
import 'package:boorusama/foundation/theme/theme.dart';
import 'package:boorusama/widgets/warning_container.dart';

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
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 8,
            ),
            child: Text(
              'download.bulk_download_tag_confirmation',
              textAlign: TextAlign.center,
              style: context.textTheme.headlineSmall!
                  .copyWith(fontWeight: FontWeight.w900),
            ).tr(),
          ),
          Padding(
            padding: const EdgeInsets.only(
              top: 18,
              left: 16,
              right: 16,
            ),
            child: Builder(
              builder: (context) {
                final selectedTags =
                    ref.watch(bulkDownloadSelectedTagsProvider);

                return Wrap(
                  spacing: 5,
                  children: [
                    ...selectedTags.map((e) => Chip(
                          label: Text(e.replaceUnderscoreWithSpace()),
                          deleteIcon: Icon(
                            Icons.close,
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
                      icon: const Icon(Icons.add),
                    ),
                  ],
                );
              },
            ),
          ),
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
              style: context.theme.textTheme.titleSmall!.copyWith(
                color: context.theme.hintColor,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          Padding(
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
                      color: context.theme.cardColor,
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
                        icon: const Icon(Icons.folder),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
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
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Builder(
              builder: (context) {
                final allowDownloadd =
                    ref.watch(isValidToStartDownloadProvider);
                final selectedTags =
                    ref.watch(bulkDownloadSelectedTagsProvider);

                return ElevatedButton(
                  onPressed: allowDownloadd
                      ? () => ref
                          .read(bulkDownloaderManagerProvider.notifier)
                          .download(tags: selectedTags.join(' '))
                      : null,
                  child: const Text('download.download').tr(),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _pickFolder(
    BuildContext context,
    DownloadOptions options,
  ) async {
    final selectedDirectory = await FilePicker.platform.getDirectoryPath();

    if (selectedDirectory != null) {
      final state = ref.read(bulkDownloadOptionsProvider);
      ref.read(bulkDownloadOptionsProvider.notifier).state = state.copyWith(
        storagePath: selectedDirectory,
      );
    }
  }
}

class DownloadPathWarning extends StatelessWidget {
  const DownloadPathWarning({
    super.key,
    required this.releaseName,
    required this.allowedFolders,
  });

  final String releaseName;
  final List<String> allowedFolders;

  @override
  Widget build(BuildContext context) {
    return WarningContainer(
      contentBuilder: (context) => Html(
        data: 'download.bulk_download_folder_select_warning'
            .tr()
            .replaceAll('{0}', allowedFolders.join(', '))
            .replaceAll('{1}', releaseName),
      ),
    );
  }
}
