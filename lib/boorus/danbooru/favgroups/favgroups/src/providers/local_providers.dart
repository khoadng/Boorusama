// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import '../../../../../../core/configs/config/types.dart';
import '../../../../client_provider.dart';
import '../types/favorite_group_repository.dart';
import 'favorite_group_repository_api.dart';

final danbooruFavoriteGroupRepoProvider =
    Provider.family<FavoriteGroupRepository, BooruConfigAuth>((ref, config) {
      return FavoriteGroupRepositoryApi(
        client: ref.watch(danbooruClientProvider(config)),
      );
    });
