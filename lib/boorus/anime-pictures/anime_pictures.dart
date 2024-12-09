// Flutter imports:

// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:booru_clients/anime_pictures.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:foundation/foundation.dart';
import 'package:foundation/widgets.dart';

// Project imports:
import 'package:boorusama/boorus/anime-pictures/anime_pictures_home_page.dart';
import 'package:boorusama/boorus/booru_builder.dart';
import 'package:boorusama/boorus/booru_builder_types.dart';
import 'package:boorusama/boorus/danbooru/danbooru.dart';
import 'package:boorusama/boorus/gelbooru_v2/gelbooru_v2.dart';
import 'package:boorusama/core/configs/config.dart';
import 'package:boorusama/core/configs/create.dart';
import 'package:boorusama/core/configs/manage.dart';
import 'package:boorusama/core/configs/ref.dart';
import 'package:boorusama/core/downloads/filename.dart';
import 'package:boorusama/core/downloads/urls.dart';
import 'package:boorusama/core/posts/details/details.dart';
import 'package:boorusama/core/posts/details/parts.dart';
import 'package:boorusama/core/posts/details/widgets.dart';
import 'package:boorusama/core/posts/post/post.dart';
import 'package:boorusama/core/scaffolds/scaffolds.dart';
import 'package:boorusama/core/settings/types.dart';
import 'package:boorusama/core/tags/tag/tag.dart';
import 'package:boorusama/foundation/caching.dart';
import 'package:boorusama/router.dart';
import '../booru_builder_default.dart';
import 'create_anime_pictures_config_page.dart';
import 'providers.dart';

class AnimePicturesBuilder
    with
        FavoriteNotSupportedMixin,
        DefaultThumbnailUrlMixin,
        CommentNotSupportedMixin,
        ArtistNotSupportedMixin,
        CharacterNotSupportedMixin,
        LegacyGranularRatingOptionsBuilderMixin,
        UnknownMetatagsMixin,
        DefaultMultiSelectionActionsBuilderMixin,
        DefaultHomeMixin,
        DefaultTagColorMixin,
        DefaultPostGesturesHandlerMixin,
        DefaultPostImageDetailsUrlMixin,
        DefaultGranularRatingFiltererMixin,
        DefaultPostStatisticsPageBuilderMixin,
        DefaultBooruUIMixin
    implements BooruBuilder {
  AnimePicturesBuilder();

  @override
  CreateConfigPageBuilder get createConfigPageBuilder => (
        context,
        id, {
        backgroundColor,
      }) =>
          CreateBooruConfigScope(
            id: id,
            config: BooruConfig.defaultConfig(
              booruType: id.booruType,
              url: id.url,
              customDownloadFileNameFormat: null,
            ),
            child: CreateAnimePicturesConfigPage(
              backgroundColor: backgroundColor,
            ),
          );

  @override
  UpdateConfigPageBuilder get updateConfigPageBuilder => (
        context,
        id, {
        backgroundColor,
        initialTab,
      }) =>
          UpdateBooruConfigScope(
            id: id,
            child: CreateAnimePicturesConfigPage(
              backgroundColor: backgroundColor,
              initialTab: initialTab,
            ),
          );

  @override
  final DownloadFilenameGenerator<Post> downloadFilenameBuilder =
      DownloadFileNameBuilder<Post>(
    defaultFileNameFormat: kGelbooruV2CustomDownloadFileNameFormat,
    defaultBulkDownloadFileNameFormat: kGelbooruV2CustomDownloadFileNameFormat,
    sampleData: kDanbooruPostSamples,
    hasRating: false,
    extensionHandler: (post, config) =>
        post.format.startsWith('.') ? post.format.substring(1) : post.format,
    tokenHandlers: {
      'width': (post, config) => post.width.toString(),
      'height': (post, config) => post.height.toString(),
    },
  );

  @override
  PostDetailsPageBuilder get postDetailsPageBuilder => (context, payload) {
        final posts = payload.posts.map((e) => e as AnimePicturesPost).toList();

        return PostDetailsScope(
          initialIndex: payload.initialIndex,
          posts: posts,
          scrollController: payload.scrollController,
          child: const DefaultPostDetailsPage<AnimePicturesPost>(),
        );
      };

  @override
  HomePageBuilder get homePageBuilder =>
      (context) => const AnimePicturesHomePage();

  @override
  FavoritesPageBuilder? get favoritesPageBuilder =>
      (context) => const AnimePicturesCurrentUserIdScope(
            child: AnimePicturesFavoritesPage(),
          );

  @override
  final PostDetailsUIBuilder postDetailsUIBuilder = PostDetailsUIBuilder(
    preview: {
      DetailsPart.toolbar: (context) =>
          const DefaultInheritedPostActionToolbar<AnimePicturesPost>(),
    },
    full: {
      DetailsPart.toolbar: (context) =>
          const DefaultInheritedPostActionToolbar<AnimePicturesPost>(),
      DetailsPart.tags: (context) => const AnimePicturesTagListSection(),
      DetailsPart.fileDetails: (context) =>
          const DefaultInheritedFileDetailsSection<AnimePicturesPost>(),
      DetailsPart.relatedPosts: (context) =>
          const AnimePicturesRelatedPostsSection(),
    },
  );
}

