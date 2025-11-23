// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import '../../../../foundation/boot/providers.dart';
import '../types/blacklisted_tag_repository.dart';
import 'hive/tag_repository.dart';

final globalBlacklistedTagRepoProvider =
    FutureProvider<GlobalBlacklistedTagRepository>(
      (ref) async {
        final dbPath = await ref.watch(dbPathProvider.future);

        final globalBlacklistedTags = HiveBlacklistedTagRepository();
        await globalBlacklistedTags.init(dbPath);

        return globalBlacklistedTags;
      },
      name: 'globalBlacklistedTagRepoProvider',
    );
