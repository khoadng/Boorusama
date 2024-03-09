// Flutter imports:
import 'package:flutter/material.dart' hide ThemeMode;

// Package imports:
import 'package:dynamic_color/dynamic_color.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import 'package:boorusama/boorus/danbooru/danbooru.dart';
import 'package:boorusama/boorus/danbooru/danbooru_provider.dart';
import 'package:boorusama/boorus/danbooru/feats/favorites/favorites.dart';
import 'package:boorusama/boorus/e621/e621.dart';
import 'package:boorusama/boorus/e621/feats/posts/posts.dart';
import 'package:boorusama/boorus/gelbooru/feats/posts/posts.dart';
import 'package:boorusama/boorus/gelbooru/gelbooru.dart';
import 'package:boorusama/boorus/gelbooru_v1/gelbooru_v1.dart';
import 'package:boorusama/boorus/moebooru/feats/autocomplete/moebooru_autocomplete_provider.dart';
import 'package:boorusama/boorus/moebooru/feats/posts/posts.dart';
import 'package:boorusama/boorus/moebooru/moebooru.dart';
import 'package:boorusama/boorus/providers.dart';
import 'package:boorusama/boorus/sankaku/sankaku.dart';
import 'package:boorusama/boorus/shimmie2/providers.dart';
import 'package:boorusama/boorus/zerochan/zerochan.dart';
import 'package:boorusama/clients/gelbooru/gelbooru_client.dart';
import 'package:boorusama/core/feats/autocompletes/autocompletes.dart';
import 'package:boorusama/core/feats/boorus/boorus.dart';
import 'package:boorusama/core/feats/downloads/downloads.dart';
import 'package:boorusama/core/feats/notes/notes.dart';
import 'package:boorusama/core/feats/posts/posts.dart';
import 'package:boorusama/core/feats/settings/settings.dart';
import 'package:boorusama/core/feats/tags/tags.dart';
import 'package:boorusama/core/pages/post_statistics_page.dart';
import 'package:boorusama/core/router.dart';
import 'package:boorusama/core/scaffolds/scaffolds.dart';
import 'package:boorusama/core/utils.dart';
import 'package:boorusama/core/widgets/widgets.dart';
import 'package:boorusama/foundation/gestures.dart';
import 'package:boorusama/foundation/theme/theme.dart';
import 'package:boorusama/functional.dart';
import 'package:boorusama/routes.dart';
import 'danbooru/feats/notes/notes.dart';
import 'danbooru/feats/posts/posts.dart';
import 'e621/feats/notes/notes.dart';
import 'philomena/philomena.dart';
import 'philomena/providers.dart';
import 'shimmie2/shimmie2.dart';
import 'szurubooru/providers.dart';
import 'szurubooru/szurubooru.dart';

typedef CreateConfigPageBuilder = Widget Function(
  BuildContext context,
  String url,
  BooruType booruType, {
  Color? backgroundColor,
});

typedef UpdateConfigPageBuilder = Widget Function(
  BuildContext context,
  BooruConfig config, {
  Color? backgroundColor,
});

typedef HomePageBuilder = Widget Function(
  BuildContext context,
  BooruConfig config,
);

typedef SearchPageBuilder = Widget Function(
  BuildContext context,
  String? initialQuery,
);

typedef PostDetailsPageBuilder = Widget Function(
  BuildContext context,
  BooruConfig config,
  DetailsPayload payload,
);

typedef FavoritesPageBuilder = Widget Function(
  BuildContext context,
  BooruConfig config,
);

typedef ArtistPageBuilder = Widget Function(
  BuildContext context,
  String artistName,
);

typedef CharacterPageBuilder = Widget Function(
  BuildContext context,
  String characterName,
);

typedef CommentPageBuilder = Widget Function(
  BuildContext context,
  bool useAppBar,
  int postId,
);

typedef PostFetcher = PostsOrError Function(
  int page,
  List<String> tags,
);

typedef AutocompleteFetcher = Future<List<AutocompleteData>> Function(
  String query,
);

typedef NoteFetcher = Future<List<Note>> Function(int postId);

