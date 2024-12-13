// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:foundation/foundation.dart';

// Project imports:
import '../../../foundation/toast.dart';
import '../data/providers.dart';
import '../types/blacklisted_tag.dart';
import '../types/blacklisted_tag_repository.dart';

final globalBlacklistedTagsProvider =
    NotifierProvider<GlobalBlacklistedTagsNotifier, IList<BlacklistedTag>>(
  GlobalBlacklistedTagsNotifier.new,
);

class GlobalBlacklistedTagsNotifier extends Notifier<IList<BlacklistedTag>> {
  @override
  IList<BlacklistedTag> build() {
    getBlacklist();
    return <BlacklistedTag>[].lock;
  }

  Future<GlobalBlacklistedTagRepository> get futureRepo =>
      ref.read(globalBlacklistedTagRepoProvider.future);

  Future<void> getBlacklist() async {
    final repo = await futureRepo;
    final tags = await repo.getBlacklist();

    state = tags.lock;
  }

  Future<void> addTag(
    String tag, {
    void Function()? onSuccess,
    void Function()? onError,
  }) async {
    try {
      final repo = await futureRepo;
      final newTag = await repo.addTag(tag);

      // If tag already exists, do nothing
      if (newTag == null) return;

      state = state.add(newTag);

      onSuccess?.call();
    } catch (e) {
      onError?.call();
    }
  }

  Future<void> addTagString(
    String tagString, {
    void Function(List<BlacklistedTag> tags)? onSuccess,
    void Function()? onError,
  }) async {
    try {
      final tags = sanitizeBlacklistTagString(tagString);

      if (tags == null) {
        onError?.call();
        return;
      }

      final newTags = <BlacklistedTag>[];

      final repo = await futureRepo;

      for (final tag in tags) {
        final newTag = await repo.addTag(tag);
        if (newTag != null) newTags.add(newTag);
      }

      state = state.addAll(newTags);

      onSuccess?.call(newTags);
    } catch (e) {
      onError?.call();
    }
  }

  Future<void> removeTag(
    BlacklistedTag tag, {
    void Function()? onSuccess,
    void Function()? onError,
  }) async {
    try {
      final repo = await futureRepo;
      await repo.removeTag(tag.id);

      state = state.remove(tag);

      onSuccess?.call();
    } catch (e) {
      onError?.call();
    }
  }

  Future<void> updateTag({
    required BlacklistedTag oldTag,
    required String newTag,
    void Function()? onSuccess,
    void Function()? onError,
  }) async {
    try {
      final repo = await futureRepo;
      final updatedTag = await repo.updateTag(oldTag.id, newTag);

      state = state.remove(oldTag).add(updatedTag);

      onSuccess?.call();
    } catch (e) {
      onError?.call();
    }
  }
}

extension GlobalBlacklistedTagsNotifierX on GlobalBlacklistedTagsNotifier {
  Future<void> addTagWithToast(BuildContext context, String tag) async {
    await addTag(
      tag,
      onSuccess: () => showSuccessToast(context, 'Tag added'),
      onError: () => showErrorToast(context, 'Failed to add tag'),
    );
  }

  Future<void> addTagStringWithToast(
    BuildContext context,
    String tagString,
  ) async {
    await addTagString(
      tagString,
      onSuccess: (tags) =>
          showSuccessToast(context, '${tags.length} tags added'),
      onError: () => showErrorToast(context, 'Failed to add tags'),
    );
  }

  Future<void> removeTagWithToast(
    BuildContext context,
    BlacklistedTag tag,
  ) async {
    await removeTag(
      tag,
      onSuccess: () => showSuccessToast(context, 'Tag removed'),
      onError: () => showErrorToast(context, 'Failed to remove tag'),
    );
  }
}
