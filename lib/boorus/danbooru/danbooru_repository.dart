// Package imports:
import 'package:booru_clients/danbooru.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:foundation/foundation.dart';
import 'package:rich_text_controller/rich_text_controller.dart';

// Project imports:
import '../../core/blacklists/blacklist.dart';
import '../../core/boorus/engine/engine.dart';
import '../../core/comments/types.dart';
import '../../core/configs/config.dart';
import '../../core/configs/create/create.dart';
import '../../core/downloads/filename/types.dart';
import '../../core/http/providers.dart';
import '../../core/notes/notes.dart';
import '../../core/posts/count/count.dart';
import '../../core/posts/favorites/types.dart';
import '../../core/posts/listing/list.dart';
import '../../core/posts/listing/providers.dart';
import '../../core/posts/post/post.dart';
import '../../core/posts/post/providers.dart';
import '../../core/search/queries/query.dart';
import '../../core/settings/settings.dart';
import '../../core/tags/autocompletes/types.dart';
import '../../core/tags/tag/tag.dart';
import 'autocompletes/providers.dart';
import 'blacklist/providers.dart';
import 'comments/comment/data.dart';
import 'notes/providers.dart';
import 'posts/count/providers.dart';
import 'posts/favorites/providers.dart';
import 'posts/post/post.dart';
import 'posts/post/providers.dart';
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
    final dio = ref.watch(defaultDioProvider(config));

    return () => DanbooruClient(
      baseUrl: config.url,
      dio: dio,
      login: config.login,
      apiKey: config.apiKey,
    ).getPosts().then((value) => true);
  }

  @override
  TagQueryComposer tagComposer(BooruConfigSearch config) {
    return DanbooruTagQueryComposer(config: config);
  }

  @override
  PostLinkGenerator postLinkGenerator(BooruConfigAuth config) {
    return PluralPostLinkGenerator(baseUrl: config.url);
  }

  @override
  GridThumbnailUrlGenerator gridThumbnailUrlGenerator() {
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
            imageQualityMapper: (_, imageQuality) => switch (imageQuality) {
              ImageQuality.automatic => post.url720x720,
              ImageQuality.low => post.url360x360,
              ImageQuality.high => post.url720x720,
              ImageQuality.highest =>
                post.isVideo ? post.url720x720 : post.urlSample,
              ImageQuality.original => post.urlOriginal,
            },
          ).generateUrl(
            post,
            settings: settings,
          ),
    );
  }
}