typedef FavoriteAdder = Future<bool> Function(int postId, WidgetRef ref);
typedef FavoriteRemover = Future<bool> Function(int postId, WidgetRef ref);

typedef GranularRatingFilterer = bool Function(Post post, BooruConfig config);
typedef GranularRatingQueryBuilder = List<String> Function(
  List<String> currentQuery,
  BooruConfig config,
);

typedef GranularRatingOptionsBuilder = Set<Rating> Function();

typedef PostCountFetcher = Future<int?> Function(
  BooruConfig config,
  List<String> tags,
  GranularRatingQueryBuilder? granularRatingQueryBuilder,
);

typedef GridThumbnailUrlBuilder = String Function(
  Settings settings,
  Post post,
);

typedef TagColorBuilder = Color? Function(
  ThemeMode themeMode,
  String? tagType,
);

typedef PostImageDetailsUrlBuilder = String Function(
  Settings settings,
  Post post,
  BooruConfig config,
);

typedef PostStatisticsPageBuilder = Widget Function(
  BuildContext context,
  Iterable<Post> posts,
);

typedef PostGestureHandlerBuilder = bool Function(
  WidgetRef ref,
  String? action,
  Post post,
  DownloadDelegate downloader,
);

abstract class BooruBuilder {
  // UI Builders
  HomePageBuilder get homePageBuilder;
  CreateConfigPageBuilder get createConfigPageBuilder;
  UpdateConfigPageBuilder get updateConfigPageBuilder;
  SearchPageBuilder get searchPageBuilder;
  PostDetailsPageBuilder get postDetailsPageBuilder;
  FavoritesPageBuilder? get favoritesPageBuilder;
  ArtistPageBuilder? get artistPageBuilder;
  CharacterPageBuilder? get characterPageBuilder;
  CommentPageBuilder? get commentPageBuilder;

  GridThumbnailUrlBuilder get gridThumbnailUrlBuilder;

  TagColorBuilder get tagColorBuilder;

  DownloadFilenameGenerator get downloadFilenameBuilder;

  PostImageDetailsUrlBuilder get postImageDetailsUrlBuilder;

  PostStatisticsPageBuilder get postStatisticsPageBuilder;

  GranularRatingFilterer? get granularRatingFilterer;
  GranularRatingQueryBuilder? get granularRatingQueryBuilder;
  GranularRatingOptionsBuilder? get granularRatingOptionsBuilder;

  PostGestureHandlerBuilder get postGestureHandlerBuilder;

  // Data Builders
  PostFetcher get postFetcher;
  AutocompleteFetcher get autocompleteFetcher;
  NoteFetcher? get noteFetcher;

  // Action Builders
  FavoriteAdder? get favoriteAdder;
  FavoriteRemover? get favoriteRemover;

  PostCountFetcher? get postCountFetcher;
}

mixin FavoriteNotSupportedMixin implements BooruBuilder {
  @override
  FavoriteAdder? get favoriteAdder => null;
  @override
  FavoriteRemover? get favoriteRemover => null;

  @override
  FavoritesPageBuilder? get favoritesPageBuilder => null;
}

mixin ArtistNotSupportedMixin implements BooruBuilder {
  @override
  ArtistPageBuilder? get artistPageBuilder => null;
}

mixin CharacterNotSupportedMixin implements BooruBuilder {
  @override
  CharacterPageBuilder? get characterPageBuilder => null;
}

mixin CommentNotSupportedMixin implements BooruBuilder {
  @override
  CommentPageBuilder? get commentPageBuilder => null;
}

mixin PostCountNotSupportedMixin implements BooruBuilder {
  @override
  PostCountFetcher? get postCountFetcher => null;
}

mixin NoteNotSupportedMixin implements BooruBuilder {
  @override
  NoteFetcher? get noteFetcher => null;
}

