// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:easy_localization/easy_localization.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';

// Project imports:
import 'package:boorusama/boorus/danbooru/application/downloads/downloads.dart';
import 'package:boorusama/boorus/danbooru/ui/features/post_detail/simple_tag_search_view.dart';
import 'package:boorusama/core/core.dart';
import 'package:boorusama/core/infra/infra.dart';
import 'package:boorusama/core/ui/warning_container.dart';

class DownloadTagSelectionView extends StatefulWidget {
  const DownloadTagSelectionView({
    super.key,
  });

  @override
  State<DownloadTagSelectionView> createState() =>
      _DownloadTagSelectionViewState();
}

class _DownloadTagSelectionViewState extends State<DownloadTagSelectionView> {
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
              style: Theme.of(context)
                  .textTheme
                  .headline5!
                  .copyWith(fontWeight: FontWeight.w900),
            ).tr(),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(
              vertical: 18,
              horizontal: 16,
            ),
            child: BlocSelector<BulkImageDownloadBloc, BulkImageDownloadState,
                List<String>>(
              selector: (state) => state.selectedTags,
              builder: (context, selectedTags) {
                return Wrap(
                  spacing: 5,
                  children: [
                    ...selectedTags.map((e) => Chip(
                          label: Text(e.replaceAll('_', ' ')),
                          deleteIcon: Icon(
                            Icons.close,
                            size: 16,
                            color: Theme.of(context).colorScheme.error,
                          ),
                          onDeleted: () => context
                              .read<BulkImageDownloadBloc>()
                              .add(BulkImageDownloadTagRemoved(tag: e)),
                        )),
                    IconButton(
                      iconSize: 28,
                      splashRadius: 20,
                      onPressed: () {
                        final bloc = context.read<BulkImageDownloadBloc>();
                        showBarModalBottomSheet(
                          context: context,
                          duration: const Duration(milliseconds: 200),
                          builder: (context) => SimpleTagSearchView(
                            ensureValidTag: false,
                            onSelected: (tag) {
                              bloc.add(
                                BulkImageDownloadTagsAdded(
                                  tags: [tag.value],
                                ),
                              );
                            },
                          ),
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
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              'download.bulk_download_save_to_folder'.tr().toUpperCase(),
              style: Theme.of(context).textTheme.titleSmall!.copyWith(
                    color: Theme.of(context).hintColor,
                    fontWeight: FontWeight.w800,
                  ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 8,
            ),
            child: BlocSelector<BulkImageDownloadBloc, BulkImageDownloadState,
                DownloadOptions>(
              selector: (state) => state.options,
              builder: (context, options) {
                return Material(
                  child: Ink(
                    decoration: BoxDecoration(
                      color: Theme.of(context).cardColor,
                      border: Border.fromBorderSide(
                        BorderSide(color: Theme.of(context).hintColor),
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
                              style: Theme.of(context)
                                  .textTheme
                                  .subtitle1!
                                  .copyWith(color: Theme.of(context).hintColor),
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
            BlocBuilder<BulkImageDownloadBloc, BulkImageDownloadState>(
              builder: (context, state) {
                return state.shouldDisplayWarning(
                  hasScopeStorage: hasScopedStorage(context.read<DeviceInfo>()),
                )
                    ? _DownloadPathWarning(
                        releaseName: context.read<DeviceInfo>().release,
                        allowedFolders: state.allowedFolders,
                      )
                    : const SizedBox.shrink();
              },
            ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: BlocBuilder<BulkImageDownloadBloc, BulkImageDownloadState>(
              builder: (context, state) {
                return ElevatedButton(
                  onPressed: state.isValidToStartDownload(
                    hasScopeStorage:
                        hasScopedStorage(context.read<DeviceInfo>()),
                  )
                      ? () => context.read<BulkImageDownloadBloc>().add(
                            BulkImagesDownloadRequested(
                              tags: state.selectedTags,
                            ),
                          )
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
    final bloc = context.read<BulkImageDownloadBloc>();
    final selectedDirectory = await FilePicker.platform.getDirectoryPath();

    if (selectedDirectory != null) {
      bloc.add(
        BulkImageDownloadOptionsChanged(
          options: options.copyWith(
            storagePath: selectedDirectory,
          ),
        ),
      );
    }
  }
}

class _DownloadPathWarning extends StatelessWidget {
  const _DownloadPathWarning({
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
