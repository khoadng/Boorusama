// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:material_symbols_icons/symbols.dart';

// Project imports:
import 'package:boorusama/core/feats/posts/posts.dart';

class CommentPostButton extends StatelessWidget {
  const CommentPostButton({
    super.key,
    required this.post,
    this.onPressed,
  });

  final Post post;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      splashRadius: 16,
      onPressed: onPressed,
      icon: const Icon(
        Symbols.mode_comment,
      ),
    );
  }
}
