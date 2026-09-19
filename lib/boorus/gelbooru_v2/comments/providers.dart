// Package imports:
import 'package:booru_clients/gelbooru.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

// Project imports:
import '../../../core/comments/types.dart';
import '../../../core/configs/config/types.dart';
import '../client_provider.dart';
import '../gelbooru_v2_provider.dart';
import 'types.dart';

final gelbooruV2CommentActionClientProvider =
    Provider.family<GelbooruCommentActionClient?, BooruConfigAuth>(
      (ref, config) {
        final gelbooruV2 = ref.watch(gelbooruV2Provider);
        final actions = gelbooruV2
            .getCapabilitiesForSite(config.url)
            ?.comments
            ?.actions;

        if (actions?.containsKey(gelbooruV2CommentUpvoteAction) != true) {
          return null;
        }

        return GelbooruCommentActionClient(
          dio: ref.watch(gelbooruV2DioProvider(config)),
          baseUrl: config.url,
          userId: config.login,
          passHash: config.passHash,
          actions: actions!,
        );
      },
    );

final gelbooruV2SupportsCommentUpvoteProvider =
    Provider.family<bool, BooruConfigAuth>((ref, config) {
      final actionClient = ref.watch(
        gelbooruV2CommentActionClientProvider(config),
      );

      return actionClient?.supports(gelbooruV2CommentUpvoteAction) ?? false;
    });

final gelbooruV2CommentRepoProvider =
    Provider.family<CommentRepository<GelbooruV2Comment>, BooruConfigAuth>((
      ref,
      config,
    ) {
      final client = ref.watch(gelbooruV2ClientProvider(config));
      return CommentRepositoryBuilder<GelbooruV2Comment>(
        fetch: (postId, {page}) => client
            .getComments(
              postId: postId,
            )
            .then(
              (value) => value.comments
                  .map(gelboorucommentDtoToGelbooruComment)
                  .toList(),
            ),
        fetchPage: (postId, {required pageKey}) async {
          final result = await client.getComments(
            postId: postId,
            cursor: switch (pageKey) {
              CursorCommentPageKey(:final cursor) => cursor,
              _ => null,
            },
          );
          return CommentPage(
            items: result.comments
                .map(gelboorucommentDtoToGelbooruComment)
                .toList(),
            nextPageKey: switch (result.nextCursor) {
              final String cursor => CursorCommentPageKey(cursor),
              null => null,
            },
          );
        },
        create: (postId, body) async => false,
        update: (commentId, body) async => false,
        delete: (commentId) async => false,
      );
    });

GelbooruV2Comment gelboorucommentDtoToGelbooruComment(CommentDto dto) {
  final createdAt = _parseCommentDate(dto.createdAt);

  return GelbooruV2Comment(
    id: int.tryParse(dto.id ?? '') ?? 0,
    postId: int.tryParse(dto.postId ?? ''),
    body: dto.body ?? '',
    creatorName: dto.creator,
    creatorId: int.tryParse(dto.creatorId ?? ''),
    createdAt: createdAt,
    updatedAt: createdAt,
    score: dto.score,
  );
}

DateTime? _parseCommentDate(String? value) {
  if (value == null || value.isEmpty) return null;

  for (final format in [
    'yyyy-MM-dd HH:mm:ss',
    'yyyy-MM-dd HH:mm',
  ]) {
    final parsed = DateFormat(format).tryParseStrict(value);
    if (parsed != null) return parsed;
  }

  return null;
}
