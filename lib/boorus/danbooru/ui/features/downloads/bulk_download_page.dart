// Flutter imports:
import 'package:animated_flip_counter/animated_flip_counter.dart';
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
import 'package:percent_indicator/percent_indicator.dart';

class BulkDownloadPage extends StatefulWidget {
  const BulkDownloadPage({
    super.key,
  });

  @override
  State<BulkDownloadPage> createState() => _BulkDownloadPageState();
}

class _BulkDownloadPageState extends State<BulkDownloadPage> {
  final textEditingController = TextEditingController();

  @override
  void dispose() {
    textEditingController.dispose();
    super.dispose();
  }

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
              return Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Padding(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
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
                    child: Wrap(
                      spacing: 5,
                      children: [
                        ...state.selectedTags.map((e) => Chip(
                              label: Text(e),
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
                    padding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: TextField(
                      controller: textEditingController,
                      decoration: InputDecoration(
                        filled: true,
                        hintText: state.options.defaultNameIfEmpty,
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
                                options:
                                    state.options.copyWith(folderName: value),
                              ),
                            );
                      },
                    ),
                  ),
                  ListTile(
                    title: const Text('Create new folder if exists'),
                    subtitle: RichText(
                      text: TextSpan(
                        text: 'Enable this option will be saved files in ',
                        style: TextStyle(color: Theme.of(context).hintColor),
                        children: [
                          TextSpan(
                            text: state.options.randomNameIfExists,
                            style: TextStyle(
                              color: Theme.of(context).colorScheme.onBackground,
                            ),
                          ),
                          TextSpan(
                            text:
                                ', otherwise new files will overwrite old files',
                            style:
                                TextStyle(color: Theme.of(context).hintColor),
                          ),
                        ],
                      ),
                    ),
                    trailing: Switch.adaptive(
                      value: state.options.createNewFolderIfExists,
                      onChanged: (value) {
                        context.read<BulkImageDownloadBloc>().add(
                              BulkImageDownloadOptionsChanged(
                                options: state.options
                                    .copyWith(createNewFolderIfExists: value),
                              ),
                            );
                      },
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: ElevatedButton(
                      onPressed: () =>
                          context.read<BulkImageDownloadBloc>().add(
                                BulkImagesDownloadRequested(
                                  tags: state.selectedTags,
                                ),
                              ),
                      child: const Text('Download'),
                    ),
                  ),
                ],
              );
            case BulkImageDownloadStatus.downloadInProgress:
              return SingleChildScrollView(
                child: Column(
                  children: [
                    ListTile(
                      title: const Text('Total'),
                      trailing: AnimatedFlipCounter(value: state.totalCount),
                    ),
                    ListTile(
                      title: const Text('Done'),
                      trailing: AnimatedFlipCounter(value: state.doneCount),
                    ),
                    if (state.totalCount > 0)
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        child: CircularPercentIndicator(
                          radius: 75,
                          lineWidth: 15,
                          animation: true,
                          animateFromLastPercent: true,
                          circularStrokeCap: CircularStrokeCap.round,
                          percent: state.doneCount / state.totalCount,
                          center: Text(
                            '${(state.doneCount / state.totalCount * 100).floor()}%',
                            style: Theme.of(context).textTheme.titleLarge,
                          ),
                        ),
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
  }
}
