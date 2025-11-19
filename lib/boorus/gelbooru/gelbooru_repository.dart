// Package imports:
import 'package:booru_clients/gelbooru.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rich_text_controller/rich_text_controller.dart';

// Project imports:
import '../../core/boorus/defaults/types.dart';
import '../../core/comments/types.dart';
import '../../core/configs/config/types.dart';
import '../../core/configs/create/create.dart';
import '../../core/configs/gesture/types.dart';
import '../../core/downloads/filename/types.dart';
import '../../core/http/client/providers.dart';
import '../../core/notes/note/types.dart';
import '../../core/posts/favorites/types.dart';
import '../../core/posts/favorites/widgets.dart';
import '../../core/posts/post/providers.dart';
import '../../core/posts/post/types.dart';
import '../../core/posts/rating/types.dart';
import '../../core/search/queries/types.dart';
import '../../core/tags/autocompletes/types.dart';
import '../../core/tags/metatag/types.dart';
import '../../core/tags/tag/types.dart';
import 'comments/providers.dart';
import 'configs/providers.dart';
import 'favorites/providers.dart';
import 'notes/providers.dart';
import 'posts/providers.dart';
import 'posts/types.dart';
import 'syntax/providers.dart';
import 'tags/providers.dart';

class GelbooruRepository extends BooruRepositoryDefault {
  const GelbooruRepository({required this.ref});

  @override
  final Ref ref;

  @override
  PostRepository<Post> post(BooruConfigSearch config) {
    return ref.read(gelbooruPostRepoProvider(config));
  }

  @override
  AutocompleteRepository autocomplete(BooruConfigAuth config) {
    return ref.read(gelbooruAutocompleteRepoProvider(config));
  }

  @override
  NoteRepository note(BooruConfigAuth config) {
    return ref.read(gelbooruNoteRepoProvider(config));
  }

  @override
  TagRepository tag(BooruConfigAuth config) {
    return ref.read(gelbooruTagRepoProvider(config));
  }

  @override
  FavoriteRepository favorite(BooruConfigAuth config) {
    return ref.watch(gelbooruFavoriteRepoProvider(config));
  }

  @override
  BooruSiteValidator? siteValidator(BooruConfigAuth config) {
    final dio = ref.watch(defaultDioProvider(config));

    return () => GelbooruClient(
      baseUrl: config.url,
      dio: dio,
      userId: config.login,
      apiKey: config.apiKey,
    ).getPosts().then((value) => true);
  }

  @override
  TagQueryComposer tagComposer(BooruConfigSearch config) {
    return ref.watch(gelbooruTagQueryComposerProvider(config));
  }

  @override
  PostLinkGenerator postLinkGenerator(BooruConfigAuth config) {
    return IndexPhpPostLinkGenerator(baseUrl: config.url);
  }

  @override
  ImageUrlResolver imageUrlResolver() {
    return const GelbooruImageUrlResolver();
  }

  @override
  TextMatcher? queryMatcher(BooruConfigAuth config) {
    return ref.watch(gelbooruQueryMatcherProvider);
  }

  @override
  DownloadFilenameGenerator downloadFilenameBuilder(BooruConfigAuth config) {
    return DownloadFileNameBuilder(
      defaultFileNameFormat: kDefaultCustomDownloadFileNameFormat,
      defaultBulkDownloadFileNameFormat: kDefaultCustomDownloadFileNameFormat,
      sampleData: kDanbooruPostSamples,
      preload: (posts, config, cancelToken) async {
        final tagExtractor = ref.read(gelbooruTagExtractorProvider(config));

        await tagExtractor.extractTagsBatch(
          posts,
          options: ExtractOptions(
            cancelToken: cancelToken,
          ),
        );
      },
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
    return ref.watch(gelbooruTagExtractorProvider(config));
  }

  @override
  CommentRepository comment(BooruConfigAuth config) {
    return ref.watch(gelbooruCommentRepoProvider(config));
  }

  @override
  BooruLoginDetails loginDetails(BooruConfigAuth config) {
    return ref.watch(gelbooruLoginDetailsProvider(config));
  }

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
      PostGestureHandler(
        customActions: {
          kToggleFavoriteAction: (ref, action, post) {
            ref.toggleFavorite(post.id);

            return true;
          },
        },
      ).handle(ref, action, post);

  @override
  MetatagExtractor getMetatagExtractor(BooruConfigAuth config) {
    return ref.watch(gelbooruMetatagExtractorProvider(config));
  }
}
