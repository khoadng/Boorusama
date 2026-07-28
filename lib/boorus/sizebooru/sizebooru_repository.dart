// Package imports:
import 'package:booru_clients/sizebooru.dart';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import '../../core/boorus/defaults/types.dart';
import '../../core/configs/config/types.dart';
import '../../core/configs/create/create.dart';
import '../../core/downloads/filename/types.dart';
import '../../core/posts/post/providers.dart';
import '../../core/posts/post/types.dart';
import '../../core/tags/autocompletes/types.dart';
import '../../core/tags/tag/types.dart';
import 'client_provider.dart';
import 'posts/providers.dart';
import 'tags/providers.dart';

const kSizebooruCustomDownloadFileNameFormat = '{id}.{extension}';

class SizebooruRepository extends BooruRepositoryDefault {
  const SizebooruRepository({required this.ref});

  @override
  final Ref ref;

  @override
  PostRepository<Post> post(BooruConfigSearch config) {
    return ref.read(sizebooruPostRepoProvider(config));
  }

  @override
  AutocompleteRepository autocomplete(BooruConfigAuth config) {
    return ref.watch(sizebooruAutoCompleteRepoProvider(config));
  }

  @override
  BooruSiteValidator? siteValidator(BooruConfigAuth config) {
    final dio = ref.watch(sizebooruDioProvider(config));
    return () => SizebooruClient(
      dio: dio,
      baseUrl: config.url,
    ).getPosts().then((value) => true);
  }

  @override
  PostLinkGenerator<Post> postLinkGenerator(BooruConfigAuth config) {
    return IntIdPostLinkGenerator(
      baseUrl: config.url,
      pathTemplate: 'Details/{id}',
    );
  }

  @override
  DownloadFilenameGenerator<Post> downloadFilenameBuilder(
    BooruConfigAuth config,
  ) {
    return DownloadFileNameBuilder<Post>(
      defaultFileNameFormat: kSizebooruCustomDownloadFileNameFormat,
      defaultBulkDownloadFileNameFormat: kSizebooruCustomDownloadFileNameFormat,
      sampleData: const [],
      tokenHandlers: const [],
      hasMd5: false,
      hasRating: false,
    );
  }

  @override
  Dio dio(BooruConfigAuth config) {
    return ref.watch(sizebooruDioProvider(config));
  }

  @override
  TagExtractor tagExtractor(BooruConfigAuth config) {
    return ref.watch(sizebooruTagExtractorProvider(config));
  }
}
