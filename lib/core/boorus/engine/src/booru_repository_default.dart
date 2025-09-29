// Package imports:
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:foundation/foundation.dart';
import 'package:rich_text_controller/rich_text_controller.dart';

// Project imports:
import '../../../../foundation/url_launcher.dart';
import '../../../blacklists/blacklist.dart';
import '../../../blacklists/providers.dart';
import '../../../comments/providers.dart';
import '../../../comments/types.dart';
import '../../../configs/config.dart';
import '../../../configs/config/providers.dart';
import '../../../configs/create/create.dart';
import '../../../configs/gesture/gesture.dart';
import '../../../downloads/downloader/providers.dart';
import '../../../downloads/filename/providers.dart';
import '../../../downloads/urls/providers.dart';
import '../../../downloads/urls/types.dart';
import '../../../errors/providers.dart';
import '../../../errors/types.dart';
import '../../../http/providers.dart';
import '../../../images/providers.dart';
import '../../../notes/notes.dart';
import '../../../posts/count/count.dart';
import '../../../posts/details_parts/widgets.dart';
import '../../../posts/favorites/providers.dart';
import '../../../posts/favorites/types.dart';
import '../../../posts/listing/list.dart';
import '../../../posts/listing/providers.dart';
import '../../../posts/post/post.dart';
import '../../../posts/post/routes.dart';
import '../../../posts/rating/rating.dart';
import '../../../posts/shares/providers.dart';
import '../../../posts/sources/source.dart';
import '../../../search/queries/providers.dart';
import '../../../search/queries/tag_query_composer.dart';
import '../../../settings/providers.dart';
import '../../../settings/settings.dart';
import '../../../tags/autocompletes/autocomplete_repository.dart';
import '../../../tags/configs/configs.dart';
import '../../../tags/local/providers.dart';
import '../../../tags/metatag/metatag.dart';
import '../../../tags/show/routes.dart';
import '../../../tags/tag/colors.dart';
import '../../../tags/tag/providers.dart';
import '../../../tags/tag/tag.dart';
import 'booru_builder_types.dart';
import 'booru_repository.dart';

abstract class BooruRepositoryDefault implements BooruRepository {
  const BooruRepositoryDefault();

  @override
  AutocompleteRepository autocomplete(BooruConfigAuth config);

  @override
  BlacklistTagRefRepository blacklistTagRef(BooruConfigAuth config) {
    return EmptyBooruSpecificBlacklistTagRefRepository(ref);
  }

  @override
  DownloadFileUrlExtractor downloadFileUrlExtractor(BooruConfigAuth config) {
    return const UrlInsidePostExtractor();
  }

  @override
  FavoriteRepository favorite(BooruConfigAuth config) {
    return EmptyFavoriteRepository();
  }

  @override
  GridThumbnailUrlGenerator gridThumbnailUrlGenerator(BooruConfigAuth config) {
    return const DefaultGridThumbnailUrlGenerator();
  }

  @override
  ImageUrlResolver imageUrlResolver() {
    return const DefaultImageUrlResolver();
  }

  @override
  NoteRepository note(BooruConfigAuth config) {
    return ref.read(emptyNoteRepoProvider);
  }

  @override
  PostRepository<Post> post(BooruConfigSearch config);

  @override
  PostCountRepository? postCount(BooruConfigSearch config) {
    return null;
  }

  @override
  PostLinkGenerator<Post> postLinkGenerator(BooruConfigAuth config);

  @override
  Ref<Object?> get ref;

  @override
  BooruSiteValidator? siteValidator(BooruConfigAuth config);

  @override
  TagRepository tag(BooruConfigAuth config) {
    return ref.read(emptyTagRepoProvider);
  }

  @override
  TagQueryComposer tagComposer(BooruConfigSearch config) {
    return ref.watch(defaultTagQueryComposerProvider(config));
  }

  @override
  TagColorGenerator tagColorGenerator() {
    return const DefaultTagColorGenerator();
  }

  @override
  TextMatcher? queryMatcher(BooruConfigAuth config) {
    return null;
  }

  @override
  TagExtractor tagExtractor(BooruConfigAuth config) {
    return TagExtractorBuilder(
      siteHost: config.url,
      tagCache: ref.watch(tagCacheRepositoryProvider.future),
      sorter: TagSorter.defaults(),
      fetcher: (post, options) => TagExtractor.extractTagsFromGenericPost(post),
    );
  }

