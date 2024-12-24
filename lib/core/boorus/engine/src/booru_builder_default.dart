// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:foundation/foundation.dart';

// Project imports:
import '../../../configs/config.dart';
import '../../../configs/ref.dart';
import '../../../downloads/downloader.dart';
import '../../../foundation/display.dart';
import '../../../foundation/url_launcher.dart';
import '../../../home/custom_home.dart';
import '../../../home/home_page_scaffold.dart';
import '../../../home/user_custom_home_builder.dart';
import '../../../posts/details/details.dart';
import '../../../posts/details/widgets.dart';
import '../../../posts/details_parts/widgets.dart';
import '../../../posts/favorites/widgets.dart';
import '../../../posts/listing/widgets.dart';
import '../../../posts/post/post.dart';
import '../../../posts/post/providers.dart';
import '../../../posts/post/routes.dart';
import '../../../posts/post/tags.dart';
import '../../../posts/rating/rating.dart';
import '../../../posts/shares/providers.dart';
import '../../../posts/shares/widgets.dart';
import '../../../posts/sources/source.dart';
import '../../../posts/statistics/stats.dart';
import '../../../posts/statistics/widgets.dart';
import '../../../router.dart';
import '../../../scaffolds/scaffolds.dart';
import '../../../search/search/routes.dart';
import '../../../search/search/widgets.dart';
import '../../../search/suggestions/widgets.dart';
import '../../../settings/providers.dart';
import '../../../settings/settings.dart';
import '../../../tags/categories/tag_category.dart';
import '../../../tags/tag/colors.dart';
import '../../../tags/tag/routes.dart';
import '../../../tags/tag/tag.dart';
import '../../../tags/tag/widgets.dart';
import '../../../theme.dart';
import '../providers.dart';
import 'booru_builder.dart';
import 'booru_builder_types.dart';

mixin FavoriteNotSupportedMixin implements BooruBuilder {
  @override
  FavoritesPageBuilder? get favoritesPageBuilder => null;
  @override
  QuickFavoriteButtonBuilder? get quickFavoriteButtonBuilder => null;
}

