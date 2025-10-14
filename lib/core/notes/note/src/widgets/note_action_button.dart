// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:foundation/foundation.dart';
import 'package:material_symbols_icons/symbols.dart';

// Project imports:
import '../../../../configs/config/types.dart';
import '../../../../posts/post/types.dart';
import '../../../../widgets/widgets.dart';
import '../providers/notes_controller_provider.dart';
import '../providers/notes_providers.dart';
import '../types/note.dart';

class NoteActionButtonWithProvider<T extends Post> extends ConsumerWidget {
  const NoteActionButtonWithProvider({
    required this.currentPost,
    required this.config,
    super.key,
  });

  final ValueNotifier<T> currentPost;
  final BooruConfigAuth config;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ValueListenableBuilder(
      valueListenable: currentPost,
      builder: (context, post, child) {
        final noteState = ref.watch(notesControllerProvider(post));
        final allNotes = ref.watch(notesProvider(config));
        final notes = allNotes[post.id] ?? const <Note>[].lock;

        if (allNotes.containsKey(post.id) && notes.isEmpty) {
          return const SizedBox.shrink();
        }

        return NoteActionButton(
          post: post,
          showDownload: notes.isEmpty,
          enableNotes: noteState.enableNotes,
          onDownload: () => ref.read(notesProvider(config).notifier).load(post),
          onToggleNotes: () => ref
              .read(notesControllerProvider(post).notifier)
              .toggleNoteVisibility(),
        );
      },
    );
  }
}

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
