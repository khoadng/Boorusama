// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import '../../foundation/riverpod/riverpod_extended.dart';
import 'providers.dart';
import 'types.dart';

class ChangelogDataNotifier extends AsyncNotifier<ChangelogData> {
  Future<ChangelogRepository> get _repo =>
      ref.read(changelogRepositoryProvider.future);

  @override
  Future<ChangelogData> build() async {
    final repo = await _repo;
    return repo.loadLatestChangelog();
  }
}

class FullChangelogNotifier extends AutoDisposeAsyncNotifier<String> {
  Future<ChangelogRepository> get _repo =>
      ref.read(changelogRepositoryProvider.future);

  @override
  Future<String> build() async {
    ref.cacheFor(const Duration(seconds: 3));

    final repo = await _repo;
    return repo.loadFullChangelog();
  }
}

class ChangelogVisibilityNotifier extends AsyncNotifier<bool> {
  Future<ChangelogRepository> get _repo =>
      ref.read(changelogRepositoryProvider.future);

  @override
  Future<bool> build() async {
    final data = await ref.watch(changelogDataProvider.future);
    final repo = await _repo;

    return repo
        .shouldShowChangelog(data.version)
        // Something must be wrong if it takes too long, just don't show the dialog to prevent it suddenly appears later
        .timeout(
          const Duration(seconds: 2),
          onTimeout: () => false,
        );
  }

  Future<void> markAsSeen() async {
    final shouldShow = await future;

    if (!shouldShow) return;

    final data = await ref.read(changelogDataProvider.future);
    final repo = await _repo;
    await repo.markChangelogAsSeen(data.version);
    state = const AsyncData(false);
  }
}
