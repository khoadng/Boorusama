// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:material_symbols_icons/symbols.dart';

// Project imports:
import '../../posts/post/post.dart';
import '../../widgets/circular_icon_button.dart';

class NoteActionButton<T extends Post> extends StatelessWidget {
  const NoteActionButton({
    required this.post,
    required this.showDownload,
    required this.enableNotes,
    required this.onDownload,
    required this.onToggleNotes,
    super.key,
  });

  final T post;
  final bool showDownload;
  final bool enableNotes;
  final VoidCallback onDownload;
  final VoidCallback onToggleNotes;

  @override
  Widget build(BuildContext context) {
    if (!post.isTranslated) return const SizedBox.shrink();

    if (showDownload) {
      return CircularIconButton(
        icon: const FaIcon(
          Symbols.translate,
        ),
        onPressed: onDownload,
      );
    }

    return CircularIconButton(
      icon: enableNotes
          ? const Icon(
              FontAwesomeIcons.eyeSlash,
              size: 18,
            )
          : const Icon(
              FontAwesomeIcons.eye,
              size: 18,
            ),
      onPressed: onToggleNotes,
    );
  }
}
