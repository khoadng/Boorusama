// Dart imports:
import 'dart:async';

// Package imports:
import 'package:equatable/equatable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import '../../../boorus/engine/providers.dart';
import '../../../configs/config.dart';
import '../types/blacklisted_tag_repository.dart';
import 'global_blacklisted_tag_notifier.dart';

final blacklistTagsRefRepoProvider =
    Provider.family<BlacklistTagRefRepository, BooruConfigAuth>(
  (ref, config) {
    final repo =
        ref.watch(booruEngineRegistryProvider).getRepository(config.booruType);

    final blacklistTagRefRepo = repo?.blacklistTagRef(config);

    if (blacklistTagRefRepo != null) {
      return blacklistTagRefRepo;
    }

    return GlobalBlacklistTagRefRepository(ref);
  },
);

class BlacklistedTagsState extends Equatable {
  const BlacklistedTagsState({
    required this.tags,
  });

  const BlacklistedTagsState.empty() : tags = const {};

  final Set<String> tags;

  @override
  List<Object?> get props => [tags];
}

class BlacklistedTagsNotifier
    extends FamilyAsyncNotifier<BlacklistedTagsState, BooruConfigAuth> {
  @override
  FutureOr<BlacklistedTagsState> build(BooruConfigAuth arg) async {
    final repo = ref.watch(blacklistTagsRefRepoProvider(arg));
    final tags = await repo.getBlacklistedTags(arg);

    return BlacklistedTagsState(tags: tags);
  }
}

final blacklistedTagsNotifierProvider = AsyncNotifierProvider.family<
    BlacklistedTagsNotifier, BlacklistedTagsState, BooruConfigAuth>(
  BlacklistedTagsNotifier.new,
);

final blacklistTagsProvider = FutureProvider.autoDispose
    .family<Set<String>, BooruConfigAuth>((ref, config) {
  return ref
      .watch(blacklistedTagsNotifierProvider(config).future)
      .then((value) => value.tags);
});

class GlobalBlacklistTagRefRepository implements BlacklistTagRefRepository {
  GlobalBlacklistTagRefRepository(this.ref);

  @override
  final Ref ref;

  @override
  Future<Set<String>> getBlacklistedTags(BooruConfigAuth config) async {
    final globalBlacklistedTags =
        ref.watch(globalBlacklistedTagsProvider).map((e) => e.name).toSet();

    return globalBlacklistedTags;
  }
}
