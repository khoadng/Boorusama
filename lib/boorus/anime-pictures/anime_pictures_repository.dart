// Package imports:
import 'package:booru_clients/anime_pictures.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import '../../core/boorus/defaults/types.dart';
import '../../core/configs/config/types.dart';
import '../../core/configs/create/create.dart';
import '../../core/downloads/filename/types.dart';
import '../../core/downloads/urls/types.dart';
import '../../core/http/client/providers.dart';
import '../../core/posts/post/providers.dart';
import '../../core/posts/post/types.dart';
import '../../core/tags/autocompletes/types.dart';
import '../../core/tags/tag/types.dart';
import 'client_provider.dart';
import 'downloads/file_url_extractor.dart';
import 'downloads/providers.dart';
import 'posts/providers.dart';
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
    return ref.read(animePicturesDownloadFilenameGeneratorProvider(config));
  }

  @override
  BooruSiteValidator? siteValidator(BooruConfigAuth config) {
    final dio = ref.watch(defaultDioProvider(config));

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
