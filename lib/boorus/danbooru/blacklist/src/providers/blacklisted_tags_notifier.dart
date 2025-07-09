// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import '../../../../../core/blacklists/blacklist.dart';
import '../../../../../core/configs/config.dart';
import '../../../client_provider.dart';
import '../../../danbooru.dart';
import '../../../posts/post/post.dart';
import '../../../users/user/providers.dart';
import '../../../users/user/user.dart';

final danbooruBlacklistedTagsProvider =
    AsyncNotifierProvider.family<
      BlacklistedTagsNotifier,
      List<String>?,
      BooruConfigAuth
    >(
      BlacklistedTagsNotifier.new,
    );

class BlacklistedTagsNotifier
    extends FamilyAsyncNotifier<List<String>?, BooruConfigAuth> {
  @override
  Future<List<String>?> build(BooruConfigAuth arg) async {
    final user = await ref.watch(danbooruCurrentUserProvider(arg).future);

    if (user == null) return null;

    return user.blacklistedTags.toList();
  }

  Future<void> add({
    required Set<String> tagSet,
    void Function(List<String> tags)? onSuccess,
    void Function(Object e)? onFailure,
  }) async {
    final user = await ref.read(danbooruCurrentUserProvider(arg).future);
    final currentTags = state.value;

    if (currentTags == null || user == null) {
      onFailure?.call('Not logged in or no blacklisted tags found');

      return;
    }

    // Duplicate tags are not allowed
    final tags = [...currentTags, ...tagSet];

    try {
      await ref
          .read(danbooruClientProvider(arg))
          .setBlacklistedTags(
            id: user.id,
            blacklistedTags: tags,
          );

      onSuccess?.call(tags);

      state = AsyncValue.data(tags);
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
    final currentTags = state.value;

    if (currentTags == null || user == null) {
      onFailure?.call();

      return;
    }

    final tags = [...currentTags]..remove(tag);

    try {
      await ref
          .read(danbooruClientProvider(arg))
          .setBlacklistedTags(id: user.id, blacklistedTags: tags);

      onSuccess?.call(tags);

      state = AsyncValue.data(tags);
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
    final currentTags = state.value;

    if (currentTags == null || user == null) {
      onFailure?.call('Fail to replace tag');

      return;
    }

    final tags = [
      ...[...currentTags]..remove(oldTag),
      newTag,
    ];

    try {
      await ref
          .read(danbooruClientProvider(arg))
          .setBlacklistedTags(id: user.id, blacklistedTags: tags);

      onSuccess?.call(tags);

      state = AsyncValue.data(tags);
    } catch (e) {
      onFailure?.call('Fail to replace tag');
    }
  }
}

class DanbooruBlacklistTagRepository implements BlacklistTagRefRepository {
  DanbooruBlacklistTagRepository(
    this.ref,
    this.config,
  );

  @override
  final Ref ref;
  final BooruConfigAuth config;

  @override
  Future<Set<String>> getBlacklistedTags(BooruConfigAuth config) async {
    final currentUser = await ref.watch(
      danbooruCurrentUserProvider(config).future,
    );

    if (currentUser == null) {
      return {};
    }

    final danbooruBlacklistedTags = await ref.watch(
      danbooruBlacklistedTagsProvider(config).future,
    );
    final isUnverified = config.isUnverified();
    final booru = ref.watch(danbooruProvider);
    final censoredTagsBanned = booru.hasCensoredTagsBanned(config.url);

    return {
      if (danbooruBlacklistedTags != null) ...danbooruBlacklistedTags,
      if (!isUnverified &&
          censoredTagsBanned &&
          !isBooruGoldPlusAccount(currentUser.level))
        ...kCensoredTags,
    };
  }
}
