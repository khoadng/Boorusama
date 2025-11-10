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
import '../../core/blacklists/types.dart';
import '../../core/boorus/defaults/types.dart';
import '../../core/boorus/engine/types.dart';
import '../../core/comments/types.dart';
import '../../core/configs/config/providers.dart';
import '../../core/configs/config/types.dart';
import '../../core/configs/create/create.dart';
import '../../core/configs/gesture/types.dart';
import '../../core/downloads/downloader/providers.dart';
import '../../core/downloads/filename/providers.dart';
import '../../core/downloads/filename/types.dart';
import '../../core/haptics/types.dart';
import '../../core/images/providers.dart';
import '../../core/notes/note/types.dart';
import '../../core/posts/count/types.dart';
import '../../core/posts/details/types.dart';
import '../../core/posts/details_parts/widgets.dart';
import '../../core/posts/favorites/types.dart';
import '../../core/posts/favorites/widgets.dart';
import '../../core/posts/listing/types.dart';
import '../../core/posts/post/providers.dart';
import '../../core/posts/post/routes.dart';
import '../../core/posts/post/types.dart';
import '../../core/posts/rating/types.dart';
import '../../core/posts/shares/providers.dart';
import '../../core/posts/sources/types.dart';
import '../../core/search/queries/types.dart';
import '../../core/settings/providers.dart';
import '../../core/tags/autocompletes/types.dart';
import '../../core/tags/metatag/types.dart';
import '../../core/tags/show/routes.dart';
import '../../core/tags/tag/types.dart';
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
import 'posts/listing/types.dart';
import 'posts/post/providers.dart';
import 'posts/post/types.dart';
import 'posts/votes/providers.dart';
import 'syntax/providers.dart';
import 'tags/tag/providers.dart';
import 'tags/user_metatags/providers.dart';

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
  MetatagExtractor? getMetatagExtractor(BooruConfigAuth config) {
    return ref.watch(danbooruMetatagExtractorProvider(config));
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
        onStartSlideshow: () =>
            PostDetailsPageViewScope.maybeOf(ref.context)?.startSlideshow(),
      );
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
  void Function()? onStartSlideshow,
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
        onStartSlideshow: onStartSlideshow,
      );
  }

  if (hapticLevel.isFull) {
    unawaited(HapticFeedback.selectionClick());
  }

  return true;
}
