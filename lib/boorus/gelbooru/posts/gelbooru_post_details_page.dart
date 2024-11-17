// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:collection/collection.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import 'package:boorusama/boorus/gelbooru/artists/artists.dart';
import 'package:boorusama/boorus/gelbooru/posts/posts.dart';
import 'package:boorusama/core/configs/configs.dart';
import 'package:boorusama/core/posts/posts.dart';
import 'package:boorusama/core/tags/tags.dart';
import 'package:boorusama/functional.dart';
import 'package:boorusama/router.dart';
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
  });

  @override
  ConsumerState<GelbooruPostDetailsPage> createState() =>
      _PostDetailPageState();
}

class _PostDetailPageState extends ConsumerState<GelbooruPostDetailsPage> {
  @override
  Widget build(BuildContext context) {
    final booruConfig = ref.watchConfig;
    final data = PostDetails.of<GelbooruPost>(context);
    final posts = data.posts;
    final controller = data.controller;

    return PostDetailsPageScaffold(
      controller: controller,
      posts: posts,
      fileDetailsBuilder: (context, post) => DefaultFileDetailsSection(
        post: post,
        uploaderName: post.uploaderName,
      ),
      sliverArtistPostsBuilder: (context, post) =>
          ref.watch(gelbooruPostDetailsArtistMapProvider).lookup(post.id).fold(
                () => const [],
                (tags) => tags.isNotEmpty
                    ? tags
                        .map((tag) => ArtistPostList(
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
                                        const SliverPreviewPostGridPlaceholder(),
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
