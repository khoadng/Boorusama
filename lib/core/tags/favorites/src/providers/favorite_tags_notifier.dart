// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:collection/collection.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import '../../../../../foundation/toast.dart';
import '../../../../search/selected_tags/tag.dart';
import '../types/favorite_tag.dart';
import 'providers.dart';

final favoriteTagsProvider =
    NotifierProvider<FavoriteTagsNotifier, List<FavoriteTag>>(
      FavoriteTagsNotifier.new,
      dependencies: [
        favoriteTagRepoProvider,
      ],
    );

final favoriteTagLabelsProvider = Provider<List<String>>((ref) {
  final tags = ref.watch(favoriteTagsProvider);
  final tagLabels = tags.expand((e) => e.labels ?? <String>[]).toSet();

  final labels = tagLabels.toList()..sort();

  return labels;
});

class FavoriteTagsNotifier extends Notifier<List<FavoriteTag>> {
  @override
  List<FavoriteTag> build() {
    load();
    return [];
  }

  Future<FavoriteTagRepository> get repo =>
      ref.read(favoriteTagRepoProvider.future);

  Future<void> load() async {
    final tags = await (await repo).getAll();

    state = tags..sort((a, b) => a.name.compareTo(b.name));
  }

  Future<void> add(
    String tag, {
    List<String>? labels,
    void Function(String tag)? onDuplicate,
    bool? isRaw,
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

    final repo = await this.repo;
    await repo.create(
      name: tag,
      labels: labels != null && labels.isNotEmpty
          ? labels.where((e) => e.isNotEmpty).toList()
          : null,
      queryType: isRaw == true ? QueryType.simple : null,
    );

    final tags = await repo.getAll();

    state = tags..sort((a, b) => a.name.compareTo(b.name));
  }

  Future<void> update(String tag, FavoriteTag newTag) async {
    if (tag.isEmpty) return;

    final repo = await this.repo;
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

    final repo = await this.repo;
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

    final repo = await this.repo;
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
    final repo = await this.repo;
    final tags = await repo.getAll();
    final tagString = tags.map((e) => e.name).join(' ');

    onDone(tagString);
  }

  Future<void> exportWithLabels({
    required BuildContext context,
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
            (l) => showErrorToast(context, l.toString()),
            (r) => showSuccessToast(context, 'Favorite tags exported to $path'),
          ),
        );
  }

  // exportWithLabels to raw string
  Future<String> exportWithLabelsToRawString() async {
    return ref
        .read(favoriteTagsIOHandlerProvider)
        .exportToRawString(state)
        .run()
        .then(
          (value) => value.fold(
            (l) => '',
            (r) => r,
          ),
        );
  }

  Future<void> importWithLabels({
    required BuildContext context,
    required String path,
  }) async {
    final repo = await this.repo;
    await ref
        .read(favoriteTagsIOHandlerProvider)
        .import(
          from: path,
        )
        .run()
        .then(
          (value) => value.fold(
            (l) => showErrorToast(context, l.toString()),
            (r) => repo
                .createFrom(r)
                .then(
                  (value) => load().then(
                    (_) {
                      if (context.mounted) {
                        showSuccessToast(
                          context,
                          'Favorite tags imported from $path',
                        );
                      }
                    },
                  ),
                ),
          ),
        );
  }

  Future<void> importWithLabelsFromRawString({
    required String text,
    BuildContext? context,
  }) async {
    final repo = await this.repo;
    await ref
        .read(favoriteTagsIOHandlerProvider)
        .importFromRawString(
          text: text,
        )
        .run()
        .then(
          (value) => value.fold(
            (l) =>
                context != null ? showErrorToast(context, l.toString()) : null,
            (r) => repo.createFrom(r).then((value) => load()),
          ),
        );
  }
}
