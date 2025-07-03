// Package imports:
import 'package:booru_clients/gelbooru.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import '../../core/boorus/engine/engine.dart';
import '../../core/configs/config.dart';
import '../../core/configs/create/create.dart';
import '../../core/downloads/filename/types.dart';
import '../../core/http/providers.dart';
import '../../core/posts/post/post.dart';
import '../../core/posts/post/providers.dart';
import '../../core/tags/autocompletes/types.dart';
import 'posts/providers.dart';
import 'tags/providers.dart';

class GelbooruV1Repository extends BooruRepositoryDefault {
  const GelbooruV1Repository({required this.ref});

  @override
  final Ref ref;

  @override
  PostRepository<Post> post(BooruConfigSearch config) {
    return ref.read(gelbooruV1PostRepoProvider(config));
  }

  @override
  AutocompleteRepository autocomplete(BooruConfigAuth config) {
    return ref.read(gelbooruV1AutocompleteRepoProvider(config));
  }

  @override
  DownloadFilenameGenerator downloadFilenameBuilder(BooruConfigAuth config) {
    return DownloadFileNameBuilder(
      defaultFileNameFormat: kDefaultCustomDownloadFileNameFormat,
      defaultBulkDownloadFileNameFormat: kDefaultCustomDownloadFileNameFormat,
      sampleData: kDanbooruPostSamples,
      tokenHandlers: const [],
    );
  }

  @override
  BooruSiteValidator? siteValidator(BooruConfigAuth config) {
    final dio = ref.watch(dioProvider(config));

    return () => GelbooruV1Client(baseUrl: config.url, dio: dio)
        .getPosts()
        .then((value) => value.isNotEmpty);
  }

  @override
  PostLinkGenerator postLinkGenerator(BooruConfigAuth config) {
    return IndexPhpPostLinkGenerator(baseUrl: config.url);
  }
}