mixin DefaultThumbnailUrlMixin implements BooruBuilder {
  @override
  GridThumbnailUrlBuilder get gridThumbnailUrlBuilder =>
      (settings, post) => switch (settings.imageQuality) {
            ImageQuality.automatic => post.thumbnailImageUrl,
            ImageQuality.low => post.thumbnailImageUrl,
            ImageQuality.high =>
              post.isVideo ? post.thumbnailImageUrl : post.sampleImageUrl,
            ImageQuality.highest =>
              post.isVideo ? post.thumbnailImageUrl : post.sampleImageUrl,
            ImageQuality.original =>
              post.isVideo ? post.thumbnailImageUrl : post.originalImageUrl
          };
}

mixin DefaultTagColorMixin implements BooruBuilder {
  @override
  TagColorBuilder get tagColorBuilder => (themeMode, tagType) {
        final colors =
            themeMode == ThemeMode.light ? TagColors.dark() : TagColors.light();

        return switch (tagType) {
          '0' || 'general' || 'tag' => colors.general,
          '1' || 'artist' => colors.artist,
          '3' || 'copyright' => colors.copyright,
          '4' || 'character' => colors.character,
          '5' || 'meta' || 'metadata' => colors.meta,
          _ => null,
        };
      };
}

mixin DefaultPostImageDetailsUrlMixin implements BooruBuilder {
  @override
  PostImageDetailsUrlBuilder get postImageDetailsUrlBuilder =>
      (settings, post, config) => post.isGif
          ? post.sampleImageUrl
          : config.imageDetaisQuality.toOption().fold(
              () => switch (settings.imageQuality) {
                    ImageQuality.low => post.thumbnailImageUrl,
                    ImageQuality.original => post.isVideo
                        ? post.videoThumbnailUrl
                        : post.originalImageUrl,
                    _ => post.isVideo
                        ? post.videoThumbnailUrl
                        : post.sampleImageUrl,
                  },
              (quality) => switch (stringToGeneralPostQualityType(quality)) {
                    GeneralPostQualityType.preview => post.thumbnailImageUrl,
                    GeneralPostQualityType.sample => post.isVideo
                        ? post.videoThumbnailUrl
                        : post.sampleImageUrl,
                    GeneralPostQualityType.original => post.isVideo
                        ? post.videoThumbnailUrl
                        : post.originalImageUrl,
                  });
}

mixin DefaultPostStatisticsPageBuilderMixin on BooruBuilder {
  @override
  PostStatisticsPageBuilder get postStatisticsPageBuilder =>
      (context, posts) => PostStatisticsPage(
            generalStats: () => posts.getStats(),
            totalPosts: () => posts.length,
          );
}

mixin DefaultGranularRatingFiltererMixin on BooruBuilder {
  @override
  GranularRatingFilterer? get granularRatingFilterer => null;
}

mixin DefaultPostGesturesHandlerMixin on BooruBuilder {
  @override
  PostGestureHandlerBuilder get postGestureHandlerBuilder =>
      (ref, action, post, downloader) => handleDefaultGestureAction(
            action,
            onDownload: () => downloader(post),
            onShare: () => ref.sharePost(
              post,
              context: ref.context,
              state: ref.read(postShareProvider(post)),
            ),
            onToggleBookmark: () => ref.toggleBookmark(post),
            onViewTags: () => goToShowTaglistPage(ref, post.extractTags()),
            onViewOriginal: () => goToOriginalImagePage(ref.context, post),
            onOpenSource: () => post.source.whenWeb(
              (source) => launchExternalUrlString(source.url),
              () => false,
            ),
          );
}

extension BooruBuilderGestures on BooruBuilder {
  bool canHandlePostGesture(
    GestureType gesture,
    GestureConfig? gestures,
  ) =>
      switch (gesture) {
        GestureType.swipeDown => gestures?.swipeDown != null,
        GestureType.swipeUp => gestures?.swipeUp != null,
        GestureType.swipeLeft => gestures?.swipeLeft != null,
        GestureType.swipeRight => gestures?.swipeRight != null,
        GestureType.doubleTap => gestures?.doubleTap != null,
        GestureType.longPress => gestures?.longPress != null,
        GestureType.tap => gestures?.tap != null,
      };
}

mixin LegacyGranularRatingOptionsBuilderMixin on BooruBuilder {
  @override
  GranularRatingOptionsBuilder? get granularRatingOptionsBuilder => () => {
        Rating.explicit,
        Rating.questionable,
        Rating.sensitive,
      };
}

