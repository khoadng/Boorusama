// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import '../../../core/configs/ref.dart';
import '../../../core/scaffolds/scaffolds.dart';
import 'comments.dart';

class GelbooruV2CommentPage extends ConsumerWidget {
  const GelbooruV2CommentPage({
    super.key,
    required this.postId,
    required this.useAppBar,
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
          ref.watch(gelbooruV2CommentRepoProvider(config)).getComments(postId),
    );
  }
}
