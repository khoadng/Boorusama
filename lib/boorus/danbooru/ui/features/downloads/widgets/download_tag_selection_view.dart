// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';

// Project imports:
import 'package:boorusama/boorus/danbooru/application/downloads/downloads.dart';
import 'package:boorusama/boorus/danbooru/ui/features/post_detail/simple_tag_search_view.dart';
import 'package:boorusama/common/constant.dart';

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
                return TextFormField(
                  controller: textEditingController,
                  autovalidateMode: AutovalidateMode.onUserInteraction,
                  validator: (value) => !options.hasValidFolderName()
                      ? 'download.bulk_download_invalid_folder_name_error'
                              .tr() +
                          illegalCharactersForFolderName.join()
                      : null,
                  decoration: InputDecoration(
                    filled: true,
                    hintText: options.defaultNameIfEmpty,
                    fillColor: Theme.of(context).cardColor,
                    border: const OutlineInputBorder(
                      borderSide: BorderSide(width: 2),
                    ),
                    contentPadding: const EdgeInsets.all(12),
                  ),
                  onChanged: (value) {
                    context.read<BulkImageDownloadBloc>().add(
                          BulkImageDownloadOptionsChanged(
                            options: options.copyWith(folderName: value),
                          ),
                        );
                  },
                );
              },
            ),
          ),
          BlocSelector<BulkImageDownloadBloc, BulkImageDownloadState,
              DownloadOptions>(
            selector: (state) => state.options,
            builder: (context, options) {
              return ListTile(
                title:
                    const Text('download.bulk_download_merge_images_to_folder')
                        .tr(),
                subtitle: const Text(
                  'download.bulk_download_merge_explanation',
                ).tr(),
                trailing: Switch.adaptive(
                  activeColor: Theme.of(context).colorScheme.primary,
                  value: !options.createNewFolderIfExists,
                  onChanged: (value) {
                    context.read<BulkImageDownloadBloc>().add(
                          BulkImageDownloadOptionsChanged(
                            options: options.copyWith(
                              createNewFolderIfExists: !value,
                            ),
                          ),
                        );
                  },
                ),
              );
            },
          ),
          BlocSelector<BulkImageDownloadBloc, BulkImageDownloadState,
              DownloadOptions>(
            selector: (state) => state.options,
            builder: (context, options) {
              return ListTile(
                title: const Text(
                  'download.bulk_download_only_download_new_images',
                ).tr(),
                trailing: Switch.adaptive(
                  activeColor: Theme.of(context).colorScheme.primary,
                  value: options.onlyDownloadNewFile,
                  onChanged: (value) {
                    context.read<BulkImageDownloadBloc>().add(
                          BulkImageDownloadOptionsChanged(
                            options: options.copyWith(
                              onlyDownloadNewFile: value,
                            ),
                          ),
                        );
                  },
                ),
              );
            },
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: BlocBuilder<BulkImageDownloadBloc, BulkImageDownloadState>(
              builder: (context, state) {
                return ElevatedButton(
                  onPressed: state.isValidToStartDownload()
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
}
