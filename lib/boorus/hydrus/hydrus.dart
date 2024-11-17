// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:collection/collection.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_symbols_icons/symbols.dart';

// Project imports:
import 'package:boorusama/boorus/booru_builder.dart';
import 'package:boorusama/boorus/danbooru/danbooru.dart';
import 'package:boorusama/boorus/gelbooru_v2/gelbooru_v2.dart';
import 'package:boorusama/boorus/providers.dart';
import 'package:boorusama/clients/hydrus/hydrus_client.dart';
import 'package:boorusama/clients/hydrus/types/types.dart';
import 'package:boorusama/core/autocompletes/autocompletes.dart';
import 'package:boorusama/core/configs/configs.dart';
import 'package:boorusama/core/configs/create/create.dart';
import 'package:boorusama/core/downloads/download_file_name_generator.dart';
import 'package:boorusama/core/home/home.dart';
import 'package:boorusama/core/posts/posts.dart';
import 'package:boorusama/core/scaffolds/scaffolds.dart';
import 'package:boorusama/core/tags/tags.dart';
import 'package:boorusama/core/widgets/widgets.dart';
import 'package:boorusama/foundation/i18n.dart';
import 'package:boorusama/foundation/networking/networking.dart';
import 'package:boorusama/router.dart';
import 'package:boorusama/widgets/widgets.dart';
import 'favorites/favorites.dart';

class HydrusPost extends SimplePost {
  HydrusPost({
    required super.id,
    required super.thumbnailImageUrl,
    required super.sampleImageUrl,
    required super.originalImageUrl,
    required super.tags,
    required super.rating,
    required super.hasComment,
    required super.isTranslated,
    required super.hasParentOrChildren,
    required super.source,
    required super.score,
    required super.duration,
    required super.fileSize,
    required super.format,
    required super.hasSound,
    required super.height,
    required super.md5,
    required super.videoThumbnailUrl,
    required super.videoUrl,
    required super.width,
    required super.uploaderId,
    required super.createdAt,
    required super.uploaderName,
    required super.metadata,
    required this.ownFavorite,
  });

  @override
  String getLink(String baseUrl) {
    return '';
  }

  final bool? ownFavorite;
}

final hydrusClientProvider =
    Provider.family<HydrusClient, BooruConfig>((ref, config) {
  final dio = newDio(ref.watch(dioArgsProvider(config)));

  return HydrusClient(
    dio: dio,
    baseUrl: config.url,
    apiKey: config.apiKey ?? '',
  );
});

final hydrusPostRepoProvider = Provider.family<PostRepository, BooruConfig>(
  (ref, config) {
    final client = ref.watch(hydrusClientProvider(config));
    final composer = ref.watch(tagQueryComposerProvider(config));

    Future<PostResult<HydrusPost>> getPosts(
      List<String> tags,
      int page, {
      int? limit,
    }) async {
      final files = await client.getFiles(
        tags: tags,
        page: page,
        limit: limit,
      );

      final data = files.files
          .map((e) => HydrusPost(
                id: e.fileId ?? 0,
                thumbnailImageUrl: e.thumbnailUrl,
                sampleImageUrl: e.imageUrl,
                originalImageUrl: e.imageUrl,
                tags: e.allTags,
                rating: Rating.general,
                hasComment: false,
                isTranslated: false,
                hasParentOrChildren: false,
                source: PostSource.from(e.firstSource),
                score: 0,
                duration: e.duration?.toDouble() ?? 0,
                fileSize: e.size ?? 0,
                format: e.ext ?? '',
                hasSound: e.hasAudio,
                height: e.height?.toDouble() ?? 0,
                md5: e.hash ?? '',
                videoThumbnailUrl: e.thumbnailUrl,
                videoUrl: e.imageUrl,
                width: e.width?.toDouble() ?? 0,
                uploaderId: null,
                uploaderName: null,
                createdAt: null,
                metadata: PostMetadata(
                  page: page,
                  search: tags.join(' '),
                ),
                ownFavorite: e.faved,
              ))
          .toList()
          .toResult(
            total: files.count,
          );

      ref.read(hydrusFavoritesProvider(config).notifier).preload(data.posts);

      return data;
    }

    return PostRepositoryBuilder(
      tagComposer: composer,
      getSettings: () async => ref.read(imageListingSettingsProvider),
      fetchFromController: (controller, page, {limit}) {
        final tags = controller.tags.map((e) => e.originalTag).toList();

        return getPosts(
          composer.compose(tags),
          page,
          limit: limit,
        );
      },
      fetch: getPosts,
    );
  },
);