mixin NewGranularRatingOptionsBuilderMixin on BooruBuilder {
  @override
  GranularRatingOptionsBuilder? get granularRatingOptionsBuilder => () => {
        Rating.explicit,
        Rating.questionable,
        Rating.sensitive,
        Rating.general,
      };
}

mixin NoGranularRatingQueryBuilderMixin on BooruBuilder {
  @override
  GranularRatingQueryBuilder? get granularRatingQueryBuilder => null;
}

mixin LegacyGranularRatingQueryBuilderMixin on BooruBuilder {
  @override
  GranularRatingQueryBuilder? get granularRatingQueryBuilder =>
      (currentQuery, config) => switch (config.ratingFilter) {
            BooruConfigRatingFilter.none => currentQuery,
            BooruConfigRatingFilter.hideNSFW => [
                ...currentQuery,
                'rating:safe',
              ],
            BooruConfigRatingFilter.hideExplicit => [
                ...currentQuery,
                '-rating:explicit',
              ],
            BooruConfigRatingFilter.custom =>
              config.granularRatingFiltersWithoutUnknown.toOption().fold(
                    () => currentQuery,
                    (ratings) => [
                      ...currentQuery,
                      ...ratings.map((e) => '-rating:${e.toFullString(
                            legacy: true,
                          )}'),
                    ],
                  ),
          };
}

mixin NewGranularRatingQueryBuilderMixin on BooruBuilder {
  @override
  GranularRatingQueryBuilder? get granularRatingQueryBuilder =>
      (currentQuery, config) => switch (config.ratingFilter) {
            BooruConfigRatingFilter.none => currentQuery,
            BooruConfigRatingFilter.hideNSFW => [
                ...currentQuery,
                'rating:g',
              ],
            BooruConfigRatingFilter.hideExplicit => [
                ...currentQuery,
                '-rating:e',
                '-rating:q',
              ],
            BooruConfigRatingFilter.custom =>
              config.granularRatingFiltersWithoutUnknown.toOption().fold(
                    () => currentQuery,
                    (ratings) => [
                      ...currentQuery,
                      ...ratings.map((e) => '-rating:${e.toShortString()}'),
                    ],
                  ),
          };
}

extension BooruBuilderWidgetRef on WidgetRef {
  Color? getTagColor(
    BuildContext context,
    String tagType, {
    ThemeMode? themeMode,
  }) {
    final tm = themeMode ?? context.themeMode;

    return getTagColorCore(
      tagType,
      primaryColor: context.colorScheme.primary,
      themeMode: tm,
      dynamicColor: watch(
          settingsProvider.select((value) => value.enableDynamicColoring)),
      color: watchBooruBuilder(watchConfig)?.tagColorBuilder(tm, tagType),
    );
  }
}

Color? getTagColorCore(
  String tagType, {
  required Color primaryColor,
  required ThemeMode themeMode,
  bool dynamicColor = false,
  required Color? color,
}) =>
    dynamicColor ? color?.harmonizeWith(primaryColor) : color;

final booruBuilderProvider = Provider<BooruBuilder?>((ref) {
  final config = ref.watchConfig;
  final booruBuilders = ref.watch(booruBuildersProvider);
  final booruBuilderFunc = booruBuilders[config.booruType];

  return booruBuilderFunc != null ? booruBuilderFunc(config) : null;
});