  @override
  MetatagExtractor? getMetatagExtractor(TagInfo tagInfo) {
    return null;
  }

  @override
  CommentRepository comment(BooruConfigAuth config) {
    return ref.watch(emptyCommentRepoProvider);
  }

  @override
  Dio dio(BooruConfigAuth config) {
    return ref.watch(defaultDioProvider(config));
  }

  @override
  Map<String, String> extraHttpHeaders(BooruConfigAuth config) {
    return {};
  }

  @override
  AppErrorTranslator appErrorTranslator(BooruConfigAuth config) {
    return ref.watch(defaultAppErrorTranslatorProvider);
  }

  @override
  BooruLoginDetails loginDetails(BooruConfigAuth config) {
    return ref.watch(defaultLoginDetailsProvider(config));
  }

  @override
  PostImageDetailsUrlBuilder postImageDetailsUrlBuilder(
    BooruConfigViewer config,
  ) =>
      (imageQuality, post, config) => post.isGif
      ? post.sampleImageUrl
      : config.imageDetaisQuality.toOption().fold(
              () => switch (imageQuality) {
                ImageQuality.low => post.thumbnailImageUrl,
                ImageQuality.original =>
                  post.isVideo ? post.videoThumbnailUrl : post.originalImageUrl,
                _ =>
                  post.isVideo ? post.videoThumbnailUrl : post.sampleImageUrl,
              },
              (quality) => switch (stringToGeneralPostQualityType(quality)) {
                GeneralPostQualityType.preview => post.thumbnailImageUrl,
                GeneralPostQualityType.sample =>
                  post.isVideo ? post.videoThumbnailUrl : post.sampleImageUrl,
                GeneralPostQualityType.original =>
                  post.isVideo ? post.videoThumbnailUrl : post.originalImageUrl,
              },
            ) ??
            switch (imageQuality) {
              ImageQuality.low => post.thumbnailImageUrl,
              ImageQuality.original =>
                post.isVideo ? post.videoThumbnailUrl : post.originalImageUrl,
              _ => post.isVideo ? post.videoThumbnailUrl : post.sampleImageUrl,
            };

  @override
  GranularRatingFilterer? granularRatingFilterer(BooruConfigSearch config) {
    return null;
  }

  @override
  Set<Rating> getGranularRatingOptions(
    BooruConfigAuth config,
  ) => {
    Rating.explicit,
    Rating.questionable,
    Rating.sensitive,
  };

  @override
  bool handlePostGesture(
    WidgetRef ref,
    String? action,
    Post post,
  ) => const PostGestureHandler().handle(ref, action, post);
}

class PostGestureHandler {
  const PostGestureHandler({
    this.customActions = const {},
  });
  final Map<String, bool Function(WidgetRef, String?, Post)> customActions;

  bool handle(WidgetRef ref, String? action, Post post) {
    final handled = handleDefaultGestureAction(
      action,
      hapticLevel: ref.read(hapticFeedbackLevelProvider),
      onDownload: () => handleDownload(ref, post),
      onShare: () => handleShare(ref, post),
      onToggleBookmark: () => handleBookmark(ref, post),
      onViewTags: () => handleViewTags(ref, post),
      onViewOriginal: () => handleViewOriginal(ref, post),
      onOpenSource: () => handleOpenSource(ref, post),
    );

    if (handled) return true;

    for (final entry in customActions.entries) {
      if (entry.key == action) {
        final customAction = entry.value;
        if (customAction(ref, action, post)) {
          return true;
        }
      }
    }

    return false;
  }

  void handleDownload(WidgetRef ref, Post post) {
    ref.download(post);
  }

  void handleShare(WidgetRef ref, Post post) {
    ref
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
        );
  }

  void handleBookmark(WidgetRef ref, Post post) {
    ref.toggleBookmark(post);
  }

  void handleViewTags(WidgetRef ref, Post post) {
    goToShowTaglistPage(
      ref,
      post,
      auth: ref.readConfigAuth,
    );
  }

  void handleViewOriginal(WidgetRef ref, Post post) {
    goToOriginalImagePage(ref, post);
  }

  void handleOpenSource(WidgetRef ref, Post post) {
    post.source.whenWeb(
      (source) => launchExternalUrlString(source.url),
      () => false,
    );
  }
}
