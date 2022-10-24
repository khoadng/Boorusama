// Flutter imports:
import 'package:boorusama/boorus/danbooru/ui/shared/info_container.dart';
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
    this.tags,
  });

  final List<String>? tags;

  @override
  State<BulkDownloadPage> createState() => _BulkDownloadPageState();
}

class _BulkDownloadPageState extends State<BulkDownloadPage> {
  late final selectedTags = ValueNotifier<List<String>>(widget.tags ?? []);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Bulk downloads'),
      ),
      body: Column(
        children: [
          Expanded(
            child: CustomScrollView(
              slivers: [
                SliverToBoxAdapter(
                  child: Center(
                    child: ValueListenableBuilder<List<String>>(
                      valueListenable: selectedTags,
                      builder: (context, tags, child) {
                        return tags.isNotEmpty
                            ? Column(
                                children: [
                                  Text(
                                    tags.join(', '),
                                  ),
                                ],
                              )
                            : const SizedBox.shrink();
                      },
                    ),
                  ),
                ),
                BlocBuilder<BulkImageDownloadBloc, BulkImageDownloadState>(
                  builder: (context, state) {
                    return SliverToBoxAdapter(
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
                          ValueListenableBuilder<List<String>>(
                            valueListenable: selectedTags,
                            builder: (context, tags, child) {
                              return ButtonBar(
                                children: [
                                  ElevatedButton.icon(
                                    onPressed: () => context
                                        .read<BulkImageDownloadBloc>()
                                        .add(BulkImagesDownloadRequested(
                                          tags: tags,
                                        )),
                                    icon: const Icon(Icons.download),
                                    label: const Text('Download'),
                                  ),
                                  ElevatedButton.icon(
                                    onPressed: () => selectedTags.value = [],
                                    icon: const Icon(Icons.restart_alt),
                                    label: const Text('Clear'),
                                  ),
                                ],
                              );
                            },
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 8),
            child: SearchBar(
              enabled: false,
              hintText: 'Add tag',
              onTap: () {
                showBarModalBottomSheet(
                  context: context,
                  builder: (context) => SimpleTagSearchView(
                    ensureValidTag: false,
                    onSelected: (tag) {
                      selectedTags.value = [...selectedTags.value, tag.value];
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
