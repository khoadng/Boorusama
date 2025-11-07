// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import '../../../../../../core/configs/config/types.dart';
import '../../../pool/types.dart';
import '../data/providers.dart';
import '../types/pool_description.dart';

final poolDescriptionProvider = FutureProvider.autoDispose
    .family<PoolDescription, (BooruConfigAuth, PoolId)>((ref, params) async {
      final (config, poolId) = params;
      final repo = ref.watch(poolDescriptionRepoProvider(config));
      final desc = await repo.getDescription(poolId);

      return PoolDescription(
        description: desc,
        descriptionEndpointRefUrl: config.url,
      );
    });
