// Package imports:
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

const kEshuushuuCustomDownloadFileNameFormat = '{id}.{extension}';

class EshuushuuRepository extends BooruRepositoryDefault {
  const EshuushuuRepository({required this.ref});

  @override
  final Ref ref;

  @override
  PostRepository<Post> post(BooruConfigSearch config) {
    return ref.read(eshuushuuPostRepoProvider(config));
  }

  @override
  AutocompleteRepository autocomplete(BooruConfigAuth config) {
    return ref.watch(eshuushuuAutoCompleteRepoProvider(config));
  }

  @override
  BooruSiteValidator? siteValidator(BooruConfigAuth config) {
    return null;
  }

  @override
  PostLinkGenerator<Post> postLinkGenerator(BooruConfigAuth config) {
    return DirectIdPathPostLinkGenerator(baseUrl: config.url);
  }

  @override
  DownloadFilenameGenerator<Post> downloadFilenameBuilder(
    BooruConfigAuth config,
  ) {
    return DownloadFileNameBuilder<Post>(
      defaultFileNameFormat: kEshuushuuCustomDownloadFileNameFormat,
      defaultBulkDownloadFileNameFormat: kEshuushuuCustomDownloadFileNameFormat,
      sampleData: [],
      tokenHandlers: [],
      hasMd5: false,
      hasRating: false,
    );
  }

  @override
  Dio dio(BooruConfigAuth config) {
    return ref.watch(eshuushuuDioProvider(config));
  }

  @override
  TagExtractor tagExtractor(BooruConfigAuth config) {
    return ref.watch(eshuushuuTagExtractorProvider(config));
  }
}
