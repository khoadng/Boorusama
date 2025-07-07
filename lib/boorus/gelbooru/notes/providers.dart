// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import '../../../core/configs/config/types.dart';
import '../../../core/notes/notes.dart';
import '../client_provider.dart';
import 'parser.dart';

final gelbooruNoteRepoProvider =
    Provider.family<NoteRepository, BooruConfigAuth>((ref, config) {
      final client = ref.watch(gelbooruClientProvider(config));

      return NoteRepositoryBuilder(
        fetch: (postId) => client
            .getNotesFromPostId(
              postId: postId,
            )
            .then((value) => value.map(gelbooruNoteToNote).toList()),
      );
    });
