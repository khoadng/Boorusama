// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import 'package:boorusama/core/configs/config.dart';
import '../../../user/providers.dart';
import '../data/creator_repository_impl.dart';
import '../types/creator_repository.dart';
import 'providers.dart';

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
