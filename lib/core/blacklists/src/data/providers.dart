// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';

// Project imports:
import '../types/blacklisted_tag_repository.dart';
import 'hive/tag_hive_object.dart';
import 'hive/tag_repository.dart';

final globalBlacklistedTagRepoProvider =
    FutureProvider<GlobalBlacklistedTagRepository>(
  (ref) async {
    final globalBlacklistedTags = HiveBlacklistedTagRepository();
    await globalBlacklistedTags.init();

    return globalBlacklistedTags;
  },
  name: 'globalBlacklistedTagRepoProvider',
);

void initBlacklistTagRepo() {
  Hive.registerAdapter(BlacklistedTagHiveObjectAdapter());
}
