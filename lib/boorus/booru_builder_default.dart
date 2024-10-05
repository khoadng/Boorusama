part of 'booru_builder.dart';

mixin FavoriteNotSupportedMixin implements BooruBuilder {
  @override
  FavoriteAdder? get favoriteAdder => null;
  @override
  FavoriteRemover? get favoriteRemover => null;

  @override
  FavoritesPageBuilder? get favoritesPageBuilder => null;
  @override
  QuickFavoriteButtonBuilder? get quickFavoriteButtonBuilder => null;
}

mixin DefaultQuickFavoriteButtonBuilderMixin implements BooruBuilder {
  @override
  QuickFavoriteButtonBuilder get quickFavoriteButtonBuilder =>
      (context, constraints, post) => DefaultQuickFavoriteButton(
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
      (ref, action, post) => handleDefaultGestureAction(
            action,
            onDownload: () => ref.download(post),
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

mixin DefaultBooruUIMixin implements BooruBuilder {
  @override
  HomePageBuilder get homePageBuilder =>
      (context, config) => const HomePageScaffold();

  @override
  SearchPageBuilder get searchPageBuilder =>
      (context, initialQuery) => DefaultSearchPage(
            initialQuery: initialQuery,
          );

  @override
  PostDetailsPageBuilder get postDetailsPageBuilder =>
      (context, config, payload) {
        return PostDetailsLayoutSwitcher(
          initialIndex: payload.initialIndex,
          posts: payload.posts,
          scrollController: payload.scrollController,
          desktop: (controller) => DefaultPostDetailsDesktopPage(
            initialIndex: controller.currentPage.value,
            posts: payload.posts,
            onExit: (page) => controller.onExit(page),
            onPageChanged: (page) => controller.setPage(page),
          ),
          mobile: (controller) => DefaultPostDetailsPage(
            payload: payload,
          ),
        );
      };
}

class DefaultPostDetailsPage extends ConsumerWidget {
  const DefaultPostDetailsPage({
    super.key,
    required this.payload,
  });

  final DetailsPayload payload;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return PostDetailsPageScaffold(
      posts: payload.posts,
      initialIndex: payload.initialIndex,
      swipeImageUrlBuilder: defaultPostImageUrlBuilder(ref),
      onExit: (page) => payload.scrollController?.scrollToIndex(page),
    );
  }
}

class DefaultSearchPage extends ConsumerWidget {
  const DefaultSearchPage({
    super.key,
    required this.initialQuery,
  });

  final String? initialQuery;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final booruBuilder = ref.watch(booruBuilderProvider);

    return SearchPageScaffold(
      initialQuery: initialQuery,
      fetcher: (page, controler) =>
          booruBuilder?.postFetcher.call(page, controler.rawTagsString) ??
          TaskEither.of(<Post>[].toResult()),
    );
  }
}

mixin DefaultHomeMixin implements BooruBuilder {
  @override
  HomeViewBuilder get homeViewBuilder =>
      (context, config, controller) => MobileHomePageScaffold(
            controller: controller,
            onSearchTap: () => goToSearchPage(context),
          );
}

String Function(
  Post post,
) defaultPostImageUrlBuilder(
  WidgetRef ref,
) =>
    (post) => kPreferredLayout.isDesktop
        ? post.sampleImageUrl
        : ref.watchBooruBuilder(ref.watchConfig)?.postImageDetailsUrlBuilder(
                  ref.watch(imageListingSettingsProvider).imageQuality,
                  post,
                  ref.watchConfig,
                ) ??
            post.sampleImageUrl;

Widget Function(
  BuildContext context,
  BoxConstraints constraints,
)? defaultImagePreviewButtonBuilder(
  WidgetRef ref,
  Post post, {
  required Widget favoriteButton,
}) =>
    switch (ref.watchConfig.defaultPreviewImageButtonActionType) {
      ImageQuickActionType.bookmark => (context, _) => Container(
            padding: const EdgeInsets.only(
              top: 2,
              bottom: 1,
              right: 1,
              left: 3,
            ),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.black.withOpacity(0.5),
            ),
            child: BookmarkPostLikeButtonButton(
              post: post,
            ),
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
                        tag: Tag.noCount(
                          name: artist,
                          category: TagCategory.artist(),
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
      ImageQuickActionType.defaultAction => (context, _) => favoriteButton,
    };

mixin UnknownMetatagsMixin implements BooruBuilder {
  @override
  MetatagExtractor? get metatagExtractor => null;
}
