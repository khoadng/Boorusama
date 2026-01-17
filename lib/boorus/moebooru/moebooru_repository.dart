// Package imports:
import 'package:booru_clients/moebooru.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import '../../core/boorus/defaults/types.dart';
import '../../core/comments/types.dart';
import '../../core/configs/config/types.dart';
import '../../core/configs/create/create.dart';
import '../../core/downloads/filename/types.dart';
import '../../core/downloads/urls/types.dart';
import '../../core/http/client/providers.dart';
import '../../core/posts/post/providers.dart';
import '../../core/posts/post/types.dart';
import '../../core/search/queries/types.dart';
import '../../core/tags/autocompletes/types.dart';
import '../../core/tags/tag/types.dart';
import 'autocompletes/providers.dart';
import 'comments/providers.dart';
import 'configs/providers.dart';
import 'downloads/providers.dart';
import 'posts/providers.dart';
import 'tags/providers.dart';

class MoebooruRepository extends BooruRepositoryDefault {
  const MoebooruRepository({required this.ref});

  @override
  final Ref ref;

  @override
  PostRepository<Post> post(BooruConfigSearch config) {
    return ref.read(moebooruPostRepoProvider(config));
  }

  @override
  AutocompleteRepository autocomplete(BooruConfigAuth config) {
    return ref.read(moebooruAutocompleteRepoProvider(config));
  }

  @override
  TagRepository tag(BooruConfigAuth config) {
    return ref.read(moebooruTagRepoProvider(config));
  }

  @override
  BooruSiteValidator? siteValidator(BooruConfigAuth config) {
    final dio = ref.watch(defaultDioProvider(config));

    return () => MoebooruClient(
      baseUrl: config.url,
      dio: dio,
      login: config.login,
      passwordHashed: config.apiKey,
    ).getPosts().then((value) => true);
  }

  @override
  TagQueryComposer tagComposer(BooruConfigSearch config) {
    return ref.watch(moebooruTagQueryComposerProvider(config));
  }

  @override
  PostLinkGenerator postLinkGenerator(BooruConfigAuth config) {
    return ShowPostLinkGenerator(baseUrl: config.url);
  }

  @override
  DownloadFilenameGenerator downloadFilenameBuilder(BooruConfigAuth config) {
    return ref.read(moebooruDownloadFilenameGeneratorProvider(config));
  }

  @override
  TagExtractor tagExtractor(BooruConfigAuth config) {
    return ref.watch(moebooruTagExtractorProvider(config));
  }

  @override
  CommentRepository comment(BooruConfigAuth config) {
    return ref.watch(moebooruCommentRepoProvider(config));
  }

  @override
  BooruLoginDetails loginDetails(BooruConfigAuth config) {
    return ref.watch(moebooruLoginDetailsProvider(config));
  }

  @override
  DownloadSourceProvider? downloadSource(BooruConfigAuth config) {
    return const MoebooruDownloadSource();
  }
}
