// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import 'package:boorusama/core/application/booru_user_identity_provider.dart';
import 'package:boorusama/core/application/boorus.dart';
import 'package:boorusama/core/domain/boorus.dart';
import 'package:boorusama/core/domain/tags.dart';
import 'package:boorusama/core/provider.dart';
import 'blacklisted_tags_provider.dart';

class BlacklistedTagsNotifier extends AutoDisposeNotifier<List<String>?> {
  @override
  List<String>? build() {
    final config = ref.watch(currentBooruConfigProvider);

    fetch(config);

    return null;
  }

  BlacklistedTagsRepository get repo =>
      ref.read(danbooruBlacklistedTagRepoProvider);
  BooruUserIdentityProvider get identityProvider =>
      ref.read(booruUserIdentityProviderProvider);

  Future<void> fetch(BooruConfig config) async {
    final id = await identityProvider.getAccountIdFromConfig(config);

    if (id == null) return;

    final blacklistedTags = await ref
        .read(danbooruBlacklistedTagRepoProvider)
        .getBlacklistedTags(id);

    state = blacklistedTags;
  }

  Future<void> add({
    required String tag,
    void Function(List<String> tags)? onSuccess,
    void Function(String message)? onFailure,
  }) async {
    final config = ref.read(currentBooruConfigProvider);
    final id = await identityProvider.getAccountIdFromConfig(config);

    if (state == null || id == null) {
      onFailure?.call('Fail to add tag');

      return;
    }

    final tags = [...state!, tag];

    try {
      await repo.setBlacklistedTags(id, tags);
      state = tags;
    } catch (e) {
      onFailure?.call('Fail to add tag');
    }
  }

  // remove a tag
  Future<void> remove({
    required String tag,
    void Function(List<String> tags)? onSuccess,
    void Function(String message)? onFailure,
  }) async {
    final config = ref.read(currentBooruConfigProvider);
    final id = await identityProvider.getAccountIdFromConfig(config);

    if (state == null || id == null) {
      onFailure?.call('Fail to remove tag');

      return;
    }

    final tags = [...state!]..remove(tag);

    try {
      await repo.setBlacklistedTags(id, tags);
      state = tags;
    } catch (e) {
      onFailure?.call('Fail to remove tag');
    }
  }

  // replace a tag
  Future<void> replace({
    required String oldTag,
    required String newTag,
    void Function(List<String> tags)? onSuccess,
    void Function(String message)? onFailure,
  }) async {
    final config = ref.read(currentBooruConfigProvider);
    final id = await identityProvider.getAccountIdFromConfig(config);

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

String tagsToTagString(List<String> tags) => tags.join('\n');
