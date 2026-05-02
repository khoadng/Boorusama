// Package imports:
import 'package:booru_clients/gelbooru.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import '../../../core/configs/config/types.dart';
import '../../../core/posts/details/types.dart';
import '../../../core/posts/post/providers.dart';
import '../../../core/posts/post/types.dart';
import '../../../core/settings/providers.dart';
import '../client_provider.dart';
import '../tags/providers.dart';
import 'parser.dart';
import 'types.dart';

const _gelbooruSearchDepthLimit = 40000;

final gelbooruPostRepoProvider =
    Provider.family<PostRepository<GelbooruPost>, BooruConfigSearch>(
      (ref, config) {
        final client = ref.watch(gelbooruClientProvider(config.auth));
        final tagComposer = ref.watch(gelbooruTagQueryComposerProvider(config));

        return PostRepositoryBuilder(
          tagComposer: tagComposer,
          fetch: client.getPostResults,
          fetchSingle: (id, {options}) async {
            final numericId = id as NumericPostId?;

            if (numericId == null) return Future.value();

            final post = await client.getPost(numericId.value);

            return post != null
                ? gelbooruPostDtoToGelbooruPost(post, null)
                : null;
          },
          getSettings: () async => ref.read(imageListingSettingsProvider),
        );
      },
    );

extension GelbooruClientX on GelbooruClient {
  Future<PostResult<GelbooruPost>> getPostResults(
    List<String> tags,
    int page, {
    int? limit,
    PostFetchOptions? options,
  }) async {
    final maxPage = _gelbooruMaxAccessiblePage(limit);

    if (maxPage != null && page > maxPage) {
      return <GelbooruPost>[].toResult(maxPage: maxPage);
    }

    final value = await getPosts(
      tags: tags,
      page: page,
      limit: limit,
    );

    return value.posts
        .map(
          (e) => gelbooruPostDtoToGelbooruPost(
            e,
            PostMetadata(
              page: page,
              search: tags.join(' '),
              limit: limit,
            ),
          ),
        )
        .toList()
        .toResult(
          total: value.count,
          maxPage: maxPage,
        );
  }
}

int? _gelbooruMaxAccessiblePage(int? limit) {
  if (limit == null || limit <= 0) return null;

  return (_gelbooruSearchDepthLimit - 1) ~/ limit;
}

final gelbooruUploaderQueryProvider =
    Provider.family<UploaderQuery?, GelbooruPost>((ref, post) {
      return switch (post.uploaderName) {
        final uploader? => UserColonUploaderQuery(uploader),
        _ => null,
      };
    });
