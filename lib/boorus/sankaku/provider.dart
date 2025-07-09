// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import '../../core/boorus/booru/booru.dart';
import '../../core/boorus/booru/providers.dart';
import 'sankaku.dart';

final sankakuProvider = Provider<Sankaku>(
  (ref) {
    final booruDb = ref.watch(booruDbProvider);
    final booru = booruDb.getBooru<Sankaku>();

    if (booru == null) {
      throw Exception('Booru not found for type: ${BooruType.sankaku}');
    }

    return booru;
  },
);
