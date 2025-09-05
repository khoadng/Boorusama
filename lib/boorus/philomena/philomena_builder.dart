// Package imports:
import 'package:foundation/foundation.dart';

// Project imports:
import '../../core/boorus/engine/engine.dart';
import '../../core/configs/auth/widgets.dart';
import '../../core/configs/config.dart';
import '../../core/configs/create/widgets.dart';
import '../../core/configs/manage/widgets.dart';
import '../../core/posts/details/widgets.dart';
import '../../core/posts/details_manager/types.dart';
import '../../core/posts/details_parts/widgets.dart';
import 'configs/widgets.dart';
import 'posts/types.dart';
import 'posts/widgets.dart';

class PhilomenaBuilder
    with
        FavoriteNotSupportedMixin,
        CommentNotSupportedMixin,
        ArtistNotSupportedMixin,
        CharacterNotSupportedMixin,
        LegacyGranularRatingOptionsBuilderMixin,
        UnknownMetatagsMixin,
        DefaultViewTagListBuilderMixin,
        DefaultTagSuggestionsItemBuilderMixin,
        DefaultMultiSelectionActionsBuilderMixin,
        DefaultHomeMixin,
        DefaultGranularRatingFiltererMixin,
        DefaultPostGesturesHandlerMixin,
        DefaultPostStatisticsPageBuilderMixin,
        DefaultBooruUIMixin
    implements BooruBuilder {
  PhilomenaBuilder();

  @override
  CreateConfigPageBuilder get createConfigPageBuilder =>
      (
        context,
        id, {
        backgroundColor,
      }) => CreateBooruConfigScope(
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
  UpdateConfigPageBuilder get updateConfigPageBuilder =>
      (
        context,
        id, {
        backgroundColor,
        initialTab,
      }) => UpdateBooruConfigScope(
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
      initialThumbnailUrl: payload.initialThumbnailUrl,
      posts: posts,
      scrollController: payload.scrollController,
      dislclaimer: payload.dislclaimer,
      child: const DefaultPostDetailsPage<PhilomenaPost>(),
    );
  };

  @override
  PostImageDetailsUrlBuilder get postImageDetailsUrlBuilder =>
      (
        imageQuality,
        rawPost,
        config,
      ) => castOrNull<PhilomenaPost>(rawPost).toOption().fold(
        () => rawPost.sampleImageUrl,
        (post) => config.imageDetaisQuality.toOption().fold(
          () => post.sampleImageUrl,
          (quality) => switch (stringToPhilomenaPostQualityType(quality)) {
            PhilomenaPostQualityType.full => post.representation.full,
            PhilomenaPostQualityType.large => post.representation.large,
            PhilomenaPostQualityType.medium => post.representation.medium,
            PhilomenaPostQualityType.tall => post.representation.tall,
            PhilomenaPostQualityType.small => post.representation.small,
            PhilomenaPostQualityType.thumb => post.representation.thumb,
            PhilomenaPostQualityType.thumbSmall =>
              post.representation.thumbSmall,
            PhilomenaPostQualityType.thumbTiny => post.representation.thumbTiny,
            null => post.representation.small,
          },
        ),
      );

  @override
  final postDetailsUIBuilder = PostDetailsUIBuilder(
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
          const DefaultInheritedBasicTagsTile<PhilomenaPost>(),
      DetailsPart.fileDetails: (context) =>
          const DefaultInheritedFileDetailsSection<PhilomenaPost>(),
    },
  );

  @override
  CreateUnknownBooruWidgetsBuilder get unknownBooruWidgetsBuilder =>
      (context) => const UnknownBooruWidgetsBuilder(
        loginField: null,
        apiKeyField: DefaultBooruApiKeyField(),
      );
}
