// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import '../core/boorus/booru/booru.dart';
import '../core/boorus/engine/engine.dart';

typedef EngineParams = ({
  BooruDb db,
  BooruRegistry registry,
});

final booruInitEngineProvider =
    Provider.family<BooruEngineRegistry, EngineParams>((ref, params) {
  final registry = BooruEngineRegistry();

  for (final booru in params.db.boorus) {
    registry.register(
      booru.type,
      params.registry.createEngine(booru, ref),
    );
  }

  return registry;
});
