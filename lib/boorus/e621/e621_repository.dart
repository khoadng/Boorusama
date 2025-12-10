// Package imports:
import 'package:booru_clients/e621.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import '../../core/boorus/defaults/types.dart';
import '../../core/comments/types.dart';
import '../../core/configs/config/types.dart';
import '../../core/configs/create/create.dart';
import '../../core/downloads/filename/types.dart';
import '../../core/downloads/urls/types.dart';
import '../../core/http/client/providers.dart';
import '../../core/notes/note/types.dart';
import '../../core/posts/details/types.dart';
import '../../core/posts/favorites/types.dart';
import '../../core/posts/post/providers.dart';
import '../../core/posts/post/types.dart';
import '../../core/search/queries/providers.dart';
import '../../core/search/queries/types.dart';
import '../../core/tags/autocompletes/types.dart';
import '../../core/tags/tag/colors.dart';
import '../../core/tags/tag/types.dart';
import 'comments/providers.dart';
import 'configs/providers.dart';
import 'downloads/providers.dart';
import 'favorites/providers.dart';
import 'notes/providers.dart';
import 'posts/providers.dart';
import 'tags/color.dart';
import 'tags/providers.dart';

class E621Repository extends BooruRepositoryDefault {
  const E621Repository({required this.ref});

  @override
  final Ref ref;

  @override
  PostRepository<Post> post(BooruConfigSearch config) {
    return ref.read(e621PostRepoProvider(config));
  }

  @override
  AutocompleteRepository autocomplete(BooruConfigAuth config) {
    return ref.read(e621AutocompleteRepoProvider(config));
  }

  @override
  NoteRepository note(BooruConfigAuth config) {
    return ref.read(e621NoteRepoProvider(config));
  }

  @override
  TagRepository tag(BooruConfigAuth config) {
    return ref.read(e621TagRepoProvider(config));
  }

  @override
  FavoriteRepository favorite(BooruConfigAuth config) {
    return ref.watch(e621FavoriteRepoProvider(config));
  }

  @override
  BooruSiteValidator? siteValidator(BooruConfigAuth config) {
    final dio = ref.watch(defaultDioProvider(config));

    return () => E621Client(
      baseUrl: config.url,
      dio: dio,
      login: config.login,
      apiKey: config.apiKey,
    ).getPosts().then((value) => true);
  }

  @override
  TagQueryComposer tagComposer(BooruConfigSearch config) {
    return ref.watch(legacyTagQueryComposerProvider(config));
  }

  @override
  PostLinkGenerator postLinkGenerator(BooruConfigAuth config) {
    return PluralPostLinkGenerator(baseUrl: config.url);
  }

  @override
  TagColorGenerator tagColorGenerator() {
    return const E621TagColorGenerator();
  }

  @override
  DownloadFilenameGenerator downloadFilenameBuilder(BooruConfigAuth config) {
    return ref.read(e621DownloadFilenameGeneratorProvider(config));
  }

  @override
  TagExtractor tagExtractor(BooruConfigAuth config) {
    return ref.watch(e621TagExtractorProvider(config));
  }

  @override
  CommentRepository comment(BooruConfigAuth config) {
    return ref.watch(e621CommentRepoProvider(config));
  }

  @override
  BooruLoginDetails loginDetails(BooruConfigAuth config) {
    return ref.watch(e621LoginDetailsProvider(config));
  }

  @override
  MediaUrlResolver mediaUrlResolver(BooruConfigAuth config) {
    return ref.watch(e621MediaUrlResolverProvider);
  }

  @override
  DownloadSourceProvider? downloadSource(BooruConfigAuth config) {
    return const E621DownloadSource();
  }
}
