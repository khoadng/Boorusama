// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import '../core/boorus/booru/booru.dart';
import '../core/boorus/engine/engine.dart';
import 'anime-pictures/anime_pictures.dart';
import 'danbooru/danbooru.dart';
import 'e621/e621.dart';
import 'gelbooru/gelbooru.dart';
import 'gelbooru_v1/gelbooru_v1.dart';
import 'gelbooru_v2/gelbooru_v2.dart';
import 'hybooru/hybooru.dart';
import 'hydrus/hydrus.dart';
import 'moebooru/moebooru.dart';
import 'philomena/philomena.dart';
import 'sankaku/sankaku.dart';
import 'shimmie2/shimmie2.dart';
import 'szurubooru/szurubooru.dart';
import 'zerochan/zerochan.dart';

typedef EngineParams = ({BooruDb db, BooruRegistry registry});

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

typedef BooruFactory = BooruComponents Function();

final Map<BooruType, BooruFactory> _booruFactories = {
  BooruType.hybooru: createHybooru,
  BooruType.animePictures: createAnimePictures,
  BooruType.hydrus: createHydrus,
  BooruType.szurubooru: createSzurubooru,
  BooruType.shimmie2: createShimmie2,
  BooruType.philomena: createPhilomena,
  BooruType.sankaku: createSankaku,
  BooruType.moebooru: createMoebooru,
  BooruType.zerochan: createZerochan,
  BooruType.e621: createE621,
  BooruType.gelbooruV2: createGelbooruV2,
  BooruType.gelbooruV1: createGelbooruV1,
  BooruType.gelbooru: createGelbooru,
  BooruType.danbooru: createDanbooru,
};

BooruRegistry createBooruRegistry() {
  final registry = BooruRegistry();

  for (final entry in _booruFactories.entries) {
    registry.register(entry.key, entry.value());
  }

  return registry;
}
