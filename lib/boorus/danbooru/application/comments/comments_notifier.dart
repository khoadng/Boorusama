// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import 'package:boorusama/boorus/danbooru/application/comments/comments_provider.dart';
import 'package:boorusama/boorus/danbooru/domain/comments.dart';
import 'package:boorusama/core/provider.dart';

class CommentsNotifier
    extends AutoDisposeFamilyNotifier<List<CommentData>?, int> {
  @override
  List<CommentData>? build(int arg) {
    fetch();
    return null;
  }

  Future<void> fetch() async {
    state = await ref
        .watch(danbooruCommentRepoProvider)
        .getCommentsFromPostId(arg)
        .then(filterDeleted())
        .then(createCommentDataWith(
          ref.watch(currentBooruConfigRepoProvider),
          ref.watch(booruUserIdentityProviderProvider),
          ref.watch(danbooruCommentVoteRepoProvider),
        ))
        .then(sortDescendedById());
  }
}
