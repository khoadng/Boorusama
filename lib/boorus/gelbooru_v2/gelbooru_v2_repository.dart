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
import '../../core/posts/post/post.dart';
import '../../core/posts/post/providers.dart';
import '../../core/search/queries/query.dart';
import '../../core/tags/autocompletes/types.dart';
import '../../core/tags/tag/tag.dart';
import 'client_provider.dart';
import 'comments/providers.dart';
import 'notes/providers.dart';
import 'posts/providers.dart';
import 'posts/types.dart';
import 'syntax/providers.dart';
import 'tags/providers.dart';

class GelbooruV2Repository extends BooruRepositoryDefault {
  const GelbooruV2Repository({required this.ref});

  @override
  final Ref ref;

  @override
  PostRepository<Post> post(BooruConfigSearch config) {
    return ref.read(gelbooruV2PostRepoProvider(config));
  }

  @override
  AutocompleteRepository autocomplete(BooruConfigAuth config) {
    return ref.read(gelbooruV2AutocompleteRepoProvider(config));
  }

  @override
  NoteRepository note(BooruConfigAuth config) {
    return ref.read(gelbooruV2NoteRepoProvider(config));
  }

  @override
  BooruSiteValidator? siteValidator(BooruConfigAuth config) {
    final dio = ref.watch(dioProvider(config));

    return () => GelbooruV2Client(
          baseUrl: config.url,
          dio: dio,
          userId: config.login,
          apiKey: config.apiKey,
        ).getPosts().then((value) => true);
  }

  @override
  TagQueryComposer tagComposer(BooruConfigSearch config) {
    return GelbooruV2TagQueryComposer(config: config);
  }

  @override
  PostLinkGenerator postLinkGenerator(BooruConfigAuth config) {
    return IndexPhpPostLinkGenerator(baseUrl: config.url);
  }

  @override
  TextMatcher? queryMatcher(BooruConfigAuth config) {
    return ref.watch(gelbooruV2QueryMatcherProvider);
  }

  @override
  DownloadFilenameGenerator downloadFilenameBuilder(BooruConfigAuth config) {
    final client = ref.watch(gelbooruV2ClientProvider(config));

    return DownloadFileNameBuilder<GelbooruV2Post>(
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
              final tags = await client.getTagsFromPostId(postId: post.id);
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
    return ref.watch(gelbooruV2TagGroupRepoProvider(config));
  }

  @override
  CommentRepository comment(BooruConfigAuth config) {
    return ref.watch(gelbooruV2CommentRepoProvider(config));
  }
}
