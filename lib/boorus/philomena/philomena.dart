// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import 'package:boorusama/boorus/booru_builder.dart';
import 'package:boorusama/boorus/danbooru/danbooru.dart';
import 'package:boorusama/boorus/gelbooru_v2/gelbooru_v2.dart';
import 'package:boorusama/boorus/philomena/create_philomena_config_page.dart';
import 'package:boorusama/core/artists/artists.dart';
import 'package:boorusama/core/configs/config.dart';
import 'package:boorusama/core/configs/create.dart';
import 'package:boorusama/core/configs/manage.dart';
import 'package:boorusama/core/downloads/filename.dart';
import 'package:boorusama/core/posts.dart';
import 'package:boorusama/core/posts/details.dart';
import 'package:boorusama/core/posts/sources.dart';
import 'package:boorusama/dart.dart';
import 'package:boorusama/foundation/theme.dart';
import 'package:boorusama/functional.dart';
import 'philomena_post.dart';

class PhilomenaBuilder
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
        DefaultGranularRatingFiltererMixin,
        DefaultPostGesturesHandlerMixin,
        DefaultPostStatisticsPageBuilderMixin,
        DefaultBooruUIMixin
    implements BooruBuilder {
  PhilomenaBuilder();

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
            child: CreatePhilomenaConfigPage(
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
            child: CreatePhilomenaConfigPage(
              backgroundColor: backgroundColor,
              initialTab: initialTab,
            ),
          );

  @override
  PostDetailsPageBuilder get postDetailsPageBuilder => (context, payload) {
        final posts = payload.posts.map((e) => e as PhilomenaPost).toList();

        return PostDetailsScope(
          initialIndex: payload.initialIndex,
          posts: posts,
          scrollController: payload.scrollController,
          child: const DefaultPostDetailsPage<PhilomenaPost>(),
        );
      };

  @override
  TagColorBuilder get tagColorBuilder =>
      (brightness, tagType) => switch (tagType) {
            'error' => brightness.isDark
                ? const Color.fromARGB(255, 212, 84, 96)
                : const Color.fromARGB(255, 173, 38, 63),
            'rating' => brightness.isDark
                ? const Color.fromARGB(255, 64, 140, 217)
                : const Color.fromARGB(255, 65, 124, 169),
            'origin' => brightness.isDark
                ? const Color.fromARGB(255, 111, 100, 224)
                : const Color.fromARGB(255, 56, 62, 133),
            'oc' => brightness.isDark
                ? const Color.fromARGB(255, 176, 86, 182)
                : const Color.fromARGB(255, 176, 86, 182),
            'character' => brightness.isDark
                ? const Color.fromARGB(255, 73, 170, 190)
                : const Color.fromARGB(255, 46, 135, 119),
            'species' => brightness.isDark
                ? const Color.fromARGB(255, 176, 106, 80)
                : const Color.fromARGB(255, 131, 87, 54),
            'content-official' => brightness.isDark
                ? const Color.fromARGB(255, 185, 180, 65)
                : const Color.fromARGB(255, 151, 142, 27),
            'content-fanmade' => brightness.isDark
                ? const Color.fromARGB(255, 204, 143, 180)
                : const Color.fromARGB(255, 174, 90, 147),
            _ => brightness.isDark
                ? Colors.green
                : const Color.fromARGB(255, 111, 143, 13),
          };

  @override
  final DownloadFilenameGenerator<Post> downloadFilenameBuilder =
      DownloadFileNameBuilder<Post>(
    defaultFileNameFormat: kGelbooruV2CustomDownloadFileNameFormat,
    defaultBulkDownloadFileNameFormat: kGelbooruV2CustomDownloadFileNameFormat,
    sampleData: kDanbooruPostSamples,
    hasRating: false,
    tokenHandlers: {
      'width': (post, config) => post.width.toString(),
      'height': (post, config) => post.height.toString(),
      'source': (post, config) => post.source.url,
    },
  );

  @override
  PostImageDetailsUrlBuilder get postImageDetailsUrlBuilder => (imageQuality,
          rawPost, config) =>
      castOrNull<PhilomenaPost>(rawPost).toOption().fold(
            () => rawPost.sampleImageUrl,
            (post) => config.imageDetaisQuality.toOption().fold(
                () => post.sampleImageUrl,
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

  @override
  final PostDetailsUIBuilder postDetailsUIBuilder = PostDetailsUIBuilder(
    preview: {
      DetailsPart.info: (context) =>
          const DefaultInheritedInformationSection<PhilomenaPost>(),
      DetailsPart.toolbar: (context) =>
          const DefaultInheritedPostActionToolbar<PhilomenaPost>(),
    },
    full: {
      DetailsPart.info: (context) =>
          const DefaultInheritedInformationSection<PhilomenaPost>(),
      DetailsPart.toolbar: (context) =>
          const DefaultInheritedPostActionToolbar<PhilomenaPost>(),
      DetailsPart.artistInfo: (context) => const PhilomenaArtistInfoSection(),
      DetailsPart.stats: (context) => const PhilomenaStatsTileSection(),
      DetailsPart.source: (context) =>
          const DefaultInheritedSourceSection<PhilomenaPost>(),
      DetailsPart.tags: (context) =>
          const DefaultInheritedTagList<PhilomenaPost>(),
      DetailsPart.fileDetails: (context) =>
          const DefaultInheritedFileDetailsSection<PhilomenaPost>(),
    },
  );
}

class PhilomenaStatsTileSection extends ConsumerWidget {
  const PhilomenaStatsTileSection({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final post = InheritedPost.of<PhilomenaPost>(context);

    return SliverToBoxAdapter(
      child: SimplePostStatsTile(
        totalComments: post.commentCount,
        favCount: post.favCount,
        score: post.score,
        votePercentText: _generatePercentText(post),
      ),
    );
  }

  String _generatePercentText(PhilomenaPost? post) {
    if (post == null) return '';
    final percent = post.score > 0 ? (post.upvotes / post.score) : 0;
    return post.score > 0 ? '(${(percent * 100).toInt()}% upvoted)' : '';
  }
}

class PhilomenaArtistInfoSection extends ConsumerWidget {
  const PhilomenaArtistInfoSection({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final post = InheritedPost.of<PhilomenaPost>(context);

    return SliverToBoxAdapter(
      child: ArtistSection(
        commentary: ArtistCommentary.description(post.description),
        artistTags: post.artistTags ?? {},
        source: post.source,
      ),
    );
  }
}
