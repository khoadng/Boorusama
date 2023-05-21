// Package imports:
import 'package:boorusama/boorus/danbooru/danbooru_provider.dart';
import 'package:boorusama/boorus/danbooru/infra/repositories/pool/pool_cacher.dart';
import 'package:boorusama/boorus/danbooru/infra/repositories/repositories.dart';
import 'package:boorusama/core/application/boorus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import 'package:boorusama/boorus/danbooru/domain/pools.dart';

final danbooruPoolRepoProvider = Provider<PoolRepository>((ref) {
  final api = ref.read(danbooruApiProvider);
  final booruConfig = ref.read(currentBooruConfigProvider);

  return PoolCacher(
    PoolRepositoryApi(api, booruConfig),
  );
});
