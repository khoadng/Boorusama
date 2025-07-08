// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import '../../../../boorus/engine/providers.dart';
import '../../../../configs/config/types.dart';
import '../types/types.dart';
import 'repository.dart';

final favoriteRepoProvider =
    Provider.family<FavoriteRepository, BooruConfigAuth>(
      (ref, config) {
        final repo = ref
            .watch(booruEngineRegistryProvider)
            .getRepository(config.booruType);

        final favoriteRepo = repo?.favorite(config);

        if (favoriteRepo != null) {
          return favoriteRepo;
        }

        return EmptyFavoriteRepository();
      },
    );
