// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import 'providers.dart';
import 'user_metatag_repository.dart';

final danbooruUserMetatagsProvider =
    AsyncNotifierProvider<UserMetatagsNotifier, List<String>>(
      UserMetatagsNotifier.new,
      dependencies: [
        danbooruUserMetatagRepoProvider,
      ],
    );

class UserMetatagsNotifier extends AsyncNotifier<List<String>> {
  @override
  Future<List<String>> build() async {
    final repo = await _repoFuture;
    return repo.getAll();
  }

  Future<UserMetatagRepository> get _repoFuture =>
      ref.watch(danbooruUserMetatagRepoProvider.future);

  Future<void> add(String tag) async {
    final repo = await _repoFuture;
    await repo.put(tag);
    final tags = repo.getAll();

    state = AsyncValue.data(tags);
  }

  Future<void> delete(String tag) async {
    final repo = await _repoFuture;
    await repo.delete(tag);
    final tags = repo.getAll();
    state = AsyncValue.data(tags);
  }
}
