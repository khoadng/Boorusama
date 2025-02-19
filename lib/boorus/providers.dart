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
import 'hydrus/hydrus.dart';
import 'moebooru/moebooru.dart';
import 'philomena/philomena.dart';
import 'sankaku/sankaku.dart';
import 'shimmie2/shimmie2.dart';
import 'szurubooru/szurubooru.dart';
import 'zerochan/zerochan.dart';

final booruInitEngineProvider =
    Provider.family<BooruEngineRegistry, BooruFactory>((ref, booruFactory) {
  final danbooru = booruFactory.getBooruFromId(kDanbooruId)!;

  final registry = BooruEngineRegistry()
    ..register(
      BooruType.danbooru,
      BooruEngine(
        booru: danbooru,
        builder: DanbooruBuilder(),
        repository: DanbooruRepository(
          ref: ref,
          booru: danbooru,
        ),
      ),
    )
    ..register(
      BooruType.gelbooru,
      BooruEngine(
        booru: booruFactory.getBooruFromId(kGelbooruId),
        builder: GelbooruBuilder(),
        repository: GelbooruRepository(ref: ref),
      ),
    )
    ..register(
      BooruType.gelbooruV2,
      BooruEngine(
        booru: booruFactory.getBooruFromId(kGelbooruV2Id),
        builder: GelbooruV2Builder(),
        repository: GelbooruV2Repository(ref: ref),
      ),
    )
    ..register(
      BooruType.gelbooruV1,
      BooruEngine(
        booru: booruFactory.getBooruFromId(kGelbooruV1Id),
        builder: GelbooruV1Builder(),
        repository: GelbooruV1Repository(ref: ref),
      ),
    )
    ..register(
      BooruType.moebooru,
      BooruEngine(
        booru: booruFactory.getBooruFromId(kMoebooruId),
        builder: MoebooruBuilder(),
        repository: MoebooruRepository(ref: ref),
      ),
    )
    ..register(
      BooruType.e621,
      BooruEngine(
        booru: booruFactory.getBooruFromId(kE621Id),
        builder: E621Builder(),
        repository: E621Repository(ref: ref),
      ),
    )
    ..register(
      BooruType.sankaku,
      BooruEngine(
        booru: booruFactory.getBooruFromId(kSankaku),
        builder: SankakuBuilder(),
        repository: SankakuRepository(ref: ref),
      ),
    )
    ..register(
      BooruType.philomena,
      BooruEngine(
        booru: booruFactory.getBooruFromId(kPhilomenaId),
        builder: PhilomenaBuilder(),
        repository: PhilomenaRepository(ref: ref),
      ),
    )
    ..register(
      BooruType.shimmie2,
      BooruEngine(
        booru: booruFactory.getBooruFromId(kShimmie2Id),
        builder: Shimmie2Builder(),
        repository: Shimmie2Repository(ref: ref),
      ),
    )
    ..register(
      BooruType.zerochan,
      BooruEngine(
        booru: booruFactory.getBooruFromId(kZerochanId),
        builder: ZerochanBuilder(),
        repository: ZerochanRepository(ref: ref),
      ),
    )
    ..register(
      BooruType.szurubooru,
      BooruEngine(
        booru: booruFactory.getBooruFromId(kSzurubooruId),
        builder: SzurubooruBuilder(),
        repository: SzurubooruRepository(ref: ref),
      ),
    )
    ..register(
      BooruType.hydrus,
      BooruEngine(
        booru: booruFactory.getBooruFromId(kHydrusId),
        builder: HydrusBuilder(),
        repository: HydrusRepository(ref: ref),
      ),
    )
    ..register(
      BooruType.animePictures,
      BooruEngine(
        booru: booruFactory.getBooruFromId(kAnimePicturesId),
        builder: AnimePicturesBuilder(),
        repository: AnimePicturesRepository(ref: ref),
      ),
    );

  return registry;
});
