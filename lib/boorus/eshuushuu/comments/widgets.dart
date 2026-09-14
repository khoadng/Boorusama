// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:foundation/foundation.dart';
import 'package:i18n/i18n.dart';
import 'package:kurumi/kurumi.dart';
import 'package:kurumi/material.dart';

// Project imports:
import '../../../core/comments/types.dart';
import '../../../core/comments/widgets.dart';
import '../../../core/developer_options/blocked_media_placeholder.dart';
import '../../../core/developer_options/providers.dart';
import '../../../foundation/html.dart';
import 'types.dart';

class EshuushuuCommentPage extends StatelessWidget {
  const EshuushuuCommentPage({
    required this.postId,
    required this.useAppBar,
    super.key,
  });

  final int postId;
  final bool useAppBar;

  @override
  Widget build(BuildContext context) {
    return CommentPageScaffold(
      postId: postId,
      useAppBar: useAppBar,
      singlePage: false,
      commentsTransformer: _buildThreadedComments,
      commentItemBuilder: (context, comment) => switch (comment) {
        final EshuushuuComment c => _EshuushuuCommentItem(comment: c),
        _ => const SizedBox.shrink(),
      },
    );
  }
}

List<Comment> _buildThreadedComments(List<Comment> comments) {
  final eshuushuuComments = comments.whereType<EshuushuuComment>().toList();
  final roots = <EshuushuuComment>[];
  final repliesByParent = <int, List<EshuushuuComment>>{};

  for (final comment in eshuushuuComments) {
    if (comment.parentCommentId case final parentId?) {
      repliesByParent.putIfAbsent(parentId, () => []).add(comment);
    } else {
      roots.add(comment);
    }
  }

  roots.sort(
    (a, b) =>
        (a.createdAt ?? DateTime(0)).compareTo(b.createdAt ?? DateTime(0)),
  );

  final result = <Comment>[];
  for (final root in roots) {
    result.add(root);
    if (repliesByParent[root.id] case final replies?) {
      replies.sort(
        (a, b) =>
            (a.createdAt ?? DateTime(0)).compareTo(b.createdAt ?? DateTime(0)),
      );
      result.addAll(replies);
    }
  }

  return result;
}

class _EshuushuuCommentItem extends ConsumerWidget {
  const _EshuushuuCommentItem({required this.comment});

  final EshuushuuComment comment;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colorScheme = Kurumi.themeOf(context).colorScheme;
    final automaticMediaLoadingEnabled = ref.watch(
      automaticMediaLoadingEnabledProvider,
    );

    return Padding(
      padding: EdgeInsets.only(left: comment.isReply ? 16 : 0),
      child: IntrinsicHeight(
        child: Row(
          children: [
            if (comment.isReply)
              Container(
                width: 2,
                margin: const EdgeInsets.only(right: 12),
                decoration: BoxDecoration(
                  color: colorScheme.outlineVariant,
                  borderRadius: BorderRadius.circular(1),
                ),
              ),
            Expanded(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: colorScheme.surfaceContainerHighest,
                      borderRadius: BorderRadius.circular(6),
                      image: switch ((
                        automaticMediaLoadingEnabled,
                        comment.creatorAvatarUrl,
                      )) {
                        (true, final String url) => DecorationImage(
                          image: NetworkImage(url),
                          fit: BoxFit.cover,
                        ),
                        _ => null,
                      },
                    ),
                    child: switch ((
                      automaticMediaLoadingEnabled,
                      comment.creatorAvatarUrl,
                    )) {
                      (false, final String _) =>
                        const BlockedMediaPlaceholder(),
                      (_, null) => Center(
                        child: Text(
                          (comment.creatorName ?? '?').isNotEmpty
                              ? comment.creatorName![0].toUpperCase()
                              : '?',
                          style: TextStyle(
                            fontSize: 14,
                            color: colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ),
                      _ => null,
                    },
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              comment.creatorName ?? 'Anonymous'.hc,
                              style: TextStyle(
                                color: colorScheme.primary,
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(width: 6),
                            if (comment.createdAt case final date?)
                              Text(
                                date.fuzzify(
                                  locale: Localizations.localeOf(context),
                                ),
                                style: TextStyle(
                                  color: colorScheme.hintColor,
                                  fontSize: 11,
                                ),
                              ),
                            if (comment.isEdited) ...[
                              const SizedBox(width: 4),
                              Text(
                                '(edited)'.hc,
                                style: TextStyle(
                                  color: colorScheme.hintColor,
                                  fontSize: 11,
                                  fontStyle: FontStyle.italic,
                                ),
                              ),
                            ],
                          ],
                        ),
                        const SizedBox(height: 2),
                        AppHtml(data: comment.body),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
