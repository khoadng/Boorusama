// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import '../../../core/comments/comment.dart';
import '../../../core/comments/comment_header.dart';
import '../../../core/configs/config.dart';
import '../../../core/configs/ref.dart';
import '../../../core/dtext/dtext.dart';
import '../../../core/scaffolds/scaffolds.dart';

class E621CommentPage extends ConsumerWidget {
  const E621CommentPage({
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
      commentItemBuilder: (context, comment) => _CommentItem(
        comment: comment,
        config: config,
      ),
    );
  }
}

class _CommentItem extends StatelessWidget {
  const _CommentItem({
    required this.comment,
    required this.config,
  });

  final Comment comment;
  final BooruConfigAuth config;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CommentHeader(
          authorName: comment.creatorName == null
              ? comment.creatorId?.toString() ?? 'Anon'
              : comment.creatorName!,
          authorTitleColor: Theme.of(context).colorScheme.primary,
          createdAt: comment.createdAt,
        ),
        const SizedBox(height: 4),
        Dtext.parse(
          dtext(
            comment.body,
            booruUrl: config.url,
          ),
          '<blockquote>',
          '</blockquote>',
        ),
      ],
    );
  }
}
