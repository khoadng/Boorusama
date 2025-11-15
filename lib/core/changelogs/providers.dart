// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_ce/hive.dart';

// Project imports:
import '../cache/providers.dart';
import 'notifier.dart';
import 'repo.dart';
import 'types.dart';

final changelogDataBoxProvider = FutureProvider<Box<String>>(
  (ref) => ref.watch(miscDataBoxProvider),
);

final changelogRepositoryProvider = FutureProvider<ChangelogRepository>(
  (ref) async {
    final box = await ref.watch(changelogDataBoxProvider.future);
    return ChangelogRepositoryImpl(box);
  },
);

final changelogDataProvider =
    AsyncNotifierProvider<ChangelogDataNotifier, ChangelogData>(
      ChangelogDataNotifier.new,
    );

final fullChangelogProvider =
    AsyncNotifierProvider.autoDispose<FullChangelogNotifier, String>(
      FullChangelogNotifier.new,
    );

final changelogVisibilityNotifierProvider =
    AsyncNotifierProvider<ChangelogVisibilityNotifier, bool>(
      ChangelogVisibilityNotifier.new,
    );
