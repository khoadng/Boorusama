// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import 'package:boorusama/boorus/providers.dart';
import 'package:boorusama/core/feats/booru_user_identity_provider.dart';
import 'package:boorusama/core/feats/boorus/boorus.dart';
import 'package:boorusama/core/feats/tags/tags.dart';
import 'package:boorusama/foundation/i18n.dart';
import 'package:boorusama/widgets/toast.dart';
import 'blacklisted_tags_provider.dart';

class BlacklistedTagsNotifier
    extends AutoDisposeFamilyNotifier<List<String>?, BooruConfig> {
  @override
  List<String>? build(BooruConfig arg) {
    fetch();

    return null;
  }

  BlacklistedTagsRepository get repo =>
      ref.read(danbooruBlacklistedTagRepoProvider(arg));
  BooruUserIdentityProvider get identityProvider =>
      ref.read(booruUserIdentityProviderProvider(arg));

  Future<void> fetch() async {
    final id = await identityProvider.getAccountIdFromConfig(arg);

    if (id == null) return;

    final blacklistedTags = await ref
        .read(danbooruBlacklistedTagRepoProvider(arg))
        .getBlacklistedTags(id);

    state = blacklistedTags;
  }

  Future<void> add({
    required String tag,
    void Function(List<String> tags)? onSuccess,
    void Function()? onFailure,
  }) async {
    final id = await identityProvider.getAccountIdFromConfig(arg);

    if (state == null || id == null) {
      onFailure?.call();

      return;
    }

    // Duplicate tags are not allowed
    final tags = {...state!, tag}.toList();

    try {
      await repo.setBlacklistedTags(id, tags);
      state = tags;
    } catch (e) {
      onFailure?.call();
    }
  }

  // remove a tag
  Future<void> remove({
    required String tag,
    void Function(List<String> tags)? onSuccess,
    void Function()? onFailure,
  }) async {
    final id = await identityProvider.getAccountIdFromConfig(arg);

    if (state == null || id == null) {
      onFailure?.call();

      return;
    }

    final tags = [...state!]..remove(tag);

    try {
      await repo.setBlacklistedTags(id, tags);
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
    final id = await identityProvider.getAccountIdFromConfig(arg);

    if (state == null || id == null) {
      onFailure?.call('Fail to replace tag');

      return;
    }

    final tags = [
      ...[...state!]..remove(oldTag),
      newTag,
    ];

    try {
      await repo.setBlacklistedTags(id, tags);
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
        onFailure: () => showErrorToast('blacklisted_tags.failed_to_add'.tr()),
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