/// A provider that provides a map of [BooruType] to [BooruBuilder] functions
/// that can be used to build a Booru instances with the given [BooruConfig].
///
/// The [BooruType] enum represents different types of boorus that can be built.
/// The [BooruConfig] class represents the configuration for a booru instance.
///
/// Example usage:
/// ```
/// final booruBuildersProvider = Provider<Map<BooruType, BooruBuilder Function(BooruConfig config)>>((ref) =>
///   {
///     BooruType.zerochan: (config) => ZerochanBuilder(
///       postRepo: ref.watch(zerochanPostRepoProvider(config)),
///       autocompleteRepo: ref.watch(zerochanAutoCompleteRepoProvider(config)),
///     ),
///     // ...
///   }
/// );
/// ```
/// Note that the [BooruBuilder] functions are not called until they are used and they won't be called again
/// Each local instance of [BooruBuilder] will be cached and reused until the app is restarted.
final booruBuildersProvider =
    Provider<Map<BooruType, BooruBuilder Function(BooruConfig config)>>((ref) =>
        {
          BooruType.zerochan: (config) => ZerochanBuilder(
                postRepo: ref.read(zerochanPostRepoProvider(config)),
                autocompleteRepo:
                    ref.read(zerochanAutoCompleteRepoProvider(config)),
              ),
          BooruType.moebooru: (config) => MoebooruBuilder(
                postRepo: ref.read(moebooruPostRepoProvider(config)),
                autocompleteRepo:
                    ref.read(moebooruAutocompleteRepoProvider(config)),
              ),
          BooruType.gelbooru: (config) => GelbooruBuilder(
                postRepo: ref.read(gelbooruPostRepoProvider(config)),
                autocompleteRepo:
                    ref.read(gelbooruAutocompleteRepoProvider(config)),
                client: ref.read(gelbooruClientProvider(config)),
              ),
          BooruType.gelbooruV2: (config) => GelbooruBuilder(
                postRepo: ref.read(gelbooruPostRepoProvider(config)),
                autocompleteRepo:
                    ref.read(gelbooruAutocompleteRepoProvider(config)),
                client: ref.read(gelbooruClientProvider(config)),
                isV2: true,
              ),
          BooruType.e621: (config) => E621Builder(
                autocompleteRepo:
                    ref.read(e621AutocompleteRepoProvider(config)),
                postRepo: ref.read(e621PostRepoProvider(config)),
                noteRepo: ref.read(e621NoteRepoProvider(config)),
              ),
          BooruType.danbooru: (config) => DanbooruBuilder(
                postRepo: ref.read(danbooruPostRepoProvider(config)),
                autocompleteRepo:
                    ref.read(danbooruAutocompleteRepoProvider(config)),
                favoriteRepo: ref.read(danbooruFavoriteRepoProvider(config)),
                postCountRepo: ref.read(danbooruPostCountRepoProvider(config)),
                noteRepo: ref.read(danbooruNoteRepoProvider(config)),
              ),
          BooruType.gelbooruV1: (config) => GelbooruV1Builder(
                postRepo: ref.read(gelbooruV1PostRepoProvider(config)),
                client: GelbooruClient.gelbooru(),
              ),
          BooruType.sankaku: (config) => SankakuBuilder(
                postRepository: ref.read(sankakuPostRepoProvider(config)),
                autocompleteRepo:
                    ref.read(sankakuAutocompleteRepoProvider(config)),
              ),
          BooruType.philomena: (config) => PhilomenaBuilder(
                postRepo: ref.read(philomenaPostRepoProvider(config)),
                autocompleteRepo:
                    ref.read(philomenaAutoCompleteRepoProvider(config)),
              ),
          BooruType.shimmie2: (config) => Shimmie2Builder(
                postRepo: ref.read(shimmie2PostRepoProvider(config)),
                autocompleteRepo:
                    ref.read(shimmie2AutocompleteRepoProvider(config)),
              ),
          BooruType.szurubooru: (config) => SzurubooruBuilder(
                postRepo: ref.read(szurubooruPostRepoProvider(config)),
                autocompleteRepo:
                    ref.read(szurubooruAutocompleteRepoProvider(config)),
              ),
        });

extension BooruBuilderFeatureCheck on BooruBuilder {
  bool get isArtistSupported => artistPageBuilder != null;

  bool canFavorite(BooruConfig config) =>
      favoriteAdder != null &&
      favoriteRemover != null &&
      config.hasLoginDetails();
}

class BooruProvider extends ConsumerWidget {
  const BooruProvider({
    super.key,
    required this.builder,
  });

  final Widget Function(BooruBuilder? booruBuilderl, WidgetRef ref) builder;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final booruBuilder = ref.watch(booruBuilderProvider);

