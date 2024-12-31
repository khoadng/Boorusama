// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import '../../../core/configs/ref.dart';
import '../../../core/scaffolds/scaffolds.dart';
import 'comments.dart';

class GelbooruCommentPage extends ConsumerWidget {
  const GelbooruCommentPage({
    required this.postId,
    required this.useAppBar,
    super.key,
  });

  final int postId;
  final bool useAppBar;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final config = ref.watchConfigAuth;
    return CommentPageScaffold(
      postId: postId,
      useAppBar: useAppBar,
      fetcher: (postId) =>
          ref.watch(gelbooruCommentRepoProvider(config)).getComments(postId),
    );
  }
}
