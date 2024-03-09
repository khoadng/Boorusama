// Package imports:
import 'package:collection/collection.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import 'package:boorusama/core/feats/tags/tags.dart';
import 'package:boorusama/widgets/widgets.dart';

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

  Future<void> add(
    String tag, {
    List<String>? labels,
    void Function(String tag)? onDuplicate,
  }) async {
    if (tag.isEmpty) return;

    // If a tag length is larger than 255 characters, we will not add it.
    // This is a limitation of Hive.
    if (tag.length > 255) return;

    // check for existing tag
    final existing = state.firstWhereOrNull((e) => e.name == tag);

    if (existing != null) {
      onDuplicate?.call(existing.name);
      return;
    }

    await repo.create(
      name: tag,
      labels: labels != null && labels.isNotEmpty
          ? labels.where((e) => e.isNotEmpty).toList()
          : null,
    );

    final tags = await repo.getAll();

    state = tags..sort((a, b) => a.name.compareTo(b.name));
  }

  Future<void> update(String tag, FavoriteTag newTag) async {
    if (tag.isEmpty) return;

    final targetTag = await repo.getFirst(tag);

    if (targetTag != null) {
      await repo.updateFirst(
        tag,
        newTag.ensureValid(),
      );

      final tags = await repo.getAll();

      state = tags..sort((a, b) => a.name.compareTo(b.name));
    }
  }

  Future<void> remove(String name) async {
    if (name.isEmpty) return;

    final tag = await repo.getFirst(name);

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

  Future<void> exportWithLabels({
    required String path,
  }) async {
    await ref
        .read(favoriteTagsIOHandlerProvider)
        .export(
          state,
          to: path,
        )
        .run()
        .then(
          (value) => value.fold(
            (l) => showErrorToast(l.toString()),
            (r) => showSuccessToast('Favorite tags exported to $path'),
          ),
        );
  }

  Future<void> importWithLabels({
    required String path,
  }) async {
    await ref
        .read(favoriteTagsIOHandlerProvider)
        .import(
          from: path,
        )
        .run()
        .then(
          (value) => value.fold(
            (l) => showErrorToast(l.toString()),
            (r) => repo.createFrom(r).then((value) => load()),
          ),
        );
  }
}
