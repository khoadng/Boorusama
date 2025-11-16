// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:foundation/foundation.dart';
import 'package:foundation/widgets.dart';
import 'package:i18n/i18n.dart';

// Project imports:
import '../../../core/configs/config/providers.dart';
import '../../../core/configs/config/types.dart';
import '../../../core/posts/details/routes.dart';
import '../../../core/posts/details/types.dart';
import '../../../core/posts/details/widgets.dart';
import '../../../core/posts/details_parts/types.dart';
import '../../../core/posts/details_parts/widgets.dart';
import '../../../core/posts/post/types.dart';
import '../../../core/router.dart';
import '../../../core/search/search/routes.dart';
import '../gelbooru_v2_provider.dart';
import 'providers.dart';
import 'types.dart';

class GelbooruV2PostDetailsPage extends ConsumerWidget {
  const GelbooruV2PostDetailsPage({
    required this.payload,
    super.key,
  });

  final DetailsRouteContext payload;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final configSearch = ref.watchConfigSearch;

    final postId = payload.posts.getOrNull(payload.initialIndex)?.id;

    if (postId == null) {
      return InvalidPage(message: 'Invalid post: $postId');
    }

    final gelbooruV2 = ref.watch(gelbooruV2Provider);

    final thumbnailOnly =
        gelbooruV2
            .getCapabilitiesForSite(configSearch.auth.url)
            ?.posts
            ?.thumbnailOnly ??
        false;

    if (thumbnailOnly) {
      return _PostDetailsDataLoadingTransitionPage(
        postId: NumericPostId(postId),
        configSearch: configSearch,
        pageBuilder: (context, detailsContext) {
          final widget = InheritedDetailsContext(
            context: detailsContext,
            child: const _PayloadPostDetailsPage(),
          );

          return widget;
        },
      );
    }

    final posts = payload.posts.map((e) => e as GelbooruV2Post).toList();

    return PostDetailsScope(
      initialIndex: payload.initialIndex,
      initialThumbnailUrl: payload.initialThumbnailUrl,
      posts: posts,
      scrollController: payload.scrollController,
      dislclaimer: payload.dislclaimer,
      child: const DefaultPostDetailsPage<GelbooruV2Post>(),
    );
  }
}

class _PayloadPostDetailsPage<T extends Post> extends ConsumerWidget {
  const _PayloadPostDetailsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final payload = InheritedDetailsContext.of<T>(context);
    final configSearch = payload.configSearch;

    if (configSearch == null) {
      return const UnimplementedPage();
    }

    return PostDetailsScope(
      initialIndex: payload.initialIndex,
      initialThumbnailUrl: payload.initialThumbnailUrl,
      posts: payload.posts.map((e) => e as GelbooruV2Post).toList(),
      scrollController: payload.scrollController,
      dislclaimer: payload.dislclaimer,
      child: const DefaultPostDetailsPage<GelbooruV2Post>(),
    );
  }
}

class _PostDetailsDataLoadingTransitionPage extends ConsumerWidget {
  const _PostDetailsDataLoadingTransitionPage({
    required this.pageBuilder,
    required this.postId,
    required this.configSearch,
  });

  final PostId postId;
  final BooruConfigSearch configSearch;

  final Widget Function(
    BuildContext context,
    DetailsRouteContext<Post> detailsContext,
  )
  pageBuilder;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final params = (postId, configSearch);
    return ref
        .watch(gelbooruV2PostProvider(params))
        .when(
          data: (post) {
            if (post == null) {
              return InvalidPage(message: 'Invalid post: $post');
            }

            final detailsContext = DetailsRouteContext(
              initialIndex: 0,
              posts: [post],
              scrollController: null,
              isDesktop: false,
              hero: false,
              initialThumbnailUrl: null,
              dislclaimer:
                  'This site only supports viewing one post at a time.'.hc,
              configSearch: configSearch,
            );
            return pageBuilder(context, detailsContext);
          },
          error: (error, stackTrace) => InvalidPage(message: error.toString()),
          loading: () => const Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          ),
        );
  }
}

class GelbooruV2UploaderFileDetailTile extends ConsumerWidget {
  const GelbooruV2UploaderFileDetailTile({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final post = InheritedPost.of<GelbooruV2Post>(context);
    final uploaderName = post.uploaderName;

    return switch (uploaderName) {
      null => const SizedBox.shrink(),
      final name => UploaderFileDetailTile(
        uploaderName: name,
        onSearch: switch (ref.watch(gelbooruV2UploaderQueryProvider(post))) {
          final query? => () => goToSearchPage(
            ref,
            tag: query.resolveTag(),
          ),
          _ => null,
        },
      ),
    };
  }
}

class GelbooruV2RelatedPostsSection extends ConsumerWidget {
  const GelbooruV2RelatedPostsSection({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final post = InheritedPost.of<GelbooruV2Post>(context);

    return post.hasParent
        ? ref
              .watch(
                gelbooruV2ChildPostsProvider(
                  (ref.watchConfigFilter, ref.watchConfigSearch, post),
                ),
              )
              .maybeWhen(
                data: (data) => SliverRelatedPostsSection(
                  title: 'Child posts',
                  posts: data,
                  imageUrl: (post) => post.sampleImageUrl,
                  onViewAll: () => goToSearchPage(
                    ref,
                    tag: post.relationshipQuery,
                  ),
                  onTap: (index) => goToPostDetailsPageFromPosts(
                    ref: ref,
                    posts: data,
                    initialIndex: index,
                    initialThumbnailUrl: data[index].sampleImageUrl,
                  ),
                ),
                orElse: () => const SliverSizedBox.shrink(),
              )
        : const SliverSizedBox.shrink();
  }
}

class GelbooruV2UploaderPostsSection extends ConsumerWidget {
  const GelbooruV2UploaderPostsSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final post = InheritedPost.of<GelbooruV2Post>(context);

    return UploaderPostsSection<GelbooruV2Post>(
      query: ref.watch(
        gelbooruV2UploaderQueryProvider(post),
      ),
    );
  }
}

final kGelbooruV2PostDetailsUIBuilder = PostDetailsUIBuilder(
  preview: {
    DetailsPart.toolbar: (context) =>
        const DefaultInheritedPostActionToolbar<GelbooruV2Post>(),
  },
  full: {
    DetailsPart.toolbar: (context) =>
        const DefaultInheritedPostActionToolbar<GelbooruV2Post>(),
    DetailsPart.source: (context) =>
        const DefaultInheritedSourceSection<GelbooruV2Post>(),
    DetailsPart.tags: (context) =>
        const DefaultInheritedTagsTile<GelbooruV2Post>(),
    DetailsPart.fileDetails: (context) =>
        const DefaultInheritedFileDetailsSection<GelbooruV2Post>(
          uploader: GelbooruV2UploaderFileDetailTile(),
        ),
    DetailsPart.artistPosts: (context) =>
        const DefaultInheritedArtistPostsSection<GelbooruV2Post>(),
    DetailsPart.uploaderPosts: (context) =>
        const GelbooruV2UploaderPostsSection(),
    DetailsPart.relatedPosts: (context) =>
        const GelbooruV2RelatedPostsSection(),
    DetailsPart.characterList: (context) =>
        const DefaultInheritedCharacterPostsSection<GelbooruV2Post>(),
  },
);
