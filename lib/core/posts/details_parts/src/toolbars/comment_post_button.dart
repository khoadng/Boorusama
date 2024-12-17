// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:material_symbols_icons/symbols.dart';

class CommentPostButton extends StatelessWidget {
  const CommentPostButton({
    super.key,
    this.onPressed,
  });

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