mixin DefaultQuickFavoriteButtonBuilderMixin implements BooruBuilder {
  @override
  QuickFavoriteButtonBuilder get quickFavoriteButtonBuilder =>
      (context, post) => DefaultQuickFavoriteButton(
            post: post,
          );
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

mixin DefaultThumbnailUrlMixin implements BooruBuilder {
  @override
  GridThumbnailUrlBuilder get gridThumbnailUrlBuilder =>
      (imageQuality, post) => switch (imageQuality) {
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
  TagColorBuilder get tagColorBuilder => (brightness, tagType) {
        final colors =
            brightness.isLight ? TagColors.dark() : TagColors.light();

        return switch (tagType) {
          '0' || 'general' || 'tag' => colors.general,
          '1' || 'artist' || 'creator' || 'studio' => colors.artist,
          '3' || 'copyright' || 'series' => colors.copyright,
          '4' || 'character' => colors.character,
          '5' || 'meta' || 'metadata' => colors.meta,
          _ => colors.general,
        };
      };
}

mixin DefaultTagSuggestionsItemBuilderMixin implements BooruBuilder {
  @override
  TagSuggestionItemBuilder get tagSuggestionItemBuilder => (
        config,
        tag,
        dense,
        currentQuery,
        onItemTap,
      ) =>
          DefaultTagSuggestionItem(
            config: config,
            tag: tag,
            onItemTap: onItemTap,
            currentQuery: currentQuery,
            dense: dense,
          );
}

mixin DefaultPostImageDetailsUrlMixin implements BooruBuilder {
  @override
  PostImageDetailsUrlBuilder get postImageDetailsUrlBuilder =>
      (imageQuality, post, config) => post.isGif
          ? post.sampleImageUrl
          : config.imageDetaisQuality.toOption().fold(
                () => switch (imageQuality) {
                  ImageQuality.low => post.thumbnailImageUrl,
                  ImageQuality.original => post.isVideo
                      ? post.videoThumbnailUrl
                      : post.originalImageUrl,
                  _ =>
                    post.isVideo ? post.videoThumbnailUrl : post.sampleImageUrl,
                },
                (quality) => switch (stringToGeneralPostQualityType(quality)) {
                  GeneralPostQualityType.preview => post.thumbnailImageUrl,
                  GeneralPostQualityType.sample =>
                    post.isVideo ? post.videoThumbnailUrl : post.sampleImageUrl,
                  GeneralPostQualityType.original => post.isVideo
                      ? post.videoThumbnailUrl
                      : post.originalImageUrl,
                },
              );
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
      (ref, action, post) => handleDefaultGestureAction(
            action,
            onDownload: () => ref.download(post),
            onShare: () => ref.sharePost(
              post,
              context: ref.context,
              state: ref.read(postShareProvider(post)),
            ),
            onToggleBookmark: () => ref.toggleBookmark(post),
            onViewTags: () =>
                goToShowTaglistPage(ref.context, post.extractTags()),
            onViewOriginal: () => goToOriginalImagePage(ref.context, post),
            onOpenSource: () => post.source.whenWeb(
              (source) => launchExternalUrlString(source.url),
              () => false,
            ),
          );
}

mixin DefaultMultiSelectionActionsBuilderMixin on BooruBuilder {
  @override
  MultiSelectionActionsBuilder? get multiSelectionActionsBuilder =>
      (context, controller) => DefaultMultiSelectionActions(
            controller: controller,
          );
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

mixin DefaultBooruUIMixin implements BooruBuilder {
  @override
  HomePageBuilder get homePageBuilder => (context) => const HomePageScaffold();

  @override
  SearchPageBuilder get searchPageBuilder =>
      (context, initialQuery) => DefaultSearchPage(
            initialQuery: initialQuery,
          );

  @override
  PostDetailsPageBuilder get postDetailsPageBuilder => (context, payload) {
        return PostDetailsScope(
          initialIndex: payload.initialIndex,
          posts: payload.posts,
          scrollController: payload.scrollController,
          child: const DefaultPostDetailsPage(),
        );
      };
}

class DefaultPostDetailsPage<T extends Post> extends ConsumerWidget {
  const DefaultPostDetailsPage({
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final data = PostDetails.of<T>(context);
    final posts = data.posts;
    final controller = data.controller;

    return PostDetailsPageScaffold(
      controller: controller,
      posts: posts,
    );
  }
}

class DefaultSearchPage extends ConsumerWidget {
  const DefaultSearchPage({
    required this.initialQuery,
    super.key,
  });

  final String? initialQuery;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final postRepo = ref.watch(postRepoProvider(ref.watchConfigSearch));

    return SearchPageScaffold(
      initialQuery: initialQuery,
      fetcher: (page, controler) => postRepo.getPostsFromController(
        controler,
        page,
      ),
    );
  }
}

mixin DefaultHomeMixin implements BooruBuilder {
  @override
  HomeViewBuilder get homeViewBuilder =>
      (context, controller) => UserCustomHomeBuilder(
            homePageController: controller,
            defaultView: MobileHomePageScaffold(
              controller: controller,
              onSearchTap: () => goToSearchPage(context),
            ),
          );

  @override
  final Map<CustomHomeViewKey, CustomHomeDataBuilder> customHomeViewBuilders =
      kDefaultAltHomeView;
}

String Function(
  Post post,
) defaultPostImageUrlBuilder(
  WidgetRef ref,
) =>
    (post) => kPreferredLayout.isDesktop
        ? post.sampleImageUrl
        : ref.watch(currentBooruBuilderProvider)?.postImageDetailsUrlBuilder(
                  ref.watch(imageListingSettingsProvider).imageQuality,
                  post,
                  ref.watchConfig,
                ) ??
            post.sampleImageUrl;

class DefaultImagePreviewQuickActionButton extends ConsumerWidget {
  const DefaultImagePreviewQuickActionButton({
    required this.post,
    super.key,
  });

  final Post post;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final config = ref.watchConfig;
    final booruBuilder = ref.watch(currentBooruBuilderProvider);

    return switch (config.defaultPreviewImageButtonActionType) {
      ImageQuickActionType.bookmark => Container(
          padding: const EdgeInsets.only(
            top: 2,
            bottom: 1,
            right: 1,
            left: 3,
          ),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: context.extendedColorScheme.surfaceContainerOverlay,
          ),
          child: BookmarkPostLikeButtonButton(
            post: post,
          ),
        ),
      ImageQuickActionType.download => DecoratedBox(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: context.extendedColorScheme.surfaceContainerOverlay,
          ),
          child: DownloadPostButton(
            post: post,
            small: true,
          ),
        ),
      ImageQuickActionType.artist => Builder(
          builder: (context) {
            final artist =
                post.artistTags != null && post.artistTags!.isNotEmpty
                    ? chooseArtistTag(post.artistTags!)
                    : null;
            if (artist == null) return const SizedBox.shrink();

            return PostTagListChip(
              tag: Tag.noCount(
                name: artist,
                category: TagCategory.artist(),
              ),
              onTap: () => goToArtistPage(
                context,
                artist,
              ),
            );
          },
        ),
      ImageQuickActionType.defaultAction =>
        booruBuilder?.quickFavoriteButtonBuilder != null
            ? booruBuilder!.quickFavoriteButtonBuilder!(
                context,
                post,
              )
            : const SizedBox.shrink(),
      ImageQuickActionType.none => const SizedBox.shrink(),
    };
  }
}

mixin UnknownMetatagsMixin implements BooruBuilder {
  @override
  MetatagExtractorBuilder? get metatagExtractorBuilder => null;
}

final PostDetailsUIBuilder kFallbackPostDetailsUIBuilder = PostDetailsUIBuilder(
  preview: {
    DetailsPart.toolbar: (context) => const DefaultInheritedPostActionToolbar(),
  },
  full: {
    DetailsPart.toolbar: (context) => const DefaultInheritedPostActionToolbar(),
    DetailsPart.tags: (context) => const DefaultInheritedTagList(),
    DetailsPart.fileDetails: (context) =>
        const DefaultInheritedFileDetailsSection(),
  },
);
