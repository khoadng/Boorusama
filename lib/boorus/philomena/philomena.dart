// Flutter imports:
import 'package:flutter/material.dart' hide ThemeMode;

// Project imports:
import 'package:boorusama/boorus/booru_builder.dart';
import 'package:boorusama/boorus/philomena/create_philomena_config_page.dart';
import 'package:boorusama/core/feats/artist_commentaries/artist_commentaries.dart';
import 'package:boorusama/core/feats/autocompletes/autocompletes.dart';
import 'package:boorusama/core/feats/boorus/boorus.dart';
import 'package:boorusama/core/feats/downloads/downloads.dart';
import 'package:boorusama/core/feats/posts/posts.dart';
import 'package:boorusama/core/feats/settings/settings.dart';
import 'package:boorusama/core/router.dart';
import 'package:boorusama/core/scaffolds/scaffolds.dart';
import 'package:boorusama/core/widgets/widgets.dart';
import 'package:boorusama/dart.dart';
import 'package:boorusama/foundation/theme/theme.dart';
import 'package:boorusama/functional.dart';
import 'philomena_post.dart';

class PhilomenaBuilder
    with
        FavoriteNotSupportedMixin,
        PostCountNotSupportedMixin,
        NoteNotSupportedMixin,
        DefaultThumbnailUrlMixin,
        CommentNotSupportedMixin,
        ArtistNotSupportedMixin,
        CharacterNotSupportedMixin,
        LegacyGranularRatingOptionsBuilderMixin,
        NoGranularRatingQueryBuilderMixin,
        DefaultSortTokenToQueryMixin, // TODO: Philomena has a different approach for sorting, they use query params instead of a query string
        DefaultGranularRatingFiltererMixin,
        DefaultPostGesturesHandlerMixin,
        DefaultPostStatisticsPageBuilderMixin,
        DefaultBooruUIMixin
    implements
        BooruBuilder {
  PhilomenaBuilder({
    required this.postRepo,
    required this.autocompleteRepo,
  });

  final PostRepository postRepo;
  final AutocompleteRepository autocompleteRepo;

  @override
  AutocompleteFetcher get autocompleteFetcher =>
      (query) => autocompleteRepo.getAutocomplete(query);

  @override
  CreateConfigPageBuilder get createConfigPageBuilder => (
        context,
        url,
        booruType, {
        backgroundColor,
      }) =>
          CreatePhilomenaConfigPage(
            config: BooruConfig.defaultConfig(
              booruType: booruType,
              url: url,
              customDownloadFileNameFormat: null,
            ),
            backgroundColor: backgroundColor,
            isNewConfig: true,
          );

  @override
  UpdateConfigPageBuilder get updateConfigPageBuilder => (
        context,
        config, {
        backgroundColor,
      }) =>
          CreatePhilomenaConfigPage(
            config: config,
            backgroundColor: backgroundColor,
          );

  @override
  PostFetcher get postFetcher => (page, tags) => postRepo.getPosts(tags, page);

  @override
  PostDetailsPageBuilder get postDetailsPageBuilder =>
      (context, config, payload) => BooruProvider(
            builder: (booruBuilder, ref) => PostDetailsPageScaffold(
              posts: payload.posts,
              initialIndex: payload.initialIndex,
              artistInfoBuilder: (context, post) => ArtistSection(
                commentary: post is PhilomenaPost
                    ? ArtistCommentary(
                        originalTitle: '',
                        originalDescription: post.description,
                        translatedTitle: '',
                        translatedDescription: '',
                      )
                    : ArtistCommentary.empty(),
                artistTags: post.artistTags ?? {},
                source: post.source,
              ),
              swipeImageUrlBuilder: defaultPostImageUrlBuilder(ref),
              infoBuilder: (context, post) =>
                  SimpleInformationSection(post: post),
              statsTileBuilder: (context, rawPost) =>
                  castOrNull<PhilomenaPost>(rawPost).toOption().fold(
                        () => const SizedBox(),
                        (post) => SimplePostStatsTile(
                          totalComments: post.commentCount,
                          favCount: post.favCount,
                          score: post.score,
                          votePercentText: _generatePercentText(post),
                        ),
                      ),
              onExit: (page) => payload.scrollController?.scrollToIndex(page),
              onTagTap: (tag) => goToSearchPage(context, tag: tag),
            ),
          );

  @override
  TagColorBuilder get tagColorBuilder =>
      (themeMode, tagType) => switch (tagType) {
            'error' => themeMode.isDark
                ? const Color.fromARGB(255, 212, 84, 96)
                : const Color.fromARGB(255, 173, 38, 63),
            'rating' => themeMode.isDark
                ? const Color.fromARGB(255, 64, 140, 217)
                : const Color.fromARGB(255, 65, 124, 169),
            'origin' => themeMode.isDark
                ? const Color.fromARGB(255, 111, 100, 224)
                : const Color.fromARGB(255, 56, 62, 133),
            'oc' => themeMode.isDark
                ? const Color.fromARGB(255, 176, 86, 182)
                : const Color.fromARGB(255, 176, 86, 182),
            'character' => themeMode.isDark
                ? const Color.fromARGB(255, 73, 170, 190)
                : const Color.fromARGB(255, 46, 135, 119),
            'species' => themeMode.isDark
                ? const Color.fromARGB(255, 176, 106, 80)
                : const Color.fromARGB(255, 131, 87, 54),
            'content-official' => themeMode.isDark
                ? const Color.fromARGB(255, 185, 180, 65)
                : const Color.fromARGB(255, 151, 142, 27),
            'content-fanmade' => themeMode.isDark
                ? const Color.fromARGB(255, 204, 143, 180)
                : const Color.fromARGB(255, 174, 90, 147),
            _ => themeMode.isDark
                ? Colors.green
                : const Color.fromARGB(255, 111, 143, 13),
          };

  @override
  DownloadFilenameGenerator<Post> get downloadFilenameBuilder =>
      LegacyFilenameBuilder(
        generateFileName: (post, downloadUrl) =>
            generateMd5FileNameFor(post, downloadUrl),
      );

  @override
  PostImageDetailsUrlBuilder get postImageDetailsUrlBuilder => (settings,
          rawPost, config) =>
      castOrNull<PhilomenaPost>(rawPost).toOption().fold(
            () => rawPost.sampleImageUrl,
            (post) => config.imageDetaisQuality.toOption().fold(
                () => switch (settings.imageQuality) {
                      ImageQuality.highest ||
                      ImageQuality.original =>
                        post.representation.medium,
                      _ => post.representation.small,
                    },
                (quality) =>
                    switch (stringToPhilomenaPostQualityType(quality)) {
                      PhilomenaPostQualityType.full => post.representation.full,
                      PhilomenaPostQualityType.large =>
                        post.representation.large,
                      PhilomenaPostQualityType.medium =>
                        post.representation.medium,
                      PhilomenaPostQualityType.tall => post.representation.tall,
                      PhilomenaPostQualityType.small =>
                        post.representation.small,
                      PhilomenaPostQualityType.thumb =>
                        post.representation.thumb,
                      PhilomenaPostQualityType.thumbSmall =>
                        post.representation.thumbSmall,
                      PhilomenaPostQualityType.thumbTiny =>
                        post.representation.thumbTiny,
                      null => post.representation.small,
                    }),
          );
}

String _generatePercentText(PhilomenaPost? post) {
  if (post == null) return '';
  final percent = post.score > 0 ? (post.upvotes / post.score) : 0;
  return post.score > 0 ? '(${(percent * 100).toInt()}% upvoted)' : '';
}
