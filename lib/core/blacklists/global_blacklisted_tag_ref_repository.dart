// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import '../configs/config.dart';
import 'blacklisted_tag.dart';
import 'providers.dart';

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
