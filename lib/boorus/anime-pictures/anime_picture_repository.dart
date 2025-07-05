// Package imports:
import 'package:booru_clients/anime_pictures.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import '../../core/boorus/engine/engine.dart';
import '../../core/configs/config/types.dart';
import '../../core/configs/create/create.dart';
import '../../core/downloads/filename/types.dart';
import '../../core/downloads/urls/types.dart';
import '../../core/http/providers.dart';
import '../../core/posts/post/post.dart';
import '../../core/posts/post/providers.dart';
import '../../core/tags/autocompletes/types.dart';
import '../../core/tags/tag/tag.dart';
import '../../foundation/caching.dart';
import 'client_provider.dart';
import 'posts/providers.dart';
import 'tags/parser.dart';
import 'tags/providers.dart';

final animePicturesDownloadFileUrlExtractorProvider =
    Provider.family<DownloadFileUrlExtractor, BooruConfigAuth>((ref, config) {
  return AnimePicturesDownloadFileUrlExtractor(
    client: ref.watch(animePicturesClientProvider(config)),
  );
});

class AnimePicturesRepository extends BooruRepositoryDefault {
  const AnimePicturesRepository({required this.ref});

  @override
  final Ref ref;

  @override
  PostRepository<Post> post(BooruConfigSearch config) {
    return ref.read(animePicturesPostRepoProvider(config));
  }

  @override
  AutocompleteRepository autocomplete(BooruConfigAuth config) {
    return ref.read(animePicturesAutocompleteRepoProvider(config));
  }

  @override
  DownloadFileUrlExtractor downloadFileUrlExtractor(BooruConfigAuth config) {
    return ref.read(animePicturesDownloadFileUrlExtractorProvider(config));
  }

  @override
  DownloadFilenameGenerator downloadFilenameBuilder(BooruConfigAuth config) {
    final client = ref.watch(animePicturesClientProvider(config));

    return DownloadFileNameBuilder<Post>(
      defaultFileNameFormat: kDefaultCustomDownloadFileNameFormat,
      defaultBulkDownloadFileNameFormat: kDefaultCustomDownloadFileNameFormat,
      sampleData: kDanbooruPostSamples,
      hasRating: false,
      extensionHandler: (post, config) =>
          post.format.startsWith('.') ? post.format.substring(1) : post.format,
      tokenHandlers: [
        WidthTokenHandler(),
        HeightTokenHandler(),
        AspectRatioTokenHandler(),
      ],
      asyncTokenHandlers: [
        AsyncTokenHandler(
          ClassicTagsTokenResolver(
            tagFetcher: (post) async {
              final details = await client.getPostDetails(id: post.id);

              return details.tags
                      ?.where((e) => e.tag != null)
                      .map((e) => e.tag!)
                      .map(
                        (tag) => (
                          name: tag.tag ?? '???',
                          type:
                              animePicturesTagTypeToTagCategory(tag.type).name,
                        ),
                      )
                      .toList() ??
                  [];
            },
          ),
        ),
      ],
    );
  }

  @override
  BooruSiteValidator? siteValidator(BooruConfigAuth config) {
    final dio = ref.watch(dioProvider(config));

    return () => AnimePicturesClient(
          baseUrl: config.url,
          dio: dio,
        ).getPosts().then((value) => true);
  }

  @override
  PostLinkGenerator postLinkGenerator(BooruConfigAuth config) {
    return PluralPostLinkGenerator(baseUrl: config.url);
  }

  @override
  TagExtractor tagExtractor(BooruConfigAuth config) {
    return ref.watch(animePicturesTagExtractorProvider(config));
  }
}

class AnimePicturesDownloadFileUrlExtractor
    with SimpleCacheMixin<DownloadUrlData>
    implements DownloadFileUrlExtractor {
  AnimePicturesDownloadFileUrlExtractor({
    required this.client,
  });

  final AnimePicturesClient client;

  @override
  Future<DownloadUrlData?> getDownloadFileUrl({
    required Post post,
    required String quality,
  }) =>
      tryGet(
        post.id.toString(),
        orElse: () async {
          final data = await client.getDownloadUrl(post.id);

          if (data == null) {
            return null;
          }

          return DownloadUrlData(
            url: data.url,
            cookie: data.cookie,
          );
        },
      );

  @override
  final Cache<DownloadUrlData> cache = Cache(
    maxCapacity: 10,
    staleDuration: const Duration(minutes: 5),
  );
}
