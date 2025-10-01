// Dart imports:
import 'dart:async';

// Flutter imports:
import 'package:flutter/services.dart';

// Package imports:
import 'package:booru_clients/danbooru.dart';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:foundation/foundation.dart';
import 'package:rich_text_controller/rich_text_controller.dart';

// Project imports:
import '../../core/blacklists/blacklist.dart';
import '../../core/boorus/engine/engine.dart';
import '../../core/comments/types.dart';
import '../../core/configs/config.dart';
import '../../core/configs/config/providers.dart';
import '../../core/configs/create/create.dart';
import '../../core/configs/gesture/gesture.dart';
import '../../core/downloads/downloader/providers.dart';
import '../../core/downloads/filename/providers.dart';
import '../../core/downloads/filename/types.dart';
import '../../core/images/providers.dart';
import '../../core/notes/notes.dart';
import '../../core/posts/count/count.dart';
import '../../core/posts/details/details.dart';
import '../../core/posts/details_parts/widgets.dart';
import '../../core/posts/favorites/types.dart';
import '../../core/posts/favorites/widgets.dart';
import '../../core/posts/listing/list.dart';
import '../../core/posts/listing/providers.dart';
import '../../core/posts/post/post.dart';
import '../../core/posts/post/providers.dart';
import '../../core/posts/post/routes.dart';
import '../../core/posts/rating/rating.dart';
import '../../core/posts/shares/providers.dart';
import '../../core/posts/sources/source.dart';
import '../../core/search/queries/query.dart';
import '../../core/settings/providers.dart';
import '../../core/settings/settings.dart';
import '../../core/tags/autocompletes/types.dart';
import '../../core/tags/configs/configs.dart';
import '../../core/tags/metatag/metatag.dart';
import '../../core/tags/metatag/providers.dart';
import '../../core/tags/show/routes.dart';
import '../../core/tags/tag/tag.dart';
import '../../foundation/url_launcher.dart';
import 'autocompletes/providers.dart';
import 'blacklist/providers.dart';
import 'client_provider.dart';
import 'comments/comment/data.dart';
import 'notes/providers.dart';
import 'posts/count/providers.dart';
import 'posts/details/providers.dart';
import 'posts/favorites/providers.dart';
import 'posts/listing/providers.dart';
import 'posts/post/post.dart';
import 'posts/post/providers.dart';
import 'posts/votes/providers.dart';
import 'syntax/providers.dart';
import 'tags/tag/providers.dart';

class DanbooruRepository extends BooruRepositoryDefault {
  const DanbooruRepository({
    required this.ref,
  });

  @override
  final Ref ref;

  @override
  PostCountRepository? postCount(BooruConfigSearch config) {
    return ref.read(danbooruPostCountRepoProvider(config));
  }

  @override
  PostRepository<Post> post(BooruConfigSearch config) {
    return ref.read(danbooruPostRepoProvider(config));
  }

  @override
  AutocompleteRepository autocomplete(BooruConfigAuth config) {
    return ref.read(danbooruAutocompleteRepoProvider(config));
  }

  @override
  NoteRepository note(BooruConfigAuth config) {
    return ref.read(danbooruNoteRepoProvider(config));
  }

  @override
  TagRepository tag(BooruConfigAuth config) {
    return ref.read(danbooruTagRepoProvider(config));
  }

  @override
  FavoriteRepository favorite(BooruConfigAuth config) {
    return ref.watch(danbooruFavoriteRepoProvider(config));
  }

  @override
  BlacklistTagRefRepository blacklistTagRef(BooruConfigAuth config) {
    return DanbooruBlacklistTagRepository(
      ref,
      config,
    );
  }

  @override
  BooruSiteValidator? siteValidator(BooruConfigAuth config) {
    final dio = ref.watch(danbooruDioProvider(config));

    return () => DanbooruClient(
      baseUrl: config.url,
      dio: dio,
      login: config.login,
      apiKey: config.apiKey,
    ).getPosts().then((value) => true);
  }

  @override
  TagQueryComposer tagComposer(BooruConfigSearch config) {
    return ref.watch(danbooruTagQueryComposerProvider(config));
  }

  @override
  PostLinkGenerator postLinkGenerator(BooruConfigAuth config) {
    return PluralPostLinkGenerator(baseUrl: config.url);
  }

  @override
  GridThumbnailUrlGenerator gridThumbnailUrlGenerator(BooruConfigAuth config) {
    return const DanbooruGridThumbnailUrlGenerator();
  }

  @override
  TextMatcher queryMatcher(BooruConfigAuth config) {
    return ref.watch(danbooruQueryMatcherProvider);
  }

  @override
  DownloadFilenameGenerator downloadFilenameBuilder(BooruConfigAuth config) {
    return DownloadFileNameBuilder<DanbooruPost>(
      defaultFileNameFormat: kBoorusamaCustomDownloadFileNameFormat,
      defaultBulkDownloadFileNameFormat:
          kBoorusamaBulkDownloadCustomFileNameFormat,
      sampleData: kDanbooruPostSamples,
      tokenHandlers: [
        WidthTokenHandler(),
        HeightTokenHandler(),
        AspectRatioTokenHandler(),
        TokenHandler('artist', (post, config) => post.artistTags.join(' ')),
        TokenHandler(
          'character',
          (post, config) => post.characterTags.join(' '),
        ),
        TokenHandler(
          'copyright',
          (post, config) => post.copyrightTags.join(' '),
        ),
        TokenHandler('general', (post, config) => post.generalTags.join(' ')),
        TokenHandler('meta', (post, config) => post.metaTags.join(' ')),
        MPixelsTokenHandler(),
      ],
    );
  }

