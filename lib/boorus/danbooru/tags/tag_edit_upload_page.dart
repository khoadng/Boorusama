// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:collection/collection.dart';
import 'package:filesize/filesize.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:flutter_portal/flutter_portal.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

// Project imports:
import 'package:boorusama/boorus/danbooru/artists/danbooru_artist_url_chips.dart';
import 'package:boorusama/boorus/danbooru/posts/posts.dart';
import 'package:boorusama/boorus/danbooru/sources/sources_provider.dart';
import 'package:boorusama/boorus/danbooru/uploads/uploads.dart';
import 'package:boorusama/clients/danbooru/types/source_dto.dart';
import 'package:boorusama/core/autocompletes/autocompletes.dart';
import 'package:boorusama/core/configs/configs.dart';
import 'package:boorusama/core/images/images.dart';
import 'package:boorusama/core/posts/posts.dart';
import 'package:boorusama/core/scaffolds/tag_edit_scaffold.dart';
import 'package:boorusama/core/search/search.dart';
import 'package:boorusama/core/tags/tags.dart';
import 'package:boorusama/core/widgets/widgets.dart';
import 'package:boorusama/flutter.dart';
import 'package:boorusama/foundation/animations.dart';
import 'package:boorusama/foundation/i18n.dart';
import 'package:boorusama/foundation/theme.dart';
import 'package:boorusama/foundation/toast.dart';
import 'package:boorusama/foundation/url_launcher.dart';
import 'package:boorusama/router.dart';
import 'package:boorusama/string.dart';
import 'package:boorusama/widgets/widgets.dart';
import 'tag_edit_favorite_view.dart';
import 'tag_edit_page.dart';
import 'tag_edit_wiki_view.dart';

final selectTagEditUploadModeProvider =
    StateProvider.autoDispose<TagEditExpandMode?>((ref) => null);

final tagEditUploadViewExpandedProvider =
    StateProvider.autoDispose<bool>((ref) => false);

final tagEditUploadSelectedTagProvider =
    StateProvider.autoDispose<String?>((ref) => null);

final _lastWord = StateProvider.autoDispose<String?>((ref) => null);

final tagEditUploadRelatedExpandedProvider =
    StateProvider.autoDispose<bool>((ref) => false);

class TagEditUploadPage extends ConsumerStatefulWidget {
  const TagEditUploadPage({
    super.key,
    required this.post,
    required this.onSubmitted,
  });

  final DanbooruUploadPost post;
  final void Function() onSubmitted;

  @override
  ConsumerState<TagEditUploadPage> createState() => _TagEditUploadPageState();
}

class _TagEditUploadPageState extends ConsumerState<TagEditUploadPage> {
  String _buildDetails(DanbooruPost post) {
    final fileSizeText =
        post.fileSize > 0 ? '• ${filesize(post.fileSize, 1)}' : '';
    return '${post.width.toInt()}x${post.height.toInt()} • ${post.format.toUpperCase()} $fileSizeText';
  }

  String? originalTitle;
  String? originalDescription;
  String? translatedTitle;
  String? translatedDescription;
  int? parentId;

