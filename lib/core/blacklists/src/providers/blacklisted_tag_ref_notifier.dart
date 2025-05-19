// Dart imports:
import 'dart:async';

// Package imports:
import 'package:equatable/equatable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import '../../../boorus/engine/providers.dart';
import '../../../configs/config.dart';
import '../../../configs/src/create/search_blacklist.dart';
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
      tags: _combineTags(
        {
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
        arg.blacklistConfigs,
      ),
    );
  }
}

Set<BlacklistedTagEntry> _combineTags(
  Set<BlacklistedTagEntry> currentTags,
  BlacklistConfigs? configs,
) {
  if (configs == null) return currentTags;

  if (!configs.enable) return currentTags;

  final mode = BlacklistCombinationMode.fromString(configs.combinationMode);
  final blacklistTags = configs.blacklistedTagsList;

  if (mode == BlacklistCombinationMode.replace) {
    return blacklistTags
        .map(
          (e) => BlacklistedTagEntry(
            tag: e,
            source: BlacklistSource.config,
          ),
        )
        .toSet();
  } else {
    return {
      ...currentTags,
      ...blacklistTags.map(
        (e) => BlacklistedTagEntry(
          tag: e,
          source: BlacklistSource.config,
        ),
      ),
    };
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
  global('Global Blacklist'),
  booruSpecific('Site Blacklist'),
  config('Profile Blacklist');

  const BlacklistSource(this.displayString);

  final String displayString;
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
