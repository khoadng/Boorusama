// Package imports:
import 'package:booru_clients/moebooru.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import '../../core/boorus/engine/engine.dart';
import '../../core/comments/types.dart';
import '../../core/configs/config.dart';
import '../../core/configs/create/create.dart';
import '../../core/downloads/filename/types.dart';
import '../../core/http/providers.dart';
import '../../core/posts/post/post.dart';
import '../../core/posts/post/providers.dart';
import '../../core/search/queries/query.dart';
import '../../core/tags/autocompletes/types.dart';
import '../../core/tags/tag/tag.dart';
import 'autocompletes/providers.dart';
import 'comments/providers.dart';
import 'posts/providers.dart';
import 'posts/types.dart';
import 'tag_groups/providers.dart';
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
    final dio = ref.watch(dioProvider(config));

    return () => MoebooruClient(
          baseUrl: config.url,
          dio: dio,
          login: config.login,
          passwordHashed: config.apiKey,
        ).getPosts().then((value) => true);
  }

  @override
  TagQueryComposer tagComposer(BooruConfigSearch config) {
    return LegacyTagQueryComposer(config: config);
  }

  @override
  PostLinkGenerator postLinkGenerator(BooruConfigAuth config) {
    return ShowPostLinkGenerator(baseUrl: config.url);
  }

  @override
  DownloadFilenameGenerator downloadFilenameBuilder(BooruConfigAuth config) {
    final tagRepo = ref.watch(moebooruTagRepoProvider(config));

    return DownloadFileNameBuilder<MoebooruPost>(
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
              final tags = await tagRepo.getTagsByName(post.tags.toSet(), 1);
              return tags
                  .map((tag) => (name: tag.name, type: tag.category.name))
                  .toList();
            },
          ),
        ),
      ],
    );
  }

  @override
  TagGroupRepository<Post> tagGroup(BooruConfigAuth config) {
    return ref.watch(moebooruTagGroupRepoProvider(config));
  }

  @override
  CommentRepository comment(BooruConfigAuth config) {
    return ref.watch(moebooruCommentRepoProvider(config));
  }
}
