// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';

// Project imports:
import '../../../../boot.dart';
import '../types/blacklisted_tag_repository.dart';
import 'hive/tag_hive_object.dart';
import 'hive/tag_repository.dart';

final globalBlacklistedTagRepoProvider =
    FutureProvider<GlobalBlacklistedTagRepository>(
  (ref) async {
    Hive.registerAdapter(BlacklistedTagHiveObjectAdapter());

    final dbPath = await ref.watch(dbPathProvider.future);

    final globalBlacklistedTags = HiveBlacklistedTagRepository();
    await globalBlacklistedTags.init(dbPath);

    return globalBlacklistedTags;
  },
  name: 'globalBlacklistedTagRepoProvider',
);
