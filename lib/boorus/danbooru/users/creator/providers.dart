// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';

// Project imports:
import 'package:boorusama/core/configs/config.dart';
import '../user/providers.dart';
import 'creator_repository.dart';

final danbooruCreatorHiveBoxProvider = Provider<Box>((ref) {
  throw UnimplementedError();
});

final danbooruCreatorRepoProvider =
    Provider.family<CreatorRepository, BooruConfigAuth>(
  (ref, config) {
    return CreatorRepositoryFromUserRepo(
      ref.watch(danbooruUserRepoProvider(config)),
      ref.watch(danbooruCreatorHiveBoxProvider),
    );
  },
  dependencies: [
    danbooruCreatorHiveBoxProvider,
  ],
);
