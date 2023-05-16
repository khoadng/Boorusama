// Package imports:
import 'package:collection/collection.dart';
import 'package:equatable/equatable.dart';

// Project imports:
import 'package:boorusama/boorus/danbooru/domain/comments.dart';
import 'package:boorusama/boorus/danbooru/domain/users.dart';
import 'package:boorusama/core/application/application.dart';
import 'package:boorusama/core/application/booru_user_identity_provider.dart';
import 'package:boorusama/core/domain/boorus.dart';

enum CommentVoteState {
  unvote,
  downvoted,
  upvoted,
}

const youtubeUrl = 'www.youtube.com';

class CommentData extends Equatable {
  const CommentData({
    required this.id,
    required this.authorName,
    required this.authorLevel,
    required this.authorId,
    required this.body,
    required this.createdAt,
    required this.updatedAt,
    required this.isSelf,
    required this.recentlyUpdated,
    required this.uris,
  });

  final int id;
  final String authorName;
  final UserLevel authorLevel;
  final UserId authorId;
  final String body;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool isSelf;
  final bool recentlyUpdated;
  final List<Uri> uris;

  @override
  List<Object?> get props => [
        id,
        authorName,
        authorLevel,
        authorId,
        body,
        createdAt,
        updatedAt,
        isSelf,
        recentlyUpdated,
        uris,
      ];
}

List<CommentData> Function(List<CommentData> comments) sortDescendedById() =>
    (comments) => comments..sort((a, b) => a.id.compareTo(b.id));

CommentData Function(Comment comment) createCommentData({
  required int? accountId,
}) =>
    (comment) => commentDataFrom(comment, comment.creator, accountId);

Future<List<CommentData>> Function(
    List<Comment> comments) createCommentDataWith(
  CurrentBooruConfigRepository currentBooruConfigRepository,
  BooruUserIdentityProvider booruUserIdentityProvider,
) =>
    (comments) async {
      final config = await currentBooruConfigRepository.get();
      final id = await booruUserIdentityProvider.getAccountIdFromConfig(config);

      return comments
          .map(createCommentData(
            accountId: id,
          ))
          .toList();
    };

CommentData commentDataFrom(
  Comment comment,
  User? user,
  int? accountId,
) =>
    CommentData(
      id: comment.id,
      authorName: user?.name ?? 'User',
      authorLevel: user?.level ?? UserLevel.member,
      authorId: user?.id ?? 0,
      body: comment.body,
      createdAt: comment.createdAt,
      updatedAt: comment.updatedAt,
      isSelf: comment.creator?.id == accountId,
      recentlyUpdated: comment.createdAt != comment.updatedAt,
      uris: RegExp(urlPattern)
          .allMatches(comment.body)
          .map((match) {
            try {
              final url = comment.body.substring(match.start, match.end);

              return Uri.parse(url);
            } catch (e) {
              return null;
            }
          })
          .whereNotNull()
          .where((e) => e.host.contains(youtubeUrl))
          .toList(),
    );
