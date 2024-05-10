// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import 'package:boorusama/boorus/danbooru/danbooru_provider.dart';
import 'package:boorusama/boorus/danbooru/feats/users/users.dart';
import 'package:boorusama/core/feats/boorus/boorus.dart';
import 'package:boorusama/foundation/i18n.dart';
import 'package:boorusama/widgets/toast.dart';

class BlacklistedTagsNotifier
    extends FamilyNotifier<List<String>?, BooruConfig> {
  @override
  List<String>? build(BooruConfig arg) {
    final user = ref.watch(danbooruCurrentUserProvider(arg)).value;

    if (user == null) return null;

    return user.blacklistedTags.toList();
  }

  Future<void> add({
    required String tag,
    void Function(List<String> tags)? onSuccess,
    void Function(Object e)? onFailure,
  }) async {
    final user = await ref.read(danbooruCurrentUserProvider(arg).future);

    if (state == null || user == null) {
      onFailure?.call('Not logged in or no blacklisted tags found');

      return;
    }

    // Duplicate tags are not allowed
    final tags = {...state!, tag}.toList();

    try {
      await ref.read(danbooruClientProvider(arg)).setBlacklistedTags(
            id: user.id,
            blacklistedTags: tags,
          );

      onSuccess?.call(tags);

      state = tags;
    } catch (e) {
      onFailure?.call(e);
    }
  }

  // remove a tag
  Future<void> remove({
    required String tag,
    void Function(List<String> tags)? onSuccess,
    void Function()? onFailure,
  }) async {
    final user = await ref.read(danbooruCurrentUserProvider(arg).future);

    if (state == null || user == null) {
      onFailure?.call();

      return;
    }

    final tags = [...state!]..remove(tag);

    try {
      await ref
          .read(danbooruClientProvider(arg))
          .setBlacklistedTags(id: user.id, blacklistedTags: tags);

      onSuccess?.call(tags);

      state = tags;
    } catch (e) {
      onFailure?.call();
    }
  }

  // replace a tag
  Future<void> replace({
    required String oldTag,
    required String newTag,
    void Function(List<String> tags)? onSuccess,
    void Function(String message)? onFailure,
  }) async {
    final user = await ref.read(danbooruCurrentUserProvider(arg).future);

    if (state == null || user == null) {
      onFailure?.call('Fail to replace tag');

      return;
    }

    final tags = [
      ...[...state!]..remove(oldTag),
      newTag,
    ];

    try {
      await ref
          .read(danbooruClientProvider(arg))
          .setBlacklistedTags(id: user.id, blacklistedTags: tags);

      onSuccess?.call(tags);

      state = tags;
    } catch (e) {
      onFailure?.call('Fail to replace tag');
    }
  }
}

extension BlacklistedTagsNotifierX on BlacklistedTagsNotifier {
  Future<void> addWithToast({
    required String tag,
  }) =>
      add(
        tag: tag,
        onSuccess: (tags) => showSuccessToast('blacklisted_tags.updated'.tr()),
        onFailure: (e) =>
            showErrorToast('${'blacklisted_tags.failed_to_add'.tr()}\n$e'),
      );

  Future<void> removeWithToast({
    required String tag,
  }) =>
      remove(
        tag: tag,
        onSuccess: (tags) => showSuccessToast('blacklisted_tags.updated'.tr()),
        onFailure: () =>
            showErrorToast('blacklisted_tags.failed_to_remove'.tr()),
      );
}
