// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import 'package:boorusama/core/blacklists/blacklists.dart';

class GlobalBlacklistedTagsNotifier extends Notifier<List<BlacklistedTag>> {
  @override
  List<BlacklistedTag> build() {
    getBlacklist();
    return [];
  }

  GlobalBlacklistedTagRepository get repo =>
      ref.read(globalBlacklistedTagRepoProvider);

  Future<void> getBlacklist() async {
    final tags = await repo.getBlacklist();

    state = tags;
  }

  Future<void> addTag(String tag) async {
    final value = await repo.addTag(tag);

    state = [...state, value];
  }

  Future<void> removeTag(BlacklistedTag tag) async {
    await repo.removeTag(tag.id);

    state = state.where((element) => element.id != tag.id).toList();
  }
}
