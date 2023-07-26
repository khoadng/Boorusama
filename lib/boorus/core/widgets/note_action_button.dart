// Flutter imports:
import 'package:flutter/material.dart' hide ThemeMode;

// Package imports:
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

// Project imports:
import 'package:boorusama/boorus/core/feats/posts/posts.dart';
import 'package:boorusama/foundation/theme/theme.dart';
import 'package:boorusama/widgets/circular_icon_button.dart';

class NoteActionButton extends StatelessWidget {
  const NoteActionButton({
    super.key,
    required this.post,
    required this.showDownload,
    required this.enableNotes,
    required this.onDownload,
    required this.onToggleNotes,
  });

  final Post post;
  final bool showDownload;
  final bool enableNotes;
  final VoidCallback onDownload;
  final VoidCallback onToggleNotes;

  @override
  Widget build(BuildContext context) {
    if (!post.isTranslated) return const SizedBox.shrink();

    if (showDownload) {
      return ElevatedButton.icon(
        style: ElevatedButton.styleFrom(
          backgroundColor: context.colorScheme.background.withOpacity(0.8),
          padding: const EdgeInsets.all(4),
        ),
        icon: const Icon(Icons.download_rounded),
        label: const Text('Notes'),
        onPressed: onDownload,
      );
    }

    return CircularIconButton(
      icon: enableNotes
          ? Padding(
              padding: const EdgeInsets.all(3),
              child: FaIcon(
                FontAwesomeIcons.eyeSlash,
                size: 18,
                color: context.themeMode.isLight
                    ? context.colorScheme.onPrimary
                    : null,
              ),
            )
          : Padding(
              padding: const EdgeInsets.all(4),
              child: FaIcon(
                FontAwesomeIcons.eye,
                size: 18,
                color: context.themeMode.isLight
                    ? context.colorScheme.onPrimary
                    : null,
              ),
            ),
      onPressed: onToggleNotes,
    );
  }
}
