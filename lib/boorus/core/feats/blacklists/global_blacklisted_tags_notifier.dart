// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import 'package:boorusama/boorus/core/feats/blacklists/blacklists.dart';
import 'package:boorusama/functional.dart';
import 'package:boorusama/widgets/widgets.dart';

class GlobalBlacklistedTagsNotifier extends Notifier<IList<BlacklistedTag>> {
  @override
  IList<BlacklistedTag> build() {
    getBlacklist();
    return <BlacklistedTag>[].lock;
  }

  GlobalBlacklistedTagRepository get repo =>
      ref.read(globalBlacklistedTagRepoProvider);

  Future<void> getBlacklist() async {
    final tags = await repo.getBlacklist();

    state = tags.lock;
  }

  Future<void> addTag(
    String tag, {
    void Function()? onSuccess,
    void Function()? onError,
  }) async {
    try {
      final newTag = await repo.addTag(tag);

      state = state.add(newTag);

      onSuccess?.call();
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
      final updatedTag = await repo.updateTag(oldTag.id, newTag);

      state = state.remove(oldTag).add(updatedTag);

      onSuccess?.call();
    } catch (e) {
      onError?.call();
    }
  }
}

extension GlobalBlacklistedTagsNotifierX on GlobalBlacklistedTagsNotifier {
  Future<void> addTagWithToast(String tag) async {
    await addTag(
      tag,
      onSuccess: () => showSuccessToast('Tag added'),
      onError: () => showErrorToast('Failed to add tag'),
    );
  }

  Future<void> removeTagWithToast(BlacklistedTag tag) async {
    await removeTag(
      tag,
      onSuccess: () => showSuccessToast('Tag removed'),
      onError: () => showErrorToast('Failed to remove tag'),
    );
  }
}
