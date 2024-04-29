part of 'booru_builder.dart';

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
        final colors = themeMode == AppThemeMode.light
            ? TagColors.dark()
            : TagColors.light();

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


mixin DefaultCustomMetatagInterceptorMixin on BooruBuilder {
AutocompleteFetcher customMetatagInterceptor({
  required AutocompleteFetcher fetcher,
  required Map<String, Set<String>> metatags,
}) =>
    (query) {
      // if query ends with ':', it means it's a metatag, use custom metatags autocomplete instead
      if (query.endsWith(':')) {
        final key = query.substring(0, query.length - 1);
        if (metatags.containsKey(key)) {
          return Future.value(
            metatags[key]!
                .map((e) => '$key:$e')
                .map((e) => AutocompleteData(
                      type: key,
                      label: e.replaceAll('$key:', ''),
                      value: e,
                    ))
                .toList(),
          );
        }
      }

      return fetcher(query);
    };

    Map<String, Set<String>> get metatags;

    AutocompleteFetcher get baseAutocompleteFetcher;

  @override
  AutocompleteFetcher get autocompleteFetcher => customMetatagInterceptor(
        fetcher: baseAutocompleteFetcher,
        metatags: metatags,
      );
}