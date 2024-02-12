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
import 'package:boorusama/core/feats/posts/posts.dart';
import 'package:boorusama/core/feats/tags/tags.dart';
import 'package:boorusama/core/router.dart';
import 'package:boorusama/core/scaffolds/scaffolds.dart';
import 'package:boorusama/core/widgets/widgets.dart';
import 'package:boorusama/functional.dart';
import 'package:boorusama/widgets/widgets.dart';

final gelbooruPostDetailsArtistMapProvider = StateProvider.autoDispose(
  (ref) => <int, List<String>>{},
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
      sliverArtistPostsBuilder: (context, post) => ref
          .watch(gelbooruPostDetailsArtistMapProvider)
          .lookup(post.id)
          .fold(
            () => const SliverSizedBox.shrink(),
            (tags) => tags.isNotEmpty
                ? ArtistPostList(
                    artists: tags,
                    builder: (tag) =>
                        ref.watch(gelbooruArtistPostsProvider(tag)).maybeWhen(
                              data: (data) => PreviewPostGrid(
                                posts: data,
                                onTap: (postIdx) => goToPostDetailsPage(
                                  context: context,
                                  posts: data,
                                  initialIndex: postIdx,
                                ),
                                imageUrl: (item) => item.sampleImageUrl,
                              ),
                              orElse: () => const PreviewPostGridPlaceholder(
                                imageCount: 30,
                              ),
                            ),
                  )
                : const SliverSizedBox.shrink(),
          ),
      tagListBuilder: (context, post) =>
          ref.watchConfig.booruType == BooruType.gelbooru
              ? TagsTile(
                  tags: ref.watch(tagsProvider(booruConfig)),
                  post: post,
                  onTagTap: (tag) => goToSearchPage(context, tag: tag.rawName),
                )
              : GelbooruV1TagsTile(post: post),
      onExpanded: (post) => ref.watchConfig.booruType == BooruType.gelbooru
          ? ref.read(tagsProvider(booruConfig).notifier).load(
              post.tags,
              onSuccess: (tags) {
                if (!mounted) return;
                ref.setGelbooruPostDetailsArtistMap(
                  post: post,
                  tags: tags,
                );
              },
            )
          : null,
    );
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
}

class GelbooruV1TagsTile extends ConsumerStatefulWidget {
  const GelbooruV1TagsTile({
    super.key,
    required this.post,
  });

  final Post post;

  @override
  ConsumerState<GelbooruV1TagsTile> createState() => _GelbooruV1TagsTileState();
}

class _GelbooruV1TagsTileState extends ConsumerState<GelbooruV1TagsTile> {
  var expanded = false;
  Object? error;

  @override
  Widget build(BuildContext context) {
    if (expanded) {
      ref.listen(gelbooruV2TagsFromIdProvider(widget.post.id),
          (previous, next) {
        next.when(
          data: (data) {
            if (!mounted) return;
            if (data.isEmpty && widget.post.tags.isNotEmpty) {
              // Just a dummy data so the check below will branch into the else block
              setState(() => error = 'No tags found');
            }
          },
          loading: () {},
          error: (error, stackTrace) {
            if (!mounted) return;
            setState(() => this.error = error);
          },
        );
      });
    }

    return error == null
        ? TagsTile(
            tags: expanded
                ? ref
                    .watch(gelbooruV2TagsFromIdProvider(widget.post.id))
                    .maybeWhen(
                      data: (data) => createTagGroupItems(data),
                      orElse: () => null,
                    )
                : null,
            post: widget.post,
            onExpand: () => setState(() => expanded = true),
            onCollapse: () {
              // Don't set expanded to false to prevent rebuilding the tags list
              setState(() => error = null);
            },
            onTagTap: (tag) => goToSearchPage(context, tag: tag.rawName),
          )
        : BasicTagList(
            tags: widget.post.tags,
            onTap: (tag) => goToSearchPage(context, tag: tag),
          );
  }
}