  @override
  Widget build(BuildContext context) {
    final config = ref.watchConfig;
    final rating = ref.watch(selectedTagEditRatingProvider(null));

    ref.listen(
      danbooruPostCreateProvider(config),
      (previous, next) {
        next.when(
          data: (data) {
            if (data != null) {
              widget.onSubmitted();
              context.pop();
            }
          },
          loading: () {},
          error: (error, stackTrace) {
            showErrorToast(
              error.toString(),
              duration: AppDurations.longToast,
            );
          },
        );
      },
    );

    ref.listen(
      danbooruSourceProvider(widget.post.pageUrl),
      (previous, next) {
        next.maybeWhen(
          data: (data) {
            setState(() {
              originalTitle ??= data.artistCommentary?.dtextTitle;

              originalDescription ??= data.artistCommentary?.dtextDescription;
            });
          },
          orElse: () {},
        );
      },
    );

    return TagEditUploadScaffold(
      imageFooterBuilder: () {
        final text = Text(
          _buildDetails(widget.post),
        );

        return Container(
          margin: const EdgeInsets.symmetric(vertical: 6),
          child: ref
              .watch(danbooruIqdbResultProvider(widget.post.mediaAssetId))
              .maybeWhen(
                data: (results) {
                  final posts = results
                      .map((e) => e.post != null
                          ? postDtoToPostNoMetadata(e.post!)
                          : null)
                      .whereNotNull()
                      .toList();
                  final pixelPerfectDup = posts.firstWhereOrNull(
                      (e) => e.pixelHash == widget.post.pixelHash);

                  return pixelPerfectDup != null || results.isNotEmpty
                      ? Wrap(
                          crossAxisAlignment: WrapCrossAlignment.center,
                          children: [
                            text,
                            const SizedBox(width: 8),
                            if (pixelPerfectDup != null)
                              CompactChip(
                                textColor: Colors.white,
                                label: 'Pixel-Perfect Duplicate',
                                onTap: () {},
                                backgroundColor:
                                    context.colorScheme.errorContainer,
                              )
                            else
                              CompactChip(
                                textColor: Colors.white,
                                label: 'Duplicate',
                                onTap: () {},
                                backgroundColor:
                                    context.colorScheme.errorContainer,
                              ),
                          ],
                        )
                      : text;
                },
                orElse: () => text,
              ),
        );
      },
      splitWeights: const [0.65, 0.35],
      maxSplit: ref.watch(tagEditUploadViewExpandedProvider),
      modeBuilder: (height) => const SizedBox.shrink(),
      contentBuilder: () {
        return ref.watch(danbooruSourceProvider(widget.post.pageUrl)).maybeWhen(
              data: (source) {
                final initialTags = source.artists?.map((e) => e.name);
                return TagEditUploadTextControllerScope(
                  initialText:
                      initialTags != null ? '${initialTags.join(' ')} ' : '',
                  builder: (controller) => DefaultTabController(
                    length: 3,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        _buildTabBar(controller, rating),
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 8),
                            child: TabBarView(
                              physics: const NeverScrollableScrollPhysics(),
                              children: [
                                _buildTagTab(controller, config, source),
                                _buildSourceTab(),
                                _buildSimilarTab(),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
              orElse: () => const Center(
                child: SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(),
                ),
              ),
            );
      },
      aspectRatio: widget.post.aspectRatio ?? 1,
      imageUrl: widget.post.url720x720,
    );
  }

  Widget _buildSimilarTab() {
    return CustomScrollView(
      slivers: [
        const SliverSizedBox(height: 16),
        SliverToBoxAdapter(
          child: BooruTextFormField(
            autocorrect: false,
            onChanged: (value) {
              setState(() {
                parentId = int.tryParse(value);
              });
            },
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              labelText: 'Parent ID',
            ),
          ),
        ),
        const SliverSizedBox(height: 16),
        ref
            .watch(danbooruIqdbResultProvider(widget.post.mediaAssetId))
            .maybeWhen(
              data: (results) {
                return results.isNotEmpty
                    ? SliverGrid.builder(
                        itemCount: results.length,
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          crossAxisSpacing: 8,
                          mainAxisSpacing: 8,
                          childAspectRatio: 0.8,
                        ),
                        itemBuilder: (context, index) {
                          final post = results[index].post != null
                              ? postDtoToPostNoMetadata(results[index].post!)
                              : DanbooruPost.empty();

                          final similar = results[index].score ?? 0;

                          return Column(
                            children: [
                              Expanded(
                                child: BooruImage(
                                  fit: BoxFit.contain,
                                  imageUrl: post.url720x720,
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(4),
                                child: Text(
                                  _buildDetails(post),
                                  style: context.textTheme.bodySmall,
                                ),
                              ),
                              // xx% similar
                              Text(
                                '${similar.toInt()}% Similar',
                                style: context.textTheme.bodySmall?.copyWith(
                                  color: Theme.of(context).hintColor,
                                ),
                              ),
                            ],
                          );
                        },
                      )
                    : SliverToBoxAdapter(
                        child: Center(
                          child: Text(
                            'No similar images found',
                            style: context.textTheme.titleMedium,
                          ),
                        ),
                      );
              },
              orElse: () => const SliverSizedBox.shrink(),
            ),
      ],
    );
  }

  Widget _buildSourceTab() {
    return CustomScrollView(
      slivers: [
        const SliverSizedBox(height: 16),
        SliverToBoxAdapter(
          child: Container(
            constraints: const BoxConstraints(
              minHeight: 80,
            ),
            decoration: BoxDecoration(
              borderRadius: const BorderRadius.all(Radius.circular(8)),
              border: Border.all(
                color: context.colorScheme.onSecondaryContainer,
              ),
              color: context.colorScheme.secondaryContainer,
            ),
            child: ref.watch(danbooruSourceProvider(widget.post.pageUrl)).when(
                  data: (source) => Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      if (source.artists != null && source.artists!.isNotEmpty)
                        for (final artist in source.artists!)
                          Container(
                            margin: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 16,
                            ),
                            child: Row(
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.stretch,
                                    children: [
                                      Text(
                                        artist.name,
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: ref.watch(
                                            tagColorProvider('artist'),
                                          ),
                                        ),
                                      ),
                                      if (artist.sortedUrls != null)
                                        const SizedBox(height: 8),
                                      if (artist.sortedUrls != null)
                                        DanbooruArtistUrlChips(
                                          alignment: WrapAlignment.start,
                                          artistUrls: artist.sortedUrls!
                                              .where((e) => e.isActive == true)
                                              .map((e) => e.url)
                                              .whereNotNull()
                                              .toList(),
                                        ),
                                    ],
                                  ),
                                ),
                                IconButton(
                                  onPressed: () {
                                    ref
                                        .read(danbooruSourceProvider(
                                                widget.post.pageUrl)
                                            .notifier)
                                        .fetch();
                                  },
                                  icon: const Icon(Icons.refresh),
                                ),
                              ],
                            ),
                          )
                      else
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const SizedBox(width: 16),
                            Text(source.artist?.name ?? '???'),
                            const Spacer(),
                            FilledButton(
                              style: FilledButton.styleFrom(
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                              onPressed: () {
                                final url =
                                    '${ref.readConfig.url}/artists/new?artist[source]=${widget.post.pageUrl}';
                                launchExternalUrlString(url);
                              },
                              child: const Text('Create'),
                            ),
                            const SizedBox(width: 16),
                          ],
                        ),
                    ],
                  ),
                  error: (_, __) => const SizedBox.shrink(),
                  loading: () => const Center(
                    child: SizedBox(
                      height: 24,
                      width: 24,
                      child: CircularProgressIndicator(),
                    ),
                  ),
                ),
          ),
        ),
        const SliverSizedBox(height: 16),
        SliverToBoxAdapter(
          child: AutofillGroup(
            child: BooruTextFormField(
              initialValue: widget.post.pageUrl,
              readOnly: true,
              autocorrect: false,
              keyboardType: TextInputType.url,
              autofillHints: const [
                AutofillHints.url,
              ],
              validator: (p0) => null,
              decoration: const InputDecoration(
                labelText: 'Source',
              ),
            ),
          ),
        ),
        const SliverSizedBox(height: 16),
        ref.watch(danbooruSourceProvider(widget.post.pageUrl)).maybeWhen(
              data: (source) => SliverToBoxAdapter(
                child: AutofillGroup(
                  child: BooruTextFormField(
                    initialValue: source.artistCommentary?.dtextTitle,
                    readOnly: true,
                    autocorrect: false,
                    validator: (p0) => null,
                    onChanged: (value) {
                      setState(() {
                        originalTitle = value;
                      });
                    },
                    decoration: const InputDecoration(
                      labelText: 'Original Title',
                    ),
                  ),
                ),
              ),
              orElse: () => const SliverSizedBox.shrink(),
            ),
        const SliverSizedBox(height: 16),
        ref.watch(danbooruSourceProvider(widget.post.pageUrl)).maybeWhen(
              data: (source) => SliverToBoxAdapter(
                child: AutofillGroup(
                  child: BooruTextFormField(
                    initialValue: source.artistCommentary?.dtextDescription,
                    readOnly: true,
                    autocorrect: false,
                    validator: (p0) => null,
                    minLines: 3,
                    maxLines: 3,
                    onChanged: (value) {
                      setState(() {
                        originalDescription = value;
                      });
                    },
                    decoration: const InputDecoration(
                      labelText: 'Original Description',
                    ),
                  ),
                ),
              ),
              orElse: () => const SliverSizedBox.shrink(),
            ),
        const SliverSizedBox(height: 16),
        SliverToBoxAdapter(
          child: AutofillGroup(
            child: BooruTextFormField(
              autocorrect: false,
              validator: (p0) => null,
              onChanged: (value) {
                setState(() {
                  translatedTitle = value;
                });
              },
              decoration: const InputDecoration(
                labelText: 'Translated Title',
              ),
            ),
          ),
        ),
        const SliverSizedBox(height: 16),
        SliverToBoxAdapter(
          child: AutofillGroup(
            child: BooruTextFormField(
              autocorrect: false,
              onChanged: (value) {
                setState(() {
                  translatedDescription = value;
                });
              },
              validator: (p0) => null,
              minLines: 3,
              maxLines: 3,
              decoration: const InputDecoration(
                labelText: 'Translated Description',
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTagTab(
    TextEditingController textEditingController,
    BooruConfig config,
    SourceDto source,
  ) {
    return Theme(
      data: context.theme.copyWith(
        listTileTheme: context.theme.listTileTheme.copyWith(
          visualDensity: const ShrinkVisualDensity(),
        ),
        dividerColor: Colors.transparent,
      ),
      child: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: _buildRatingSelector(config),
          ),
          const SliverSizedBox(height: 8),
          SliverToBoxAdapter(
            child: _buildSuggestions(textEditingController),
          ),
          SliverToBoxAdapter(
            child: _buildTranslated(textEditingController, source),
          ),
          SliverToBoxAdapter(
            child: _buildRelated(textEditingController),
          ),
          SliverToBoxAdapter(
            child: _buildFavorites(textEditingController),
          ),
        ],
      ),
    );
  }

  Widget _buildTranslated(
    TextEditingController textEditingController,
    SourceDto source,
  ) {
    final translatedTags = [
      if (source.artists != null)
        ...source.artists!.map((e) => (
              name: e.name,
              count: null,
              category: TagCategory.artist(),
            )),
      if (source.translatedTags != null)
        ...source.translatedTags!.where((e) => e.name != null).map((e) => (
              name: e.name!,
              count: e.postCount,
              category: TagCategory.fromLegacyId(e.category ?? 0),
            ))
    ];

    return translatedTags.isNotEmpty
        ? ValueListenableBuilder(
            valueListenable: textEditingController,
            builder: (context, value, child) {
              final tags = value.text.split(' ');

              return ExpansionTile(
                initiallyExpanded: true,
                title: const Text('Translated'),
                controlAffinity: ListTileControlAffinity.leading,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Container(
                        margin: const EdgeInsets.symmetric(
                          horizontal: 12,
                        ),
                        child: Wrap(
                          alignment: WrapAlignment.start,
                          spacing: 4,
                          children: [
                            for (final tag in translatedTags)
                              BooruChip(
                                visualDensity: const ShrinkVisualDensity(),
                                onPressed: () {
                                  final name = tag.name;

                                  if (tags.contains(name)) {
                                    _removeTag(textEditingController, name);
                                  } else {
                                    _addTag(textEditingController, name);
                                  }
                                },
                                showBackground: tags.contains(tag.name),
                                showBorder: tags.contains(tag.name),
                                label: Text(
                                  tag.name.replaceAll('_', ' '),
                                ),
                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
                                ),
                                color: ref
                                    .watch(tagColorProvider(tag.category.name)),
                              ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              );
            },
          )
        : const SizedBox.shrink();
  }

  Widget _buildFavorites(TextEditingController textEditingController) {
    return ValueListenableBuilder(
      valueListenable: textEditingController,
      builder: (context, value, child) {
        final tags = value.text.split(' ');

        return ExpansionTile(
          title: const Text('Favorites'),
          controlAffinity: ListTileControlAffinity.leading,
          children: [
            TagEditFavoriteView(
              onRemoved: (tag) {
                _removeTag(textEditingController, tag);
              },
              onAdded: (tag) {
                _addTag(textEditingController, tag);
              },
              isSelected: (tag) => tags.contains(tag),
            ),
          ],
        );
      },
    );
  }

  Widget _buildRelated(TextEditingController textEditingController) {
    return ValueListenableBuilder(
      valueListenable: textEditingController,
      builder: (context, value, child) {
        final tags = value.text.split(' ');
        final selectedTag =
            ref.watch(tagEditUploadSelectedTagProvider)?.replaceAll('_', ' ') ??
                '';

        return ExpansionTile(
          controlAffinity: ListTileControlAffinity.leading,
          title: Row(
            children: [
              const Text('Related'),
              const SizedBox(width: 8),
              if (selectedTag.isNotEmpty)
                BooruChip(
                  visualDensity: const ShrinkVisualDensity(),
                  onPressed: () {},
                  label: Text(
                    selectedTag,
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  color: ref.watch(tagColorProvider('general')),
                ),
            ],
          ),
          onExpansionChanged: (value) {
            ref.read(tagEditUploadRelatedExpandedProvider.notifier).state =
                value;
          },
          children: [
            if (ref.watch(tagEditUploadRelatedExpandedProvider))
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                ),
                child: TagEditWikiView(
                  tag: ref.watch(tagEditUploadSelectedTagProvider),
                  onRemoved: (tag) {
                    _removeTag(textEditingController, tag);
                  },
                  onAdded: (tag) {
                    _addTag(textEditingController, tag);
                  },
                  isSelected: (tag) => tags.contains(tag),
                ),
              ),
          ],
        );
      },
    );
  }

  Widget _buildSuggestions(TextEditingController textEditingController) {
    return PortalTarget(
      anchor: const Aligned(
        follower: Alignment.bottomLeft,
        target: Alignment.topLeft,
      ),
      portalFollower: TagSuggestionsPortalFollower(
        onSelected: (tag) {
          // _addTag(ref, tags, tag);

          final currentText = textEditingController.text;

          // replace last word with the selected tag
          final newText = currentText
              .split(' ')
              .reversed
              .skip(1)
              .toList()
              .reversed
              .join(' ')
              .trim();

          textEditingController.text = newText.isEmpty ? tag : '$newText $tag ';
          ref.read(_lastWord.notifier).state = null;
        },
      ),
      child: BooruTextFormField(
        controller: textEditingController,
        autocorrect: false,
        maxLines: 4,
        minLines: 4,
        validator: (p0) => null,
      ),
    );
  }

  Widget _buildRatingSelector(BooruConfig config) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.all(8),
          child: Row(
            children: [
              Text(
                'Rating',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              if (!config.hasStrictSFW)
                IconButton(
                  splashRadius: 20,
                  visualDensity: VisualDensity.compact,
                  onPressed: () => launchExternalUrlString(kHowToRateUrl),
                  icon: const Icon(
                    FontAwesomeIcons.circleQuestion,
                    size: 16,
                  ),
                ),
              const Spacer(),
              OptionDropDownButton(
                alignment: AlignmentDirectional.centerStart,
                value: ref.watch(selectedTagEditRatingProvider(null)),
                onChanged: (value) => ref
                    .read(selectedTagEditRatingProvider(null).notifier)
                    .state = value,
                items: [...Rating.values.where((e) => e != Rating.unknown)]
                    .map(
                      (value) => DropdownMenuItem(
                        value: value,
                        child: Text(value.name.sentenceCase),
                      ),
                    )
                    .toList(),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTabBar(
    TextEditingController textEditingController,
    Rating? rating,
  ) {
    final notifier =
        ref.watch(danbooruPostCreateProvider(ref.watchConfig).notifier);

    return Row(
      children: [
        Expanded(
          child: TabBar(
            isScrollable: true,
            tabs: [
              const Tab(text: 'Tags'),
              const Tab(text: 'Source'),
              ref
                  .watch(danbooruIqdbResultProvider(widget.post.mediaAssetId))
                  .maybeWhen(
                    data: (results) => results.isNotEmpty
                        ? Badge.count(
                            offset: const Offset(16, 4),
                            count: results.length,
                            child: const Tab(text: 'Similar'),
                          )
                        : const Tab(text: 'Similar'),
                    orElse: () => const Tab(text: 'Similar'),
                  ),
            ],
          ),
        ),
        ValueListenableBuilder(
          valueListenable: textEditingController,
          builder: (context, value, child) {
            return TextButton(
              onPressed: (value.text.isNotEmpty &&
                      rating != null &&
                      widget.post.source.url != null)
                  ? ref
                      .watch(danbooruPostCreateProvider(ref.watchConfig))
                      .maybeWhen(
                        loading: () => null,
                        orElse: () => () {
                          notifier.create(
                            mediaAssetId: widget.post.mediaAssetId,
                            uploadMediaAssetId: widget.post.uploadMediaAssetId,
                            rating: rating,
                            source: widget.post.pageUrl,
                            tags: value.text.split(' '),
                            artistCommentaryTitle: originalTitle,
                            artistCommentaryDesc: originalDescription,
                            translatedCommentaryTitle: translatedTitle,
                            translatedCommentaryDesc: translatedDescription,
                            parentId: parentId,
                          );
                        },
                      )
                  : null,
              child: const Text('Post'),
            );
          },
        ),
      ],
    );
  }

  void _removeTag(
    TextEditingController textEditingController,
    String tag,
  ) {
    final currentTags = textEditingController.text;
    textEditingController.text = currentTags.replaceAll('$tag ', '');

    ref.read(_lastWord.notifier).state = null;
  }

  void _addTag(TextEditingController textEditingController, String tag) {
    final currentText = textEditingController.text;

    // append the selected tag
    textEditingController.text =
        currentText.isEmpty ? '$tag ' : '$currentText$tag ';

    ref.read(_lastWord.notifier).state = null;
  }
}

class TagEditUploadTextControllerScope extends ConsumerStatefulWidget {
  const TagEditUploadTextControllerScope({
    super.key,
    required this.initialText,
    required this.builder,
  });

  final String initialText;
  final Widget Function(TextEditingController controller) builder;

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _TagEditUploadTextControllerScopeState();
}

class _TagEditUploadTextControllerScopeState
    extends ConsumerState<TagEditUploadTextControllerScope> {
  late final textEditingController =
      TextEditingController(text: widget.initialText);

  @override
  void initState() {
    super.initState();
    textEditingController.addListener(_onSelectionChanged);
  }

  @override
  void dispose() {
    super.dispose();
    textEditingController.removeListener(_onSelectionChanged);
    textEditingController.dispose();
  }

  void _onSelectionChanged() {
    final selection = textEditingController.selection;
    final text = textEditingController.text;
    final texts = text.split(' ').reversed.toList();

    final lastWord = texts.firstOrNull;
    final previousLastWord = texts.elementAtOrNull(1) ?? lastWord ?? '';

    if (lastWord != null) {
      ref.read(_lastWord.notifier).state = lastWord;

      ref
          .read(suggestionsProvider(ref.readConfig).notifier)
          .getSuggestions(lastWord);
    }

    // Find the start and end index of the word nearest to the cursor
    var start = selection.baseOffset;
    var end = selection.extentOffset;

    final trueLastWord =
        lastWord != null && lastWord.isNotEmpty ? lastWord : previousLastWord;

    // check if the cursor is at the last character then just set the selected tag to the last word and return
    if (end == text.length || start == -1 || end == -1) {
      ref.read(tagEditUploadSelectedTagProvider.notifier).state = trueLastWord;
      return;
    }

    // Find the beginning of the nearest word
    while (start > 0 && text[start - 1].trim().isNotEmpty) {
      start--;
    }

    // Find the end of the nearest word
    while (end < text.length && text[end].trim().isNotEmpty) {
      end++;
    }

    // Extract the nearest word
    final nearestWord = text.substring(start, end);

    ref.read(tagEditUploadSelectedTagProvider.notifier).state =
        nearestWord.isEmpty ? trueLastWord : nearestWord;
  }

  @override
  Widget build(BuildContext context) {
    return widget.builder(textEditingController);
  }
}

Widget _getTitle(
  AutocompleteData tag,
  String currentQuery,
  Color? color,
) {
  final query = currentQuery.replaceUnderscoreWithSpace().toLowerCase();
  return tag.hasAlias
      ? Html(
          style: {
            'p': Style(
              fontSize: FontSize.medium,
              color: color,
              margin: Margins.zero,
            ),
            'body': Style(
              margin: Margins.zero,
            ),
            'b': Style(
              fontWeight: FontWeight.w900,
            ),
          },
          data:
              '<p>${tag.antecedent!.replaceUnderscoreWithSpace().replaceAll(query, '<b>$query</b>')} ➞ ${tag.label.replaceAll(query, '<b>$query</b>')}</p>',
        )
      : Html(
          style: {
            'p': Style(
              fontSize: FontSize.medium,
              color: color,
            ),
            'b': Style(
              fontWeight: FontWeight.w900,
            ),
          },
          data:
              '<p>${tag.label.replaceAll(query.replaceUnderscoreWithSpace(), '<b>$query</b>')}</p>',
        );
}

class TagSuggestionsPortalFollower extends ConsumerWidget {
  const TagSuggestionsPortalFollower({
    super.key,
    required this.onSelected,
  });

  final void Function(String tag) onSelected;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final lastQuery = ref.watch(_lastWord);
    final tags = lastQuery != null
        ? ref.watch(suggestionProvider(lastQuery)).reversed.toList()
        : <AutocompleteData>[];

    return tags.isEmpty
        ? const SizedBox.shrink()
        : Container(
            margin: const EdgeInsets.only(
              bottom: 4,
              left: 4,
              right: 40,
            ),
            constraints: const BoxConstraints(
              maxHeight: 200,
            ),
            width: context.screenWidth,
            color: context.colorScheme.secondaryContainer,
            child: SingleChildScrollView(
              reverse: true,
              child: Column(
                children: tags.map(
                  (tag) {
                    return InkWell(
                      onTap: () {
                        onSelected(tag.value);
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: _getTitle(
                                tag,
                                lastQuery ?? '',
                                generateAutocompleteTagColor(ref, context, tag),
                              ),
                            ),
                            if (tag.hasCount && !ref.watchConfig.hasStrictSFW)
                              Container(
                                constraints:
                                    const BoxConstraints(maxWidth: 100),
                                child: Text(
                                  NumberFormat.compact().format(tag.postCount),
                                  style: TextStyle(
                                    color: context.theme.hintColor,
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                    );
                  },
                ).toList(),
              ),
            ),
          );
  }
}
