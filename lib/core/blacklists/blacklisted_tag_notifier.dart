// Dart imports:
import 'dart:async';

// Package imports:
import 'package:equatable/equatable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import '../../boorus/providers.dart';
import '../configs/config.dart';

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
