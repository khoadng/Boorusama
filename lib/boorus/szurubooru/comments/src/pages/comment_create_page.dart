// Flutter imports:
import 'package:flutter/widgets.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_symbols_icons/symbols.dart';

// Project imports:
import '../../../../../core/comments/widgets.dart';
import '../../../../../core/configs/config/providers.dart';
import '../../providers.dart';

class SzurubooruCommentCreatePage extends ConsumerWidget {
  const SzurubooruCommentCreatePage({
    required this.postId,
    super.key,
    this.initialContent,
  });

  final int postId;
  final String? initialContent;

  @override
  Widget build(context, ref) {
    final config = ref.watchConfigAuth;

    return CommentEditorPage(
      initialContent: initialContent,
      submitIcon: Symbols.send,
      onSubmit: (content) => ref
          .read(szurubooruCommentsProvider(config).notifier)
          .send(
            postId: postId,
            content: content,
          ),
    );
  }
}
