// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import '../core/boorus/booru/booru.dart';
import '../core/boorus/engine/engine.dart';

final booruInitEngineProvider =
    Provider.family<BooruEngineRegistry, BooruDb>((ref, db) {
  final registry = BooruEngineRegistry();

  for (final booru in db.boorus) {
    registry.register(
      booru.type,
      BooruEngine(
        booru: booru,
        builder: booru.createBuilder(),
        repository: booru.createRepository(ref),
      ),
    );
  }

  return registry;
});
