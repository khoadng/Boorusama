// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:i18n/i18n.dart';

// Project imports:
import '../../../configs/config/providers.dart';
import '../../../widgets/widgets.dart';
import '../types/comment.dart';
import '../widgets/comment_item.dart';

class SimpleCommentPageScaffold extends ConsumerWidget {
  const SimpleCommentPageScaffold({
    required this.comments,
    required this.useAppBar,
    super.key,
    this.commentItemBuilder,
  });

  final List<Comment> comments;
  final Widget Function(BuildContext context, Comment comment)?
  commentItemBuilder;
  final bool useAppBar;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final config = ref.watchConfigAuth;

    return Scaffold(
      appBar: useAppBar
          ? AppBar(
              title: Text(context.t.comment.comments),
            )
          : null,
      body: comments.isEmpty
          ? const Center(child: NoDataBox())
          : Padding(
              padding: const EdgeInsetsDirectional.symmetric(horizontal: 12),
              child: ListView.builder(
                itemCount: comments.length,
                itemBuilder: (context, index) {
                  final comment = comments[index];
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: commentItemBuilder != null
                        ? commentItemBuilder!(context, comment)
                        : CommentItem(
                            comment: comment,
                            config: config,
                          ),
                  );
                },
              ),
            ),
    );
  }
}
