// Package imports:
import 'package:booru_clients/gelbooru.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rich_text_controller/rich_text_controller.dart';

// Project imports:
import '../../core/boorus/defaults/types.dart';
import '../../core/comments/types.dart';
import '../../core/configs/config.dart';
import '../../core/configs/create/create.dart';
import '../../core/configs/gesture/gesture.dart';
import '../../core/downloads/filename/types.dart';
import '../../core/http/providers.dart';
import '../../core/notes/notes.dart';
import '../../core/posts/favorites/types.dart';
import '../../core/posts/favorites/widgets.dart';
import '../../core/posts/listing/list.dart';
import '../../core/posts/listing/providers.dart';
import '../../core/posts/post/post.dart';
import '../../core/posts/post/providers.dart';
import '../../core/search/queries/query.dart';
import '../../core/tags/autocompletes/types.dart';
import '../../core/tags/tag/tag.dart';
import 'comments/providers.dart';
import 'configs/providers.dart';
import 'favorites/providers.dart';
import 'gelbooru_v2_provider.dart';
import 'notes/providers.dart';
import 'posts/providers.dart';
import 'posts/types.dart';
import 'syntax/providers.dart';
import 'tags/providers.dart';

class GelbooruV2Repository extends BooruRepositoryDefault {
  const GelbooruV2Repository({required this.ref});

  @override
  final Ref ref;

  @override
  PostRepository<Post> post(BooruConfigSearch config) {
    return ref.read(gelbooruV2PostRepoProvider(config));
  }

  @override
  AutocompleteRepository autocomplete(BooruConfigAuth config) {
    return ref.read(gelbooruV2AutocompleteRepoProvider(config));
  }

  @override
  NoteRepository note(BooruConfigAuth config) {
    return ref.read(gelbooruV2NoteRepoProvider(config));
  }

  @override
  BooruSiteValidator? siteValidator(BooruConfigAuth config) {
    final dio = ref.watch(defaultDioProvider(config));

    return () => GelbooruV2Client(
      baseUrl: config.url,
      dio: dio,
      userId: config.login,
      apiKey: config.apiKey,
    ).getPosts().then((value) => true);
  }

  @override
  TagQueryComposer tagComposer(BooruConfigSearch config) {
    return ref.watch(gelbooruV2TagQueryComposerProvider(config));
  }

  @override
  PostLinkGenerator postLinkGenerator(BooruConfigAuth config) {
    return IndexPhpPostLinkGenerator(baseUrl: config.url);
  }

  @override
  TextMatcher? queryMatcher(BooruConfigAuth config) {
    return ref.watch(gelbooruV2QueryMatcherProvider);
  }

  @override
  DownloadFilenameGenerator downloadFilenameBuilder(BooruConfigAuth config) {
    return DownloadFileNameBuilder<GelbooruV2Post>(
      defaultFileNameFormat: kDefaultCustomDownloadFileNameFormat,
      defaultBulkDownloadFileNameFormat: kDefaultCustomDownloadFileNameFormat,
      sampleData: kDanbooruPostSamples,
      tokenHandlers: [
        WidthTokenHandler(),
        HeightTokenHandler(),
        AspectRatioTokenHandler(),
        MPixelsTokenHandler(),
      ],
      asyncTokenHandlers: [
        AsyncTokenHandler(
          ClassicTagsTokenResolver(
            tagExtractor: tagExtractor(config),
          ),
        ),
      ],
    );
  }

  @override
  TagExtractor tagExtractor(BooruConfigAuth config) {
    return ref.watch(gelbooruV2TagExtractorProvider(config));
  }

  @override
  CommentRepository comment(BooruConfigAuth config) {
    return ref.watch(gelbooruV2CommentRepoProvider(config));
  }

  @override
  FavoriteRepository favorite(BooruConfigAuth config) {
    return ref.watch(gelbooruV2FavoriteRepoProvider(config));
  }

  @override
  GridThumbnailUrlGenerator gridThumbnailUrlGenerator(BooruConfigAuth config) {
    final gelbooruV2 = ref.watch(gelbooruV2Provider);
    final thumbnailOnly =
        gelbooruV2.getCapabilitiesForSite(config.url)?.posts?.thumbnailOnly ??
        false;

    return thumbnailOnly
        ? DefaultGridThumbnailUrlGenerator(
            imageQualityMapper: (post, imageQuality, gridSize) =>
                post.thumbnailImageUrl,
            gifImageQualityMapper: (post, imageQuality) =>
                post.thumbnailImageUrl,
          )
        : const DefaultGridThumbnailUrlGenerator();
  }

  @override
  ImageUrlResolver imageUrlResolver() {
    return ref.watch(gelbooruV2PostImageUrlResolverProvider);
  }

  @override
  BooruLoginDetails loginDetails(BooruConfigAuth config) {
    return ref.watch(gelbooruV2LoginDetailsProvider(config));
  }

  @override
  bool handlePostGesture(WidgetRef ref, String? action, Post post) =>
      PostGestureHandler(
        customActions: {
          kToggleFavoriteAction: (ref, action, post) {
            ref.toggleFavorite(post.id);

            return true;
          },
        },
      ).handle(ref, action, post);
}

class GelbooruV2ImageUrlResolver implements ImageUrlResolver {
  const GelbooruV2ImageUrlResolver();

  @override
  String resolveImageUrl(String url) => url;

  @override
  String resolvePreviewUrl(String url) {
    if (url.isEmpty) return url;

    final uri = Uri.tryParse(url);

    return switch (uri) {
      null => url,
      Uri(host: 'api-cdn.rule34.xxx', path: final p)
          when p.contains('/samples/') =>
        uri.replace(host: 'wimg.rule34.xxx').toString(),
      _ => url,
    };
  }

  @override
  String resolveThumbnailUrl(String url) => url;
}
