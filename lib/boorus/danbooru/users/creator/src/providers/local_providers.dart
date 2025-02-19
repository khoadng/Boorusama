// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import '../../../../../../core/configs/config.dart';
import '../../../user/providers.dart';
import '../data/creator_repository_impl.dart';
import '../types/creator_repository.dart';
import 'providers.dart';

final danbooruCreatorRepoProvider =
    FutureProvider.family<CreatorRepository, BooruConfigAuth>(
  (ref, config) async {
    final box = await ref.watch(danbooruCreatorHiveBoxProvider(config).future);

    return CreatorRepositoryFromUserRepo(
      ref.watch(danbooruUserRepoProvider(config)),
      box,
    );
  },
);
