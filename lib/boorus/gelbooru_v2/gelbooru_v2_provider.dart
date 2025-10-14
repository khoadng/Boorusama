// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import '../../core/boorus/booru/providers.dart';
import '../../core/boorus/booru/types.dart';
import 'gelbooru_v2.dart';

final gelbooruV2Provider = Provider<GelbooruV2>(
  (ref) {
    final booruDb = ref.watch(booruDbProvider);
    final booru = booruDb.getBooru(BooruType.gelbooruV2) as GelbooruV2?;

    if (booru == null) {
      throw Exception('Booru not found for type: ${BooruType.gelbooruV2}');
    }

    return booru;
  },
);
