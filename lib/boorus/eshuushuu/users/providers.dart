// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import '../../../core/configs/config/types.dart';
import '../client_provider.dart';
import 'types.dart';

final eshuushuuUserProvider =
    FutureProvider.family<EshuushuuUser?, (BooruConfigAuth, int)>((
      ref,
      params,
    ) async {
      final (config, userId) = params;
      final client = ref.watch(eshuushuuClientProvider(config));
      final dto = await client.getUser(userId);

      return dto != null ? EshuushuuUser.fromDto(dto) : null;
    });