  @override
  TagExtractor tagExtractor(BooruConfigAuth config) {
    return ref.watch(danbooruTagExtractorProvider(config));
  }

  @override
  CommentRepository comment(BooruConfigAuth config) {
    return ref.watch(danbooruCommentRepoProvider(config));
  }

  @override
  Dio dio(BooruConfigAuth config) {
    return ref.watch(danbooruDioProvider(config));
  }

  @override
  MediaUrlResolver mediaUrlResolver(BooruConfigAuth config) {
    return ref.watch(danbooruMediaUrlResolverProvider(config));
  }

  @override
  MetatagExtractor? getMetatagExtractor(TagInfo tagInfo) {
    return DefaultMetatagExtractor(
      metatags: tagInfo.metatags,
    );
  }

  @override
  GranularRatingFilterer? granularRatingFilterer(BooruConfigSearch config) =>
      (post, config) => switch (config.filter.ratingFilter) {
        BooruConfigRatingFilter.none => false,
        BooruConfigRatingFilter.hideNSFW => post.rating != Rating.general,
        BooruConfigRatingFilter.hideExplicit => post.rating.isNSFW(),
        BooruConfigRatingFilter.custom =>
          config.filter.granularRatingFiltersWithoutUnknown.toOption().fold(
            () => false,
            (ratings) => ratings.contains(post.rating),
          ),
      };

  @override
  Set<Rating> getGranularRatingOptions(
    BooruConfigAuth config,
  ) => {
    Rating.explicit,
    Rating.questionable,
    Rating.sensitive,
    Rating.general,
  };

  @override
  bool handlePostGesture(WidgetRef ref, String? action, Post post) =>
      handleDanbooruGestureAction(
        action,
        hapticLevel: ref.read(hapticFeedbackLevelProvider),
        onDownload: () => ref.download(post),
        onShare: () => ref
            .read(shareProvider)
            .sharePost(
              post,
              ref.readConfigAuth,
              context: ref.context,
              configViewer: ref.readConfigViewer,
              download: ref.readConfigDownload,
              filenameBuilder: ref.read(
                downloadFilenameBuilderProvider(ref.readConfigAuth),
              ),
              imageCacheManager: ref.read(defaultImageCacheManagerProvider),
            ),
        onToggleBookmark: () => ref.toggleBookmark(post),
        onViewTags: () => goToShowTaglistPage(
          ref,
          post,
          auth: ref.readConfigAuth,
        ),
        onViewOriginal: () => goToOriginalImagePage(ref, post),
        onOpenSource: () => post.source.whenWeb(
          (source) => launchExternalUrlString(source.url),
          () => false,
        ),
        onToggleFavorite: () => ref.toggleFavorite(post.id),
        onUpvote: () => ref.danbooruUpvote(post.id),
        onDownvote: () => ref.danbooruDownvote(post.id),
        onEdit: () => castOrNull<DanbooruPost>(post).toOption().fold(
          () => false,
          (post) => ref.danbooruEdit(post),
        ),
      );
}

class DanbooruGridThumbnailUrlGenerator implements GridThumbnailUrlGenerator {
  const DanbooruGridThumbnailUrlGenerator();

  @override
  String generateUrl(
    Post post, {
    required GridThumbnailSettings settings,
  }) {
    return castOrNull<DanbooruPost>(post).toOption().fold(
      () => const DefaultGridThumbnailUrlGenerator().generateUrl(
        post,
        settings: settings,
      ),
      (post) =>
          DefaultGridThumbnailUrlGenerator(
            gifImageQualityMapper: (_, _) => post.sampleImageUrl,
            imageQualityMapper: (_, imageQuality, gridSize) =>
                switch (imageQuality) {
                  ImageQuality.automatic => switch (gridSize) {
                    GridSize.micro => post.url180x180,
                    GridSize.tiny => post.url360x360,
                    _ => post.url720x720,
                  },
                  ImageQuality.low => switch (gridSize) {
                    GridSize.micro || GridSize.tiny => post.url180x180,
                    _ => post.url360x360,
                  },
                  ImageQuality.high => switch (gridSize) {
                    GridSize.micro => post.url180x180,
                    GridSize.tiny => post.url360x360,
                    _ => post.url720x720,
                  },
                  ImageQuality.highest =>
                    post.isVideo
                        ? post.url720x720
                        : switch (gridSize) {
                            GridSize.micro => post.url360x360,
                            GridSize.tiny => post.url720x720,
                            _ => post.urlSample,
                          },
                  ImageQuality.original => post.urlOriginal,
                },
          ).generateUrl(
            post,
            settings: settings,
          ),
    );
  }
}

bool handleDanbooruGestureAction(
  String? action, {
  required HapticFeedbackLevel hapticLevel,
  void Function()? onDownload,
  void Function()? onShare,
  void Function()? onToggleBookmark,
  void Function()? onViewTags,
  void Function()? onViewOriginal,
  void Function()? onOpenSource,
  void Function()? onToggleFavorite,
  void Function()? onUpvote,
  void Function()? onDownvote,
  void Function()? onEdit,
}) {
  switch (action) {
    case kToggleFavoriteAction:
      onToggleFavorite?.call();
    case kUpvoteAction:
      onUpvote?.call();
    case kDownvoteAction:
      onDownvote?.call();
    case kEditAction:
      onEdit?.call();
    default:
      return handleDefaultGestureAction(
        action,
        onDownload: onDownload,
        onShare: onShare,
        onToggleBookmark: onToggleBookmark,
        onViewTags: onViewTags,
        onViewOriginal: onViewOriginal,
        onOpenSource: onOpenSource,
        hapticLevel: hapticLevel,
      );
  }

  if (hapticLevel.isFull) {
    unawaited(HapticFeedback.selectionClick());
  }

  return true;
}
