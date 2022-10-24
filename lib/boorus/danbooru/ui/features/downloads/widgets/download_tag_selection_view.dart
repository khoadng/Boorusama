// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';

// Project imports:
import 'package:boorusama/boorus/danbooru/application/downloads/downloads.dart';
import 'package:boorusama/boorus/danbooru/ui/features/post_detail/simple_tag_search_view.dart';

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
              'The below tags will be downloaded',
              textAlign: TextAlign.center,
              style: Theme.of(context)
                  .textTheme
                  .headline5!
                  .copyWith(fontWeight: FontWeight.w900),
            ),
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
              'Save images in folder'.toUpperCase(),
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
                return TextField(
                  controller: textEditingController,
                  decoration: InputDecoration(
                    filled: true,
                    hintText: options.defaultNameIfEmpty,
                    fillColor: Theme.of(context).cardColor,
                    enabledBorder: const OutlineInputBorder(
                      borderSide: BorderSide(width: 2),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(
                        color: Theme.of(context).colorScheme.secondary,
                        width: 2,
                      ),
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
                title: const Text('Merge with existing folder'),
                subtitle: const Text('Disable this will create a new folder'),
                trailing: Switch.adaptive(
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
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: BlocSelector<BulkImageDownloadBloc, BulkImageDownloadState,
                List<String>>(
              selector: (state) => state.selectedTags,
              builder: (context, selectedTags) {
                return ElevatedButton(
                  onPressed: () => context.read<BulkImageDownloadBloc>().add(
                        BulkImagesDownloadRequested(
                          tags: selectedTags,
                        ),
                      ),
                  child: const Text('Download'),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
