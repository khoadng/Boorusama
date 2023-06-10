// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import 'package:boorusama/boorus/core/feats/tags/tags.dart';
import 'package:boorusama/utils/collection_utils.dart';

class FavoriteTagsNotifier extends Notifier<List<FavoriteTag>> {
  @override
  List<FavoriteTag> build() {
    load();
    return [];
  }

  FavoriteTagRepository get repo => ref.read(favoriteTagRepoProvider);

  Future<void> load() async {
    final tags = await repo.getAll();

    state = tags..sort((a, b) => a.name.compareTo(b.name));
  }

  Future<void> add(String tag) async {
    if (tag.isEmpty) return;

    await repo.create(name: tag);

    final tags = await repo.getAll();

    state = tags..sort((a, b) => a.name.compareTo(b.name));
  }

  Future<void> remove(int index) async {
    final tag = state.getOrNull(index);

    if (tag != null) {
      final deleted = await repo.deleteFirst(tag.name);

      if (deleted != null) {
        final tags = await repo.getAll();

        state = tags..sort((a, b) => a.name.compareTo(b.name));
      }
    }
  }

  Future<void> import(String tagString) async {
    if (tagString.isEmpty) return;

    final tags = tagString.split(' ');
    for (final t in tags) {
      await repo.create(name: t);
    }

    final newTags = await repo.getAll();

    state = newTags;
  }

  Future<void> export({
    required void Function(String tagString) onDone,
  }) async {
    final tags = await repo.getAll();
    final tagString = tags.map((e) => e.name).join(' ');

    onDone(tagString);
  }
}