final hydrusAutocompleteRepoProvider =
    Provider.family<AutocompleteRepository, BooruConfig>((ref, config) {
  final client = ref.watch(hydrusClientProvider(config));

  return AutocompleteRepositoryBuilder(
    persistentStorageKey:
        '${Uri.encodeComponent(config.url)}_autocomplete_cache_v1',
    persistentStaleDuration: const Duration(minutes: 5),
    autocomplete: (query) async {
      final dtos = await client.getAutocomplete(query: query);

      return dtos.map((e) {
        // looking for xxx:tag format using regex
        final category = RegExp(r'(\w+):').firstMatch(e.value)?.group(1);

        return AutocompleteData(
          label: e.value,
          value: e.value,
          category: category,
          postCount: e.count,
        );
      }).toList();
    },
  );
});

class HydrusBuilder
    with
        PostCountNotSupportedMixin,
        ArtistNotSupportedMixin,
        CharacterNotSupportedMixin,
        DefaultThumbnailUrlMixin,
        CommentNotSupportedMixin,
        LegacyGranularRatingOptionsBuilderMixin,
        UnknownMetatagsMixin,
        DefaultMultiSelectionActionsBuilderMixin,
        DefaultHomeMixin,
        DefaultTagColorMixin,
        DefaultPostGesturesHandlerMixin,
        DefaultGranularRatingFiltererMixin,
        DefaultPostStatisticsPageBuilderMixin,
        DefaultBooruUIMixin
    implements BooruBuilder {
  HydrusBuilder();

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
            child: CreateHydrusConfigPage(
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
            child: CreateHydrusConfigPage(
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
    tokenHandlers: {
      'width': (post, config) => post.width.toString(),
      'height': (post, config) => post.height.toString(),
    },
  );

  @override
  PostImageDetailsUrlBuilder get postImageDetailsUrlBuilder =>
      (imageQuality, rawPost, config) => rawPost.sampleImageUrl;

  @override
  PostDetailsPageBuilder get postDetailsPageBuilder =>
      (context, config, payload) {
        final posts = payload.posts.map((e) => e as HydrusPost).toList();

        return PostDetailsLayoutSwitcher(
          initialIndex: payload.initialIndex,
          posts: posts,
          scrollController: payload.scrollController,
          desktop: () => const HydrusPostDetailsDesktopPage(),
          mobile: () => const HydrusPostDetailsPage(),
        );
      };

  @override
  FavoritesPageBuilder? get favoritesPageBuilder =>
      (context, config) => const HydrusFavoritesPage();

  @override
  FavoriteAdder? get favoriteAdder => (postId, ref) => ref
      .read(hydrusFavoritesProvider(ref.readConfig).notifier)
      .add(postId)
      .then((value) => true);

  @override
  FavoriteRemover? get favoriteRemover => (postId, ref) => ref
      .read(hydrusFavoritesProvider(ref.readConfig).notifier)
      .remove(postId)
      .then((value) => true);

  @override
  HomePageBuilder get homePageBuilder => (context, config) => HydrusHomePage(
        config: config,
      );

  @override
  SearchPageBuilder get searchPageBuilder =>
      (context, initialQuery) => HydrusSearchPage(
            initialQuery: initialQuery,
          );

  @override
  QuickFavoriteButtonBuilder? get quickFavoriteButtonBuilder =>
      (context, post) => HydrusQuickFavoriteButton(
            post: post,
          );

  @override
  final PostDetailsUIBuilder postDetailsUIBuilder = PostDetailsUIBuilder(
    toolbarBuilder: (context) => const HydrusPostActionToolbar(),
  );
}

class HydrusHomePage extends StatelessWidget {
  const HydrusHomePage({
    super.key,
    required this.config,
  });

  final BooruConfig config;

  @override
  Widget build(BuildContext context) {
    return HomePageScaffold(
      mobileMenu: [
        SideMenuTile(
          icon: const Icon(Symbols.favorite),
          title: Text('profile.favorites'.tr()),
          onTap: () => goToFavoritesPage(context),
        ),
      ],
      desktopMenuBuilder: (context, controller, constraints) => [
        HomeNavigationTile(
          value: 1,
          controller: controller,
          constraints: constraints,
          selectedIcon: Symbols.favorite,
          icon: Symbols.favorite,
          title: 'Favorites',
        ),
      ],
      desktopViews: const [
        HydrusFavoritesPage(),
      ],
    );
  }
}

final ratingServiceNameProvider =
    FutureProvider.family<String?, BooruConfig>((ref, config) async {
  final client = ref.read(hydrusClientProvider(config));

  final services = await client.getServicesCached();

  final key = getLikeDislikeRatingKey(services);

  if (key == null) {
    return null;
  }

  return services.firstWhereOrNull((e) => e.key == key)?.name;
});

class HydrusPostDetailsPage extends ConsumerWidget {
  const HydrusPostDetailsPage({
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final data = PostDetails.of<HydrusPost>(context);
    final posts = data.posts;
    final controller = data.controller;

    return PostDetailsPageScaffold(
      controller: controller,
      posts: posts,
      fileDetailsBuilder: (context, post) => DefaultFileDetailsSection(
        post: post,
        initialExpanded: true,
      ),
      tagListBuilder: (context, post) => BasicTagList(
        tags: post.tags.toList(),
        onTap: (tag) => goToSearchPage(
          context,
          tag: tag,
        ),
        unknownCategoryColor: ref.watch(tagColorProvider('general')),
      ),
    );
  }
}

class HydrusPostDetailsDesktopPage extends ConsumerWidget {
  const HydrusPostDetailsDesktopPage({
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final data = PostDetails.of<HydrusPost>(context);
    final posts = data.posts;
    final controller = data.controller;

    return PostDetailsPageDesktopScaffold(
      controller: controller,
      debounceDuration: Duration.zero,
      posts: posts,
      imageUrlBuilder: defaultPostImageUrlBuilder(ref),
      fileDetailsBuilder: (context, post) => DefaultFileDetailsSection(
        post: post,
        initialExpanded: true,
      ),
      tagListBuilder: (context, post) => BasicTagList(
        tags: post.tags.toList(),
        onTap: (tag) => goToSearchPage(
          context,
          tag: tag,
        ),
        unknownCategoryColor: ref.watch(tagColorProvider('general')),
      ),
      topRightButtonsBuilder: (currentPage, expanded, post) =>
          GeneralMoreActionButton(post: post),
    );
  }
}

class CreateHydrusConfigPage extends ConsumerWidget {
  const CreateHydrusConfigPage({
    super.key,
    this.backgroundColor,
    this.initialTab,
  });

  final Color? backgroundColor;
  final String? initialTab;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return CreateBooruConfigScaffold(
      authTab: const HydrusAuthConfigView(),
      backgroundColor: backgroundColor,
      initialTab: initialTab,
      canSubmit: apiKeyRequired,
    );
  }
}

class HydrusAuthConfigView extends ConsumerWidget {
  const HydrusAuthConfigView({
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const SizedBox(height: 24),
          const DefaultBooruApiKeyField(
            labelText: 'API access key',
          ),
          const SizedBox(height: 8),
          WarningContainer(
            title: 'Warning',
            contentBuilder: (context) => const Text(
              "It is recommended to not make any changes to Hydrus's services while using the app, you might see unexpected behavior.",
            ),
          ),
        ],
      ),
    );
  }
}

class HydrusPostActionToolbar extends ConsumerWidget {
  const HydrusPostActionToolbar({
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final post = InheritedPost.of<HydrusPost>(context);
    final canFav =
        ref.watch(hydrusCanFavoriteProvider(ref.watchConfig)).maybeWhen(
              data: (fav) => fav,
              orElse: () => false,
            );

    return PostActionToolbar(
      children: [
        if (canFav) HydrusFavoritePostButton(post: post),
        BookmarkPostButton(post: post),
        DownloadPostButton(post: post),
      ],
    );
  }
}

class HydrusSearchPage extends ConsumerWidget {
  const HydrusSearchPage({
    super.key,
    this.initialQuery,
  });

  final String? initialQuery;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final config = ref.watchConfig;
    return SearchPageScaffold(
      initialQuery: initialQuery,
      fetcher: (page, controller) => ref
          .read(hydrusPostRepoProvider(config))
          .getPostsFromController(controller, page),
    );
  }
}