    return builder(booruBuilder, ref);
  }
}

mixin DefaultBooruUIMixin implements BooruBuilder {
  @override
  HomePageBuilder get homePageBuilder => (context, config) => HomePageScaffold(
        onPostTap:
            (context, posts, post, scrollController, settings, initialIndex) =>
                goToPostDetailsPage(
          context: context,
          posts: posts,
          initialIndex: initialIndex,
        ),
        onSearchTap: () => goToSearchPage(context),
      );

  @override
  SearchPageBuilder get searchPageBuilder =>
      (context, initialQuery) => BooruProvider(
            builder: (booruBuilder, _) => SearchPageScaffold(
              initialQuery: initialQuery,
              fetcher: (page, tags) =>
                  booruBuilder?.postFetcher.call(page, tags) ??
                  TaskEither.of(<Post>[]),
            ),
          );

  @override
  PostDetailsPageBuilder get postDetailsPageBuilder =>
      (context, config, payload) => BooruProvider(
            builder: (booruBuilder, ref) => PostDetailsPageScaffold(
              posts: payload.posts,
              initialIndex: payload.initialIndex,
              swipeImageUrlBuilder: defaultPostImageUrlBuilder(ref),
              onExit: (page) => payload.scrollController?.scrollToIndex(page),
              onTagTap: (tag) => goToSearchPage(context, tag: tag),
            ),
          );
}

String Function(
  Post post,
) defaultPostImageUrlBuilder(
  WidgetRef ref,
) =>
    (post) =>
        ref.watchBooruBuilder(ref.watchConfig)?.postImageDetailsUrlBuilder(
            ref.watch(settingsProvider), post, ref.watchConfig) ??
        post.sampleImageUrl;

Widget Function(
  BuildContext context,
  BoxConstraints constraints,
)? defaultImagePreviewButtonBuilder(
  WidgetRef ref,
  Post post,
) =>
    switch (ref.watchConfig.defaultPreviewImageButtonActionType) {
      ImageQuickActionType.bookmark => (context, _) =>
          BookmarkPostLikeButtonButton(
            post: post,
          ),
      ImageQuickActionType.download => (context, _) => DownloadPostButton(
            post: post,
            small: true,
          ),
      ImageQuickActionType.artist => (context, constraints) => Builder(
            builder: (context) {
              final artist =
                  post.artistTags != null && post.artistTags!.isNotEmpty
                      ? chooseArtistTag(post.artistTags!)
                      : null;
              if (artist == null) return const SizedBox.shrink();

              return SizedBox(
                width: constraints.maxWidth * 0.9,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Flexible(
                      child: PostTagListChip(
                        tag: Tag(
                          name: artist,
                          category: TagCategory.artist,
                          postCount: 0,
                        ),
                        onTap: () => goToArtistPage(
                          context,
                          artist,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
      ImageQuickActionType.none => (context, _) => const SizedBox.shrink(),
      ImageQuickActionType.defaultAction => null,
    };

extension BooruRef on Ref {
  BooruBuilder? readBooruBuilder(BooruConfig? config) {
    if (config == null) return null;

    final booruBuilders = read(booruBuildersProvider);
    final booruBuilderFunc = booruBuilders[config.booruType];

    return booruBuilderFunc != null ? booruBuilderFunc(config) : null;
  }

  BooruBuilder? readCurrentBooruBuilder() {
    final config = read(currentBooruConfigProvider);
    return readBooruBuilder(config);
  }
}

extension BooruWidgetRef on WidgetRef {
  BooruBuilder? readBooruBuilder(BooruConfig? config) {
    if (config == null) return null;

    final booruBuilders = read(booruBuildersProvider);
    final booruBuilderFunc = booruBuilders[config.booruType];

    return booruBuilderFunc != null ? booruBuilderFunc(config) : null;
  }

  BooruBuilder? watchBooruBuilder(BooruConfig? config) {
    if (config == null) return null;

    final booruBuilders = watch(booruBuildersProvider);
    final booruBuilderFunc = booruBuilders[config.booruType];

    return booruBuilderFunc != null ? booruBuilderFunc(config) : null;
  }
}
