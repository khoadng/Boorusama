// Dart imports:
import 'dart:async';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import '../../../../core/configs/config/providers.dart';
import '../../../../core/configs/config/types.dart';
import '../../../../core/text_markup/providers.dart';
import 'data/providers.dart';
import 'types/wiki.dart';

final danbooruWikiProvider =
    AsyncNotifierProvider.family<WikiNotifier, Wiki?, String>(
      WikiNotifier.new,
    );

class WikiNotifier extends FamilyAsyncNotifier<Wiki?, String> {
  @override
  FutureOr<Wiki?> build(String arg) {
    final config = ref.watchConfigAuth;
    return _load(config, arg);
  }

  Future<void> reload() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(
      () => _load(ref.readConfigAuth, arg),
    );
  }

  Future<Wiki?> _load(BooruConfigAuth config, String title) async {
    final wiki = await ref
        .read(danbooruWikiRepoProvider(config))
        .getWikiFor(
          title,
        );
    if (wiki == null) return null;

    await ref.read(textMarkupCacheProvider(config).notifier).resolveBodies([
      wiki.body,
    ]);

    return wiki;
  }
}
