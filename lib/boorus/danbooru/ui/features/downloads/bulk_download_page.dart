// Flutter imports:
import 'package:boorusama/boorus/danbooru/ui/shared/info_container.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';

// Project imports:
import 'package:boorusama/boorus/danbooru/application/downloads/bulk_image_download_bloc.dart';
import 'package:boorusama/boorus/danbooru/ui/features/post_detail/simple_tag_search_view.dart';
import 'package:boorusama/boorus/danbooru/ui/shared/shared.dart';

class BulkDownloadPage extends StatefulWidget {
  const BulkDownloadPage({
    super.key,
  });

  @override
  State<BulkDownloadPage> createState() => _BulkDownloadPageState();
}

class _BulkDownloadPageState extends State<BulkDownloadPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Bulk downloads'),
      ),
      body: BlocBuilder<BulkImageDownloadBloc, BulkImageDownloadState>(
        builder: (context, state) {
          switch (state.status) {
            case BulkImageDownloadStatus.initial:
              return Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Padding(
                    padding:
                        const EdgeInsets.symmetric(vertical: 20, horizontal: 8),
                    child: SearchBar(
                      enabled: false,
                      hintText: 'Add tag',
                      onTap: () {
                        showBarModalBottomSheet(
                          context: context,
                          builder: (context) => SimpleTagSearchView(
                            ensureValidTag: false,
                            onSelected: (tag) {
                              context.read<BulkImageDownloadBloc>().add(
                                    BulkImageDownloadTagsAdded(
                                      tags: [tag.value],
                                    ),
                                  );
                            },
                          ),
                        );
                      },
                    ),
                  ),
                  Center(
                    child: Text(
                      'No tags selected',
                      style: Theme.of(context)
                          .textTheme
                          .headline5!
                          .copyWith(fontWeight: FontWeight.w900),
                    ),
                  ),
                ],
              );
            case BulkImageDownloadStatus.dataSelected:
              return Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      child: Text(
                        'The below tags will be downloaded',
                        style: Theme.of(context)
                            .textTheme
                            .headline5!
                            .copyWith(fontWeight: FontWeight.w900),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 18),
                      child: Wrap(
                        children: state.selectedTags
                            .map((e) => Chip(label: Text(e)))
                            .toList(),
                      ),
                    ),
                    ElevatedButton(
                      onPressed: () =>
                          context.read<BulkImageDownloadBloc>().add(
                                BulkImagesDownloadRequested(
                                  tags: state.selectedTags,
                                ),
                              ),
                      child: const Text('Download'),
                    ),
                  ],
                ),
              );
            case BulkImageDownloadStatus.downloadInProgress:
              return SingleChildScrollView(
                child: Column(
                  children: [
                    ListTile(
                      title: const Text('Total'),
                      trailing: Text(state.totalCount.toString()),
                    ),
                    ListTile(
                      title: const Text('Done'),
                      trailing: Text(state.doneCount.toString()),
                    ),
                    InfoContainer(
                      contentBuilder: (context) => const Text(
                        "Some images might be hidden and won't be downloaded",
                      ),
                    ),
                    WarningContainer(
                      contentBuilder: (context) => const Text(
                        'Please stay on this screen until all files are downloaded',
                      ),
                    ),
                  ],
                ),
              );
            case BulkImageDownloadStatus.failure:
              return Center(
                child: const Text('general.errors.unknown').tr(),
              );
            case BulkImageDownloadStatus.done:
              return Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Expanded(
                    child: CustomScrollView(
                      slivers: [
                        SliverToBoxAdapter(
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Text(
                              '${state.doneCount} images downloaded',
                              style: Theme.of(context)
                                  .textTheme
                                  .headline5!
                                  .copyWith(fontWeight: FontWeight.w900),
                            ),
                          ),
                        ),
                        SliverList(
                          delegate: SliverChildBuilderDelegate(
                            (context, index) {
                              final data = state.downloaded[index];

                              return ListTile(
                                visualDensity: VisualDensity.compact,
                                title: Text(
                                  data.fileName,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  softWrap: false,
                                ),
                                subtitle: Text(
                                  data.relativeToPublicFolderPath,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  softWrap: false,
                                ),
                                leading: Text(
                                  (index + 1).toString(),
                                  style: Theme.of(context).textTheme.titleLarge,
                                ),
                                trailing: ElevatedButton(
                                  onPressed: () => print('open'),
                                  child: const Text('View'),
                                ),
                              );
                            },
                            childCount: state.downloaded.length,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                    child: ElevatedButton(
                      onPressed: () => context
                          .read<BulkImageDownloadBloc>()
                          .add(const BulkImageDownloadReset()),
                      child: const Text('Download more'),
                    ),
                  ),
                ],
              );
          }
        },
      ),
    );

    // return Scaffold(
    //   appBar: AppBar(
    //     title: const Text('Bulk downloads'),
    //   ),
    //   body: Column(
    //     children: [
    //       Expanded(
    //         child: CustomScrollView(
    //           slivers: [
    //             SliverToBoxAdapter(
    //               child: Center(
    //                 child: ValueListenableBuilder<List<String>>(
    //                   valueListenable: selectedTags,
    //                   builder: (context, tags, child) {
    //                     return tags.isNotEmpty
    //                         ? Column(
    //                             children: [
    //                               Text(
    //                                 tags.join(', '),
    //                               ),
    //                             ],
    //                           )
    //                         : const SizedBox.shrink();
    //                   },
    //                 ),
    //               ),
    //             ),
    //             BlocBuilder<BulkImageDownloadBloc, BulkImageDownloadState>(
    //               builder: (context, state) {
    //                 return SliverToBoxAdapter(
    //                   child: Column(
    //                     children: [
    //                       ListTile(
    //                         title: const Text('Total'),
    //                         trailing: Text(state.totalCount.toString()),
    //                       ),
    //                       ListTile(
    //                         title: const Text('Done'),
    //                         trailing: Text(state.doneCount.toString()),
    //                       ),
    //                       InfoContainer(
    //                         contentBuilder: (context) => const Text(
    //                           "Some images might be hidden and won't be downloaded",
    //                         ),
    //                       ),
    //                       WarningContainer(
    //                         contentBuilder: (context) => const Text(
    //                           'Please stay on this screen until all files are downloaded',
    //                         ),
    //                       ),
    //                       ValueListenableBuilder<List<String>>(
    //                         valueListenable: selectedTags,
    //                         builder: (context, tags, child) {
    //                           return ButtonBar(
    //                             children: [
    //                               ElevatedButton.icon(
    //                                 onPressed: () => context
    //                                     .read<BulkImageDownloadBloc>()
    //                                     .add(BulkImagesDownloadRequested(
    //                                       tags: tags,
    //                                     )),
    //                                 icon: const Icon(Icons.download),
    //                                 label: const Text('Download'),
    //                               ),
    //                               ElevatedButton.icon(
    //                                 onPressed: () => selectedTags.value = [],
    //                                 icon: const Icon(Icons.restart_alt),
    //                                 label: const Text('Clear'),
    //                               ),
    //                             ],
    //                           );
    //                         },
    //                       ),
    //                     ],
    //                   ),
    //                 );
    //               },
    //             ),
    //           ],
    //         ),
    //       ),
    //       Padding(
    //         padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 8),
    //         child: SearchBar(
    //           enabled: false,
    //           hintText: 'Add tag',
    //           onTap: () {
    //             showBarModalBottomSheet(
    //               context: context,
    //               builder: (context) => SimpleTagSearchView(
    //                 ensureValidTag: false,
    //                 onSelected: (tag) {
    //                   selectedTags.value = [...selectedTags.value, tag.value];
    //                 },
    //               ),
    //             );
    //           },
    //         ),
    //       ),
    //     ],
    //   ),
    // );
  }
}
