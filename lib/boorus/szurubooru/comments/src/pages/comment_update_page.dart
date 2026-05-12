// Flutter imports:
import 'package:flutter/widgets.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import '../../../../../core/comments/widgets.dart';
import '../../../../../core/configs/config/providers.dart';
import '../../providers.dart';

class SzurubooruCommentUpdatePage extends ConsumerWidget {
  const SzurubooruCommentUpdatePage({
    required this.postId,
    required this.commentId,
    super.key,
    this.initialContent,
  });

  final int postId;
  final int commentId;
  final String? initialContent;

  @override
  Widget build(context, ref) {
    final config = ref.watchConfigAuth;

    return CommentEditorPage(
      initialContent: initialContent,
      onSubmit: (content) => ref
          .read(szurubooruCommentsProvider(config).notifier)
          .updateById(
            postId: postId,
            commentId: commentId,
            content: content,
          ),
    );
  }
}
