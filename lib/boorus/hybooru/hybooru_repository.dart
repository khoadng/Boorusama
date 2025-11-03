// Package imports:
import 'package:booru_clients/hybooru.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import '../../core/boorus/defaults/types.dart';
import '../../core/configs/config/types.dart';
import '../../core/configs/create/create.dart';
import '../../core/downloads/filename/types.dart';
import '../../core/http/client/providers.dart';
import '../../core/posts/post/providers.dart';
import '../../core/posts/post/types.dart';
import '../../core/tags/autocompletes/types.dart';
import '../../core/tags/tag/types.dart';
import 'posts/providers.dart';
import 'tags/providers.dart';

class HybooruRepository extends BooruRepositoryDefault {
  const HybooruRepository({required this.ref});

  @override
  final Ref ref;

  @override
  PostRepository<Post> post(BooruConfigSearch config) {
    return ref.read(hybooruPostRepoProvider(config));
  }

  @override
  AutocompleteRepository autocomplete(BooruConfigAuth config) {
    return ref.read(hybooruAutocompleteRepoProvider(config));
  }

  @override
  BooruSiteValidator? siteValidator(BooruConfigAuth config) {
    final dio = ref.watch(defaultDioProvider(config));

    return () => HybooruClient(
      baseUrl: config.url,
      dio: dio,
    ).getPosts().then((value) => true);
  }

  @override
  PostLinkGenerator<Post> postLinkGenerator(BooruConfigAuth config) {
    return PluralPostLinkGenerator(baseUrl: config.url);
  }

  @override
  DownloadFilenameGenerator<Post> downloadFilenameBuilder(
    BooruConfigAuth config,
  ) {
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
    );
  }

  @override
  TagExtractor tagExtractor(BooruConfigAuth config) {
    return ref.watch(hybooruTagExtractorProvider(config));
  }
}
