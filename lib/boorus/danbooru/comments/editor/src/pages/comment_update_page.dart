// Flutter imports:
import 'package:flutter/widgets.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import '../../../../../../core/comments/widgets.dart';
import '../../../../../../core/configs/config/providers.dart';
import '../../../comment/providers.dart';

class CommentUpdatePage extends ConsumerWidget {
  const CommentUpdatePage({
    required this.postId,
    required this.commentId,
    super.key,
    this.initialContent,
  });

  final int commentId;
  final String? initialContent;
  final int postId;

  @override
  Widget build(context, ref) {
    final config = ref.watchConfigAuth;

    return CommentEditorPage(
      initialContent: initialContent,
      onSubmit: (content) => ref
          .read(danbooruCommentsProvider(config).notifier)
          .update(
            postId: postId,
            commentId: commentId,
            content: content,
          ),
    );
  }
}
