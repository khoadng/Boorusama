// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import '../../../core/configs/config/providers.dart';
import '../../../core/notes/editor/types.dart';
import '../../../core/notes/editor/widgets.dart';
import '../client_provider.dart';
import '../posts/details/src/providers.dart';
import '../posts/post/types.dart';
import 'providers.dart';

class DanbooruNoteEditorPage extends ConsumerWidget {
  const DanbooruNoteEditorPage({
    super.key,
    required this.post,
  });

  final DanbooruPost post;

  String _buildSuccessMessage(NoteChangeset changeset) {
    final parts = <String>[];
    if (changeset.created.isNotEmpty) {
      parts.add('${changeset.created.length} created');
    }
    if (changeset.updated.isNotEmpty) {
      parts.add('${changeset.updated.length} updated');
    }
    if (changeset.deleted.isNotEmpty) {
      parts.add('${changeset.deleted.length} deleted');
    }

    if (parts.isEmpty) {
      return 'No changes';
    }

    return 'Notes saved: ${parts.join(', ')}';
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final auth = ref.watchConfigAuth;
    final viewer = ref.watchConfigViewer;
    final mediaUrlResolver = ref.watch(
      danbooruMediaUrlResolverProvider(auth),
    );

    final imageUrl = mediaUrlResolver.resolveMediaUrl(post, viewer);

    return ref
        .watch(danbooruInitialNotesProvider(post.id))
        .when(
          data: (initialNotes) => RawNoteEditorPage(
            image: NoteImage(
              width: post.width,
              height: post.height,
            ),
            initialNotes: initialNotes,
            imageBuilder: (constraints) => DefaultNoteEditImage(
              auth: auth,
              imageUrl: imageUrl,
              constraints: constraints,
            ),
            onSubmit: (changeset) async {
              final client = ref.read(
                danbooruClientProvider(ref.readConfigAuth),
              );

              var createdCount = 0;
              var updatedCount = 0;
              var deletedCount = 0;

              try {
                for (final note in changeset.created) {
                  await client.createNote(
                    postId: post.id,
                    x: note.x,
                    y: note.y,
                    width: note.width,
                    height: note.height,
                    body: note.body,
                  );
                  createdCount++;
                }

                for (final note in changeset.updated) {
                  await client.updateNote(
                    noteId: note.id!,
                    x: note.x,
                    y: note.y,
                    width: note.width,
                    height: note.height,
                    body: note.body,
                  );
                  updatedCount++;
                }

                for (final noteId in changeset.deleted) {
                  await client.deleteNote(noteId: noteId);
                  deletedCount++;
                }

                if (context.mounted) {
                  final message = _buildSuccessMessage(changeset);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(message),
                      duration: const Duration(seconds: 2),
                    ),
                  );
                  Navigator.of(context).pop();
                }
              } catch (e) {
                // Partial success - tell user what worked
                if (context.mounted) {
                  final successParts = <String>[];
                  if (createdCount > 0) {
                    successParts.add('$createdCount created');
                  }
                  if (updatedCount > 0) {
                    successParts.add('$updatedCount updated');
                  }
                  if (deletedCount > 0) {
                    successParts.add('$deletedCount deleted');
                  }

                  final message = successParts.isNotEmpty
                      ? 'Partial save (${successParts.join(', ')}). Reloading... Error: $e'
                      : 'Failed to save notes: $e';

                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(message),
                      backgroundColor: Colors.orange,
                      duration: const Duration(seconds: 5),
                    ),
                  );

                  if (successParts.isNotEmpty) {
                    Navigator.of(context).pop();
                  }
                  // On total failure: stay open for retry
                }
              }
            },
          ),
          loading: () => const Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          ),
          error: (error, _) => Scaffold(
            appBar: AppBar(
              title: const Text('Note Editor'),
            ),
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 64, color: Colors.red),
                  const SizedBox(height: 16),
                  Text('Failed to load notes: $error'),
                  const SizedBox(height: 24),
                  ElevatedButton.icon(
                    onPressed: () =>
                        ref.invalidate(danbooruInitialNotesProvider),
                    icon: const Icon(Icons.refresh),
                    label: const Text('Retry'),
                  ),
                ],
              ),
            ),
          ),
        );
  }
}
