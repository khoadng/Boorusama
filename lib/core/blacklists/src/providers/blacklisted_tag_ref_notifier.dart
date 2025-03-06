// Dart imports:
import 'dart:async';

// Package imports:
import 'package:equatable/equatable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import '../../../boorus/engine/providers.dart';
import '../../../configs/config.dart';
import '../../../configs/ref.dart';
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

    return EmptyBooruSpecificBlacklistTagRefRepository(ref);
  },
);

class BlacklistedTagsState extends Equatable {
  const BlacklistedTagsState({
    required this.tags,
  });

  const BlacklistedTagsState.empty() : tags = const {};

  final Set<BlacklistedTagEntry> tags;

  @override
  List<Object?> get props => [tags];
}

class BlacklistedTagsNotifier
    extends FamilyAsyncNotifier<BlacklistedTagsState, BooruConfigFilter> {
  @override
  FutureOr<BlacklistedTagsState> build(BooruConfigFilter arg) async {
    final repo = ref.watch(blacklistTagsRefRepoProvider(arg.auth));
    final booruSpecificBlacklistedTags =
        await repo.getBlacklistedTags(arg.auth);

    final globalBlacklistedTags =
        ref.watch(globalBlacklistedTagsProvider).map((e) => e.name).toSet();

    return BlacklistedTagsState(
      tags: {
        ...globalBlacklistedTags.map(
          (e) => BlacklistedTagEntry(
            tag: e,
            source: BlacklistSource.global,
          ),
        ),
        ...booruSpecificBlacklistedTags.map(
          (e) => BlacklistedTagEntry(
            tag: e,
            source: BlacklistSource.booruSpecific,
          ),
        ),
      },
    );
  }
}

final blacklistedTagsNotifierProvider = AsyncNotifierProvider.family<
    BlacklistedTagsNotifier, BlacklistedTagsState, BooruConfigFilter>(
  BlacklistedTagsNotifier.new,
);

final blacklistTagEntriesProvider = FutureProvider.autoDispose
    .family<Set<BlacklistedTagEntry>, BooruConfigFilter>((ref, config) {
  return ref
      .watch(blacklistedTagsNotifierProvider(config).future)
      .then((value) => value.tags);
});

final blacklistTagsProvider = FutureProvider.autoDispose
    .family<Set<String>, BooruConfigFilter>((ref, config) {
  return ref
      .watch(blacklistedTagsNotifierProvider(config).future)
      .then((value) => value.tags.map((e) => e.tag).toSet());
});

final currentBlacklistTagsProvider =
    FutureProvider.autoDispose<Set<String>>((ref) {
  final config = ref.watchConfigFilter;
  return ref.watch(blacklistTagsProvider(config).future);
});

class EmptyBooruSpecificBlacklistTagRefRepository
    implements BlacklistTagRefRepository {
  EmptyBooruSpecificBlacklistTagRefRepository(this.ref);

  @override
  final Ref ref;

  @override
  Future<Set<String>> getBlacklistedTags(BooruConfigAuth config) async {
    return {};
  }
}

enum BlacklistSource {
  global,
  booruSpecific,
}

class BlacklistedTagEntry extends Equatable {
  const BlacklistedTagEntry({
    required this.tag,
    required this.source,
  });

  final String tag;
  final BlacklistSource source;

  @override
  List<Object?> get props => [tag, source];
}
