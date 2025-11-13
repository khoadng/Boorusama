// Package imports:
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rich_text_controller/rich_text_controller.dart';

// Project imports:
import '../../../../foundation/url_launcher.dart';
import '../../../blacklists/providers.dart';
import '../../../blacklists/types.dart';
import '../../../comments/providers.dart';
import '../../../comments/types.dart';
import '../../../configs/config/providers.dart';
import '../../../configs/config/types.dart';
import '../../../configs/create/create.dart';
import '../../../configs/gesture/types.dart';
import '../../../downloads/downloader/providers.dart';
import '../../../downloads/filename/providers.dart';
import '../../../downloads/urls/providers.dart';
import '../../../downloads/urls/types.dart';
import '../../../errors/providers.dart';
import '../../../errors/types.dart';
import '../../../http/client/providers.dart';
import '../../../images/providers.dart';
import '../../../notes/note/providers.dart';
import '../../../notes/note/types.dart';
import '../../../posts/count/types.dart';
import '../../../posts/details/providers.dart';
import '../../../posts/details/types.dart';
import '../../../posts/details_parts/widgets.dart';
import '../../../posts/favorites/providers.dart';
import '../../../posts/favorites/types.dart';
import '../../../posts/listing/providers.dart';
import '../../../posts/listing/types.dart';
import '../../../posts/post/routes.dart';
import '../../../posts/post/types.dart';
import '../../../posts/rating/types.dart';
import '../../../posts/shares/providers.dart';
import '../../../posts/sources/types.dart';
import '../../../search/queries/providers.dart';
import '../../../search/queries/tag_query_composer.dart';
import '../../../settings/providers.dart';
import '../../../tags/autocompletes/autocomplete_repository.dart';
import '../../../tags/local/providers.dart';
import '../../../tags/metatag/types.dart';
import '../../../tags/show/routes.dart';
import '../../../tags/tag/colors.dart';
import '../../../tags/tag/providers.dart';
import '../../../tags/tag/types.dart';
import '../../engine/types.dart';

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
  MetatagExtractor? getMetatagExtractor(BooruConfigAuth config) {
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
  MediaUrlResolver mediaUrlResolver(BooruConfigAuth config) =>
      ref.watch(defaultMediaUrlResolverProvider(config));

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

  @override
  CommentExtractor commentExtractor(BooruConfigAuth config) {
    return ref.watch(unsupportedCommentExtractor);
  }
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
      onStartSlideshow: () =>
          PostDetailsPageViewScope.maybeOf(ref.context)?.startSlideshow(),
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
    ref
        .read(
          downloadNotifierProvider(
            ref.read(
              downloadNotifierParamsProvider((
                ref.readConfigAuth,
                ref.readConfigDownload,
              )),
            ),
          ).notifier,
        )
        .download(post);
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
