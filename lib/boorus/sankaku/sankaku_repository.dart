// Package imports:
import 'package:booru_clients/sankaku.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import '../../core/autocompletes/autocompletes.dart';
import '../../core/boorus/engine/engine.dart';
import '../../core/configs/config.dart';
import '../../core/configs/create/create.dart';
import '../../core/downloads/filename.dart';
import '../../core/downloads/filename/constants.dart';
import '../../core/downloads/urls.dart';
import '../../core/http/providers.dart';
import '../../core/posts/post/post.dart';
import '../../core/tags/tag/tag.dart';
import 'posts/providers.dart';
import 'posts/types.dart';
import 'tags/providers.dart';

class SankakuRepository extends BooruRepositoryDefault {
  const SankakuRepository({required this.ref});

  @override
  final Ref ref;

  @override
  PostRepository<Post> post(BooruConfigSearch config) {
    return ref.read(sankakuPostRepoProvider(config));
  }

  @override
  AutocompleteRepository autocomplete(BooruConfigAuth config) {
    return ref.read(sankakuAutocompleteRepoProvider(config));
  }

  @override
  BooruSiteValidator? siteValidator(BooruConfigAuth config) {
    final dio = ref.watch(dioProvider(config));

    return () => SankakuClient(
          baseUrl: config.url,
          dio: dio,
          username: config.login,
          password: config.apiKey,
        ).getPosts().then((value) => true);
  }

  @override
  PostLinkGenerator postLinkGenerator(BooruConfigAuth config) {
    return SankakuPostLinkGenerator(baseUrl: config.url);
  }

  @override
  DownloadFilenameGenerator downloadFilenameBuilder(BooruConfigAuth config) {
    return DownloadFileNameBuilder<SankakuPost>(
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
        TokenHandler(
          'source',
          (post, config) => sanitizedUrl(config.downloadUrl),
        ),
      ],
    );
  }

  @override
  TagGroupRepository<Post> tagGroup(BooruConfigAuth config) {
    return ref.watch(sankakuTagGroupRepoProvider(config));
  }
}

class SankakuPostLinkGenerator implements PostLinkGenerator<SankakuPost> {
  SankakuPostLinkGenerator({
    required this.baseUrl,
  });

  final String baseUrl;

  @override
  String getLink(SankakuPost post) {
    final url = baseUrl.endsWith('/')
        ? baseUrl.substring(0, baseUrl.length - 1)
        : baseUrl;

    return '$url/posts/${post.sankakuId}';
  }
}
