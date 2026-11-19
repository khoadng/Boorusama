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
import 'pagination.dart';
import 'types.dart';

final gelbooruPostRepoProvider =
    Provider.family<PostRepository<GelbooruPost>, BooruConfigSearch>(
      (ref, config) {
        final client = ref.watch(gelbooruClientProvider(config.auth));
        final tagComposer = ref.watch(gelbooruTagQueryComposerProvider(config));
        final cursors = GelbooruPageCursors();

        return PostRepositoryBuilder(
          tagComposer: tagComposer,
          fetch: (tags, page, {limit, options}) => client.getPostResults(
            tags,
            page,
            limit: limit,
            options: options,
            cursors: cursors,
          ),
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
    GelbooruPageCursors? cursors,
  }) async {
    final useCursor = options?.useCursor ?? false;
    if ((useCursor, cursors, GelbooruIdPagination.fromTags(tags)) case (
      false,
      final cursors?,
      final pagination?,
    )) {
      return _getDeepPostResults(
        tags,
        page,
        limit: limit ?? _kGelbooruDefaultLimit,
        cursors: cursors,
        pagination: pagination,
      );
    }

    final pagination = useCursor ? GelbooruIdPagination.fromTags(tags) : null;
    final cursor = options?.cursor;
    final requestTags = pagination != null && cursor != null
        ? pagination.tagsAfter(cursor)
        : tags;

    if (requestTags == null) {
      return <GelbooruPost>[].toResult();
    }

    final value = await getPosts(
      tags: requestTags,
      page: pagination != null ? 1 : page,
      limit: limit,
    );

    final nextCursor = pagination != null ? value.lastId : null;
    if (pagination != null) {
      var previousId = cursor;
      for (final post in value.posts) {
        final id = post.id;
        if (id == null ||
            (previousId != null &&
                (pagination.ascending ? id <= previousId : id >= previousId))) {
          throw const FormatException('Gelbooru pagination did not advance');
        }
        previousId = id;
      }
      if (nextCursor != null &&
          cursor != null &&
          (pagination.ascending
              ? nextCursor <= cursor
              : nextCursor >= cursor)) {
        throw const FormatException('Gelbooru pagination did not advance');
      }
    }

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
          nextCursor: nextCursor,
        );
  }

  Future<PostResult<GelbooruPost>> _getDeepPostResults(
    List<String> tags,
    int page, {
    required int limit,
    required GelbooruPageCursors cursors,
    required GelbooruIdPagination pagination,
  }) async {
    final target = await cursors.locate(
      tags: tags,
      pagination: pagination,
      page: page,
      limit: limit,
      lastIdOf: (tags, page) async =>
          (await getPosts(tags: tags, page: page, limit: limit)).lastId,
      probe: (tags) async {
        final value = await getPosts(tags: tags, page: 1, limit: 1);
        return (
          count: value.count ?? 0,
          firstId: value.posts.firstOrNull?.id,
        );
      },
    );
    if (target == null) return <GelbooruPost>[].toResult();

    final value = await getPosts(
      tags: target.tags,
      page: target.page,
      limit: limit,
    );
    cursors.record(tags: tags, page: page, limit: limit, lastId: value.lastId);

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
          total: switch (value.count) {
            final count? => count + target.skipped,
            null => null,
          },
        );
  }
}

const _kGelbooruDefaultLimit = 100;

final gelbooruUploaderQueryProvider =
    Provider.family<UploaderQuery?, GelbooruPost>((ref, post) {
      return switch (post.uploaderName) {
        final uploader? => UserColonUploaderQuery(uploader),
        _ => null,
      };
    });
