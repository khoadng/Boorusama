// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import '../../core/boorus/booru/providers.dart';
import '../../core/boorus/booru/types.dart';

final sankakuProvider = Provider<Booru>(
  (ref) {
    final booruDb = ref.watch(booruDbProvider);
    final booru = booruDb.getBooru(BooruType.sankaku);

    if (booru == null) {
      throw Exception('Booru not found for type: ${BooruType.sankaku}');
    }

    return booru;
  },
);
