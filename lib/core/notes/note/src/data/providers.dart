// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import '../../../../boorus/engine/providers.dart';
import '../../../../configs/config/types.dart';
import '../types/note.dart';
import 'repo.dart';

final noteRepoProvider = Provider.family<NoteRepository, BooruConfigAuth>(
  (ref, config) {
    final repo = ref
        .watch(booruEngineRegistryProvider)
        .getRepository(config.booruType);

    final noteRepo = repo?.note(config);

    if (noteRepo != null) {
      return noteRepo;
    }

    return ref.watch(emptyNoteRepoProvider);
  },
);

final emptyNoteRepoProvider = Provider<NoteRepository>(
  (_) => const EmptyNoteRepository(),
);
