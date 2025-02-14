// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import '../../../premiums/providers.dart';
import 'saved_download_task_provider.dart';

final savedTaskLockProvider =
    AsyncNotifierProvider<SavedTaskLockNotifier, SavedTaskLockState>(
  SavedTaskLockNotifier.new,
);

final isSavedTaskLockedProvider = Provider.autoDispose.family<bool, String>(
  (ref, id) {
    final lock = ref.watch(savedTaskLockProvider);
    return lock.value?.isLocked(id) ?? false;
  },
);

class SavedTaskLockNotifier extends AsyncNotifier<SavedTaskLockState> {
  @override
  Future<SavedTaskLockState> build() async {
    final hasPremium = ref.watch(hasPremiumProvider);
    const state = SavedTaskLockState();

    // If user doesn't have premium, lock all saved tasks except the first one
    if (!hasPremium) {
      final tasks = await ref.watch(savedDownloadTasksProvider.future);
      if (tasks.length > 1) {
        return state.copyWith(
          lockedIds: tasks.skip(1).map((e) => e.task.id).toSet(),
        );
      }
    }

    return state;
  }

  Future<void> lockTask(String id) async {
    state = AsyncData(
      (await future).copyWith(
        lockedIds: {...state.value!.lockedIds, id},
      ),
    );
  }

  Future<void> unlockTask(String id) async {
    state = AsyncData(
      (await future).copyWith(
        lockedIds: state.value!.lockedIds.where((e) => e != id).toSet(),
      ),
    );
  }

  Future<void> unlockAll() async {
    state = const AsyncLoading();
    state = AsyncData(
      (await future).copyWith(lockedIds: {}),
    );
  }
}

class SavedTaskLockState {
  const SavedTaskLockState({
    this.lockedIds = const {},
  });

  final Set<String> lockedIds;

  bool isLocked(String id) => lockedIds.contains(id);

  SavedTaskLockState copyWith({
    Set<String>? lockedIds,
  }) {
    return SavedTaskLockState(
      lockedIds: lockedIds ?? this.lockedIds,
    );
  }
}