class AnimePicturesCurrentUserIdScope extends ConsumerWidget {
  const AnimePicturesCurrentUserIdScope({
    super.key,
    required this.child,
  });

  final Widget child;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ref
        .watch(animePicturesCurrentUserIdProvider(ref.watchConfigAuth))
        .when(
          data: (value) => value != null
              ? ProviderScope(
                  overrides: [
                    _uidProvider.overrideWithValue(value),
                  ],
                  child: child,
                )
              : _buildInvalidPage(),
          loading: () => Scaffold(
            appBar: AppBar(),
            body: const Center(
              child: CircularProgressIndicator(),
            ),
          ),
          error: (e, _) => _buildInvalidPage(),
        );
  }

  Widget _buildInvalidPage() {
    return const Scaffold(
      body: Center(
        child: Text('You need to provide login details to use this feature.'),
      ),
    );
  }
}

final _uidProvider = Provider.autoDispose<int>((ref) {
  throw UnimplementedError();
});

class AnimePicturesFavoritesPage extends ConsumerWidget {
  const AnimePicturesFavoritesPage({
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final uid = ref.watch(_uidProvider);
    final config = ref.watchConfigAuth;

    return FavoritesPageScaffold(
      favQueryBuilder: null,
      fetcher: (page) => TaskEither.Do(($) async {
        final posts = await ref
            .read(animePicturesClientProvider(config))
            .getPosts(starsBy: uid, page: page)
            .then((values) => values.map(dtoToAnimePicturesPost).toList());

        return posts.toResult();
      }),
    );
  }
}

class AnimePicturesDownloadFileUrlExtractor
    with SimpleCacheMixin<DownloadUrlData>
    implements DownloadFileUrlExtractor {
  AnimePicturesDownloadFileUrlExtractor({
    required this.client,
  });

  final AnimePicturesClient client;

  @override
  Future<DownloadUrlData?> getDownloadFileUrl({
    required Post post,
    required DownloadQuality quality,
  }) =>
      tryGet(
        post.id.toString(),
        orElse: () async {
          final data = await client.getDownloadUrl(post.id);

          if (data == null) {
            return null;
          }

          return DownloadUrlData(
            url: data.url,
            cookie: data.cookie,
          );
        },
      );

  @override
  final Cache<DownloadUrlData> cache = Cache(
    maxCapacity: 10,
    staleDuration: Duration(minutes: 5),
  );
}

final postDetailsProvider =
    FutureProvider.autoDispose.family<PostDetailsDto, int>((ref, id) async {
  final config = ref.watchConfigAuth;
  final client = ref.watch(animePicturesClientProvider(config));

  final post = await client.getPostDetails(id: id);

  return post;
});

final postTagsProvider =
    FutureProvider.autoDispose.family<List<TagGroupItem>, int>((ref, id) async {
  final postDetails = await ref.watch(postDetailsProvider(id).future);

  final tagGroups = <TagGroupItem>[
    for (final c in AnimePicturesTagType.values)
      TagGroupItem(
        category: animePicturesTagTypeToTagCategory(c).id,
        groupName: _mapToGroupName(c),
        order: _mapToOrder(c),
        tags: postDetails.tags
                ?.where((e) => e.tag?.type == c)
                .nonNulls
                .map((e) => e.tag!)
                .map((e) => Tag(
                      name: e.tag ?? '???',
                      category: animePicturesTagTypeToTagCategory(e.type),
                      postCount: e.num ?? 0,
                    ))
                .toList() ??
            [],
      ),
  ];

  tagGroups.sort((a, b) => a.order.compareTo(b.order));

  final filtered = tagGroups.where((e) => e.tags.isNotEmpty).toList();

  return filtered;
});

int _mapToOrder(AnimePicturesTagType type) => switch (type) {
      AnimePicturesTagType.copyrightProduct => 0,
      AnimePicturesTagType.copyrightGame => 1,
      AnimePicturesTagType.copyrightOther => 2,
      AnimePicturesTagType.character => 3,
      AnimePicturesTagType.author => 4,
      AnimePicturesTagType.reference => 5,
      AnimePicturesTagType.object => 6,
      AnimePicturesTagType.unknown => 7,
    };

String _mapToGroupName(AnimePicturesTagType type) => switch (type) {
      AnimePicturesTagType.character => 'Character',
      AnimePicturesTagType.reference => 'Reference',
      AnimePicturesTagType.author => 'Author',
      AnimePicturesTagType.object => 'Object',
      AnimePicturesTagType.unknown => 'Unknown',
      AnimePicturesTagType.copyrightProduct => 'Copyright (Product)',
      AnimePicturesTagType.copyrightGame => 'Game Copyright',
      AnimePicturesTagType.copyrightOther => 'Other Copyright',
    };

class AnimePicturesTagListSection extends ConsumerWidget {
  const AnimePicturesTagListSection({
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final post = InheritedPost.of<AnimePicturesPost>(context);

    return SliverToBoxAdapter(
      child: ref.watch(postTagsProvider(post.id)).when(
            data: (tags) => TagsTile(
              initialExpanded: true,
              initialCount: post.tagsCount,
              post: post,
              tags: tags,
            ),
            loading: () => TagsTile(
              initialExpanded: true,
              initialCount: post.tagsCount,
              post: post,
              tags: null,
            ),
            error: (e, _) => Text('Error: $e'),
          ),
    );
  }
}

class AnimePicturesRelatedPostsSection extends ConsumerWidget {
  const AnimePicturesRelatedPostsSection({
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final posts = PostDetails.of<AnimePicturesPost>(context).posts;
    final post = InheritedPost.of<AnimePicturesPost>(context);

    return ref.watch(postDetailsProvider(post.id)).when(
          data: (details) => details.tied != null && details.tied!.isNotEmpty
              ? SliverRelatedPostsSection(
                  posts: details.tied!.map(dtoToAnimePicturesPost).toList(),
                  imageUrl: defaultPostImageUrlBuilder(ref),
                  onTap: (index) => goToPostDetailsPageFromPosts(
                    context: context,
                    posts: posts,
                    initialIndex: index,
                  ),
                )
              : const SliverSizedBox.shrink(),
          error: (e, _) => const SliverSizedBox.shrink(),
          loading: () => const SliverSizedBox.shrink(),
        );
  }
}
