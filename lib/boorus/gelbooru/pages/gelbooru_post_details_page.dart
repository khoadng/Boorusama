// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:collection/collection.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import 'package:boorusama/boorus/booru_builder.dart';
import 'package:boorusama/boorus/gelbooru/feats/posts/posts.dart';
import 'package:boorusama/boorus/gelbooru/gelbooru.dart';
import 'package:boorusama/core/feats/boorus/boorus.dart';
import 'package:boorusama/core/feats/notes/notes.dart';
import 'package:boorusama/core/feats/posts/posts.dart';
import 'package:boorusama/core/feats/tags/tags.dart';
import 'package:boorusama/core/router.dart';
import 'package:boorusama/core/scaffolds/scaffolds.dart';
import 'package:boorusama/core/utils.dart';
import 'package:boorusama/core/widgets/posts/character_post_list.dart';
import 'package:boorusama/core/widgets/widgets.dart';
import 'package:boorusama/functional.dart';
import 'package:boorusama/widgets/widgets.dart';

final gelbooruPostDetailsArtistMapProvider = StateProvider.autoDispose(
  (ref) => <int, List<String>>{},
);

final gelbooruPostDetailsCharacterMapProvider = StateProvider.autoDispose(
  (ref) => <int, Set<String>>{},
);

class GelbooruPostDetailsPage extends ConsumerStatefulWidget {
  const GelbooruPostDetailsPage({
    super.key,
    required this.posts,
    required this.initialIndex,
    required this.onExit,
  });

  final int initialIndex;
  final List<GelbooruPost> posts;
  final void Function(int page) onExit;

  @override
  ConsumerState<GelbooruPostDetailsPage> createState() =>
      _PostDetailPageState();
}

class _PostDetailPageState extends ConsumerState<GelbooruPostDetailsPage> {
  List<GelbooruPost> get posts => widget.posts;

  @override
  Widget build(BuildContext context) {
    final booruConfig = ref.watchConfig;

    return PostDetailsPageScaffold(
      posts: posts,
      initialIndex: widget.initialIndex,
      onExit: widget.onExit,
      onTagTap: (tag) => goToSearchPage(context, tag: tag),
      toolbarBuilder: (context, post) => SimplePostActionToolbar(post: post),
      swipeImageUrlBuilder: defaultPostImageUrlBuilder(ref),
      fileDetailsBuilder: (context, post) => FileDetailsSection(
        post: post,
        rating: post.rating,
        uploader: post.uploaderName != null
            ? Text(
                post.uploaderName!.replaceAll('_', ' '),
                maxLines: 1,
                style: const TextStyle(
                  fontSize: 14,
                ),
              )
            : null,
      ),
      sliverArtistPostsBuilder: (context, post) =>
          ref.watch(gelbooruPostDetailsArtistMapProvider).lookup(post.id).fold(
                () => [],
                (tags) => tags.isNotEmpty
                    ? tags
                        .map((tag) => ArtistPostList2(
                              tag: tag,
                              builder: (tag) => ref
                                  .watch(gelbooruArtistPostsProvider(tag))
                                  .maybeWhen(
                                    data: (data) => SliverPreviewPostGrid(
                                      posts: data,
                                      onTap: (postIdx) => goToPostDetailsPage(
                                        context: context,
                                        posts: data,
                                        initialIndex: postIdx,
                                      ),
                                      imageUrl: (item) => item.sampleImageUrl,
                                    ),
                                    orElse: () =>
                                        const SliverPreviewPostGridPlaceholder(
                                      itemCount: 30,
                                    ),
                                  ),
                            ))
                        .toList()
                    : [],
              ),
      sliverCharacterPostsBuilder: (context, post) => ref
          .watch(gelbooruPostDetailsCharacterMapProvider)
          .lookup(post.id)
          .fold(
            () => const SliverSizedBox.shrink(),
            (tags) => tags.isNotEmpty
                ? CharacterPostList(
                    tags: tags,
                  )
                : const SliverSizedBox.shrink(),
          ),
      tagListBuilder: (context, post) => TagsTile(
        tags: ref.watch(tagsProvider(booruConfig)),
        post: post,
        onTagTap: (tag) => goToSearchPage(context, tag: tag.rawName),
      ),
      imageOverlayBuilder: (constraints, post) => noteOverlayBuilderDelegate(
        constraints,
        post,
        ref.watch(notesControllerProvider(post)),
      ),
      topRightButtonsBuilder: (page, expanded, post) {
        return [
          NoteActionButtonWithProvider(
            post: post,
            expanded: expanded,
            noteState: ref.watch(notesControllerProvider(post)),
          ),
          GeneralMoreActionButton(post: post),
        ];
      },
      onExpanded: (post) => ref.read(tagsProvider(booruConfig).notifier).load(
            post.tags,
            onSuccess: (tags) => _setTags(post, tags),
          ),
    );
  }

  void _setTags(
    GelbooruPost post,
    List<TagGroupItem> tags,
  ) {
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      if (!mounted) return;
      ref.setGelbooruPostDetailsArtistMap(
        post: post,
        tags: tags,
      );

      ref.setGelbooruPostDetailsCharacterMap(
        post: post,
        tags: tags,
      );
    });
  }
}

extension GelbooruArtistMapProviderX on WidgetRef {
  void setGelbooruPostDetailsArtistMap({
    required Post post,
    required List<TagGroupItem> tags,
  }) {
    final group =
        tags.firstWhereOrNull((tag) => tag.groupName.toLowerCase() == 'artist');

    if (group == null) return;
    final map = read(gelbooruPostDetailsArtistMapProvider);

    map[post.id] = group.tags.map((e) => e.rawName).toList();

    read(gelbooruPostDetailsArtistMapProvider.notifier).state = {
      ...map,
    };
  }

  void setGelbooruPostDetailsCharacterMap({
    required Post post,
    required List<TagGroupItem> tags,
  }) {
    final group = tags.firstWhereOrNull(
      (tag) => tag.groupName.toLowerCase() == 'character',
    );

    if (group == null) return;
    final map = read(gelbooruPostDetailsCharacterMapProvider);

    map[post.id] = group.tags.map((e) => e.rawName).toSet();

    read(gelbooruPostDetailsCharacterMapProvider.notifier).state = {
      ...map,
    };
  }
}
