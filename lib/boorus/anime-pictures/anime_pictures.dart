// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:booru_clients/anime_pictures.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:foundation/foundation.dart';
import 'package:foundation/widgets.dart';

// Project imports:
import '../../core/autocompletes/autocompletes.dart';
import '../../core/boorus/booru/booru.dart';
import '../../core/boorus/engine/engine.dart';
import '../../core/configs/config/types.dart';
import '../../core/configs/create/create.dart';
import '../../core/configs/create/widgets.dart';
import '../../core/configs/manage/widgets.dart';
import '../../core/configs/ref.dart';
import '../../core/downloads/filename.dart';
import '../../core/downloads/urls.dart';
import '../../core/foundation/caching.dart';
import '../../core/http/http.dart';
import '../../core/http/providers.dart';
import '../../core/posts/details/details.dart';
import '../../core/posts/details/routes.dart';
import '../../core/posts/details/widgets.dart';
import '../../core/posts/details_manager/types.dart';
import '../../core/posts/details_parts/widgets.dart';
import '../../core/posts/post/post.dart';
import '../../core/posts/post/providers.dart';
import '../../core/scaffolds/scaffolds.dart';
import '../../core/tags/tag/tag.dart';
import '../danbooru/danbooru.dart';
import '../gelbooru_v2/gelbooru_v2.dart';
import 'anime_pictures_home_page.dart';
import 'create_anime_pictures_config_page.dart';
import 'providers.dart';

class AnimePicturesBuilder
    with
        FavoriteNotSupportedMixin,
        CommentNotSupportedMixin,
        ArtistNotSupportedMixin,
        CharacterNotSupportedMixin,
        LegacyGranularRatingOptionsBuilderMixin,
        UnknownMetatagsMixin,
        DefaultTagSuggestionsItemBuilderMixin,
        DefaultMultiSelectionActionsBuilderMixin,
        DefaultHomeMixin,
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
  PostDetailsPageBuilder get postDetailsPageBuilder => (context, payload) {
        final posts = payload.posts.map((e) => e as AnimePicturesPost).toList();

        return PostDetailsScope(
          initialIndex: payload.initialIndex,
          initialThumbnailUrl: payload.initialThumbnailUrl,
          posts: posts,
          scrollController: payload.scrollController,
          dislclaimer: payload.dislclaimer,
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

class AnimePicturesRepository extends BooruRepositoryDefault {
  const AnimePicturesRepository({required this.ref});

  @override
  final Ref ref;

  @override
  PostRepository<Post> post(BooruConfigSearch config) {
    return ref.read(animePicturesPostRepoProvider(config));
  }

  @override
  AutocompleteRepository autocomplete(BooruConfigAuth config) {
    return ref.read(animePicturesAutocompleteRepoProvider(config));
  }

  @override
  DownloadFileUrlExtractor downloadFileUrlExtractor(BooruConfigAuth config) {
    return ref.read(animePicturesDownloadFileUrlExtractorProvider(config));
  }

  @override
  DownloadFilenameGenerator downloadFilenameBuilder(BooruConfigAuth config) {
    final client = ref.watch(animePicturesClientProvider(config));

    return DownloadFileNameBuilder<Post>(
      defaultFileNameFormat: kGelbooruV2CustomDownloadFileNameFormat,
      defaultBulkDownloadFileNameFormat:
          kGelbooruV2CustomDownloadFileNameFormat,
      sampleData: kDanbooruPostSamples,
      hasRating: false,
      extensionHandler: (post, config) =>
          post.format.startsWith('.') ? post.format.substring(1) : post.format,
      tokenHandlers: [
        WidthTokenHandler(),
        HeightTokenHandler(),
        AspectRatioTokenHandler(),
      ],
      asyncTokenHandlers: [
        AsyncTokenHandler(
          ClassicTagsTokenResolver(
            tagFetcher: (post) async {
              final details = await client.getPostDetails(id: post.id);

              return details.tags
                      ?.where((e) => e.tag != null)
                      .map((e) => e.tag!)
                      .map(
                        (tag) => (
                          name: tag.tag ?? '???',
                          type:
                              animePicturesTagTypeToTagCategory(tag.type).name,
                        ),
                      )
                      .toList() ??
                  [];
            },
          ),
        ),
      ],
    );
  }

  @override
  BooruSiteValidator? siteValidator(BooruConfigAuth config) {
    final dio = ref.watch(dioProvider(config));

    return () => AnimePicturesClient(
          baseUrl: config.url,
          dio: dio,
        ).getPosts().then((value) => true);
  }

  @override
  PostLinkGenerator postLinkGenerator(BooruConfigAuth config) {
    return PluralPostLinkGenerator(baseUrl: config.url);
  }
}

class AnimePicturesCurrentUserIdScope extends ConsumerWidget {
  const AnimePicturesCurrentUserIdScope({
    required this.child,
    super.key,
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
    required String quality,
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
    staleDuration: const Duration(minutes: 5),
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
                .map(
                  (e) => Tag(
                    name: e.tag ?? '???',
                    category: animePicturesTagTypeToTagCategory(e.type),
                    postCount: e.num ?? 0,
                  ),
                )
                .toList() ??
            [],
      ),
  ]..sort((a, b) => a.order.compareTo(b.order));

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
    final configAuth = ref.watchConfigAuth;
    final configViewer = ref.watchConfigViewer;

    return ref.watch(postDetailsProvider(post.id)).when(
          data: (details) => details.tied != null && details.tied!.isNotEmpty
              ? SliverRelatedPostsSection(
                  posts: details.tied!.map(dtoToAnimePicturesPost).toList(),
                  imageUrl:
                      defaultPostImageUrlBuilder(ref, configAuth, configViewer),
                  onTap: (index) => goToPostDetailsPageFromPosts(
                    context: context,
                    posts: posts,
                    initialIndex: index,
                    initialThumbnailUrl: defaultPostImageUrlBuilder(
                      ref,
                      configAuth,
                      configViewer,
                    )(posts[index]),
                  ),
                )
              : const SliverSizedBox.shrink(),
          error: (e, _) => const SliverSizedBox.shrink(),
          loading: () => const SliverSizedBox.shrink(),
        );
  }
}

BooruComponents createAnimePictures() => BooruComponents(
      parser: AnimePicturesParser(),
      createBuilder: AnimePicturesBuilder.new,
      createRepository: (ref) => AnimePicturesRepository(ref: ref),
    );

class AnimePictures extends Booru with PassHashAuthMixin {
  const AnimePictures({
    required super.name,
    required super.protocol,
    required this.sites,
    required this.loginUrl,
  });

  @override
  final List<String> sites;

  @override
  final String? loginUrl;

  @override
  BooruType get type => BooruType.animePictures;

  @override
  String? getLoginUrl() => loginUrl;
}

class AnimePicturesParser extends BooruParser {
  @override
  BooruType get booruType => BooruType.animePictures;

  @override
  Booru parse(String name, dynamic data) {
    return AnimePictures(
      name: name,
      protocol: parseProtocol(data['protocol']),
      sites: List.from(data['sites']),
      loginUrl: data['login-url'],
    );
  }
}
