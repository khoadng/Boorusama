// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:collection/collection.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:foundation/foundation.dart';
import 'package:foundation/widgets.dart';
import 'package:sliver_tools/sliver_tools.dart';

// Project imports:
import '../../../core/configs/ref.dart';
import '../../../core/posts/details/details.dart';
import '../../../core/posts/details/parts.dart';
import '../../../core/posts/post/post.dart';
import '../../../core/router.dart';
import '../../../core/tags/tag/providers.dart';
import '../../../core/tags/tag/tag.dart';
import '../artists/artists.dart';
import 'posts.dart';

final gelbooruPostDetailsArtistMapProvider = StateProvider.autoDispose(
  (ref) => <int, List<String>>{},
);

final gelbooruPostDetailsCharacterMapProvider = StateProvider.autoDispose(
  (ref) => <int, Set<String>>{},
);

class GelbooruTagListSection extends ConsumerStatefulWidget {
  const GelbooruTagListSection({
    super.key,
  });

  @override
  ConsumerState<GelbooruTagListSection> createState() =>
      _GelbooruTagListSectionState();
}

class _GelbooruTagListSectionState
    extends ConsumerState<GelbooruTagListSection> {
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      if (!context.mounted) return;
      _fetchTags();
    });
  }

  void _fetchTags() {
    final config = ref.watchConfigAuth;
    final post = InheritedPost.of<GelbooruPost>(context);

    ref.read(tagsProvider(config).notifier).load(
      post.tags,
      onSuccess: (tags) {
        WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
          if (!context.mounted) return;
          ref.setGelbooruPostDetailsArtistMap(
            post: post,
            tags: tags,
          );

          ref.setGelbooruPostDetailsCharacterMap(
            post: post,
            tags: tags,
          );
        });
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final config = ref.watchConfigAuth;
    final post = InheritedPost.of<GelbooruPost>(context);

    return SliverToBoxAdapter(
      child: TagsTile(
        tags: ref.watch(tagsProvider(config)),
        post: post,
        onTagTap: (tag) => goToSearchPage(context, tag: tag.rawName),
        onExpand: () => _fetchTags(),
      ),
    );
  }
}

class GelbooruCharacterListSection extends ConsumerWidget {
  const GelbooruCharacterListSection({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final post = InheritedPost.of<GelbooruPost>(context);

    return ref
        .watch(gelbooruPostDetailsCharacterMapProvider)
        .lookup(post.id)
        .fold(
          () => const SliverSizedBox.shrink(),
          (tags) => tags.isNotEmpty
              ? SliverCharacterPostList(
                  tags: tags,
                )
              : const SliverSizedBox.shrink(),
        );
  }
}

class GelbooruFileDetailsSection extends StatelessWidget {
  const GelbooruFileDetailsSection({
    super.key,
    this.initialExpanded = false,
  });

  final bool initialExpanded;

  @override
  Widget build(BuildContext context) {
    final post = InheritedPost.of<GelbooruPost>(context);

    return SliverToBoxAdapter(
      child: DefaultFileDetailsSection(
        post: post,
        initialExpanded: initialExpanded,
        uploaderName: post.uploaderName,
      ),
    );
  }
}

class GelbooruArtistPostsSection extends ConsumerWidget {
  const GelbooruArtistPostsSection({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final post = InheritedPost.of<GelbooruPost>(context);

    return MultiSliver(
      children:
          ref.watch(gelbooruPostDetailsArtistMapProvider).lookup(post.id).fold(
                () => const [],
                (tags) => tags.isNotEmpty
                    ? tags
                        .map(
                          (tag) => SliverArtistPostList(
                            tag: tag,
                            child: ref
                                .watch(gelbooruArtistPostsProvider(tag))
                                .maybeWhen(
                                  data: (data) => SliverPreviewPostGrid(
                                    posts: data,
                                    onTap: (postIdx) =>
                                        goToPostDetailsPageFromPosts(
                                      context: context,
                                      posts: data,
                                      initialIndex: postIdx,
                                    ),
                                    imageUrl: (item) => item.sampleImageUrl,
                                  ),
                                  orElse: () =>
                                      const SliverPreviewPostGridPlaceholder(),
                                ),
                          ),
                        )
                        .toList()
                    : [],
              ),
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
