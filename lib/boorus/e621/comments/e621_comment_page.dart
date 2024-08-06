// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import 'package:boorusama/boorus/e621/e621.dart';
import 'package:boorusama/core/comments/comments.dart';
import 'package:boorusama/core/configs/configs.dart';
import 'package:boorusama/core/dtext/dtext.dart';
import 'package:boorusama/core/scaffolds/scaffolds.dart';
import 'package:boorusama/foundation/theme.dart';

class E621CommentPage extends ConsumerWidget {
  const E621CommentPage({
    super.key,
    required this.postId,
  });

  final int postId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final config = ref.watchConfig;
    final client = ref.watch(e621ClientProvider(config));

    return CommentPageScaffold(
      postId: postId,
      commentItemBuilder: (context, comment) => _CommentItem(
        comment: comment,
        config: config,
      ),
      fetcher: (id) => client.getComments(postId: postId, page: 1).then(
            (value) => value
                .map((e) => SimpleComment(
                      id: e.id ?? 0,
                      body: e.body ?? '',
                      createdAt: e.createdAt ?? DateTime(1),
                      updatedAt: e.updatedAt ?? DateTime(1),
                      creatorName: e.creatorName ?? '',
                      creatorId: e.creatorId ?? 0,
                    ))
                .toList(),
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
  final BooruConfig config;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CommentHeader(
          authorName: comment.creatorName == null
              ? comment.creatorId?.toString() ?? 'Anon'
              : comment.creatorName!,
          authorTitleColor: context.colorScheme.primary,
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
