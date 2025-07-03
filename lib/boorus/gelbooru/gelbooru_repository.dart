// Package imports:
import 'package:booru_clients/gelbooru.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rich_text_controller/rich_text_controller.dart';

// Project imports:
import '../../core/boorus/engine/engine.dart';
import '../../core/comments/types.dart';
import '../../core/configs/config.dart';
import '../../core/configs/create/create.dart';
import '../../core/downloads/filename/types.dart';
import '../../core/http/providers.dart';
import '../../core/notes/notes.dart';
import '../../core/posts/favorites/providers.dart';
import '../../core/posts/post/post.dart';
import '../../core/posts/post/providers.dart';
import '../../core/search/queries/query.dart';
import '../../core/tags/autocompletes/types.dart';
import '../../core/tags/tag/tag.dart';
import 'client_provider.dart';
import 'comments/providers.dart';
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
    return GelbooruFavoriteRepository(ref, config);
  }

  @override
  BooruSiteValidator? siteValidator(BooruConfigAuth config) {
    final dio = ref.watch(dioProvider(config));

    return () => GelbooruClient(
          baseUrl: config.url,
          dio: dio,
          userId: config.login,
          apiKey: config.apiKey,
        ).getPosts().then((value) => true);
  }

  @override
  TagQueryComposer tagComposer(BooruConfigSearch config) {
    return GelbooruTagQueryComposer(config: config);
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
    final client = ref.watch(gelbooruClientProvider(config));

    return DownloadFileNameBuilder<GelbooruPost>(
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
            tagFetcher: (post) async {
              final tags = await client.getTags(tags: post.tags);
              return tags
                  .map((tag) => (name: tag.name, type: tag.type.toString()))
                  .toList();
            },
          ),
        ),
      ],
    );
  }

  @override
  TagGroupRepository<Post> tagGroup(BooruConfigAuth config) {
    return ref.watch(gelbooruTagGroupRepoProvider(config));
  }

  @override
  CommentRepository comment(BooruConfigAuth config) {
    return ref.watch(gelbooruCommentRepoProvider(config));
  }
}

class GelbooruImageUrlResolver implements ImageUrlResolver {
  const GelbooruImageUrlResolver();

  @override
  String resolveImageUrl(String url) {
    // Handle the img3 to img4 migration
    final uri = Uri.tryParse(url);

    if (uri == null) {
      return url; // Return original if URL is invalid
    }

    // Check if this is a gelbooru URL
    if (uri.host.contains('gelbooru.com')) {
      // Handle specific subdomain changes
      if (uri.host == 'img3.gelbooru.com') {
        // Create new URL with updated subdomain
        final newUri = uri.replace(host: 'img4.gelbooru.com');
        return newUri.toString();
      }
    }

    return url; // Return original if no patterns match
  }

  @override
  String resolvePreviewUrl(String url) => resolveImageUrl(url);

  @override
  String resolveThumbnailUrl(String url) => resolveImageUrl(url);
}
