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

final booruInitEngineProvider = Provider<BooruEngineRegistry>((ref) {
  final registry = BooruEngineRegistry()
    ..register(
      BooruType.danbooru,
      BooruEngine(
        builder: DanbooruBuilder(),
        repository: DanbooruRepository(ref: ref),
      ),
    )
    ..register(
      BooruType.gelbooru,
      BooruEngine(
        builder: GelbooruBuilder(),
        repository: GelbooruRepository(ref: ref),
      ),
    )
    ..register(
      BooruType.gelbooruV2,
      BooruEngine(
        builder: GelbooruV2Builder(),
        repository: GelbooruV2Repository(ref: ref),
      ),
    )
    ..register(
      BooruType.gelbooruV1,
      BooruEngine(
        builder: GelbooruV1Builder(),
        repository: GelbooruV1Repository(ref: ref),
      ),
    )
    ..register(
      BooruType.moebooru,
      BooruEngine(
        builder: MoebooruBuilder(),
        repository: MoebooruRepository(ref: ref),
      ),
    )
    ..register(
      BooruType.e621,
      BooruEngine(
        builder: E621Builder(),
        repository: E621Repository(ref: ref),
      ),
    )
    ..register(
      BooruType.sankaku,
      BooruEngine(
        builder: SankakuBuilder(),
        repository: SankakuRepository(ref: ref),
      ),
    )
    ..register(
      BooruType.philomena,
      BooruEngine(
        builder: PhilomenaBuilder(),
        repository: PhilomenaRepository(ref: ref),
      ),
    )
    ..register(
      BooruType.shimmie2,
      BooruEngine(
        builder: Shimmie2Builder(),
        repository: Shimmie2Repository(ref: ref),
      ),
    )
    ..register(
      BooruType.zerochan,
      BooruEngine(
        builder: ZerochanBuilder(),
        repository: ZerochanRepository(ref: ref),
      ),
    )
    ..register(
      BooruType.szurubooru,
      BooruEngine(
        builder: SzurubooruBuilder(),
        repository: SzurubooruRepository(ref: ref),
      ),
    )
    ..register(
      BooruType.hydrus,
      BooruEngine(
        builder: HydrusBuilder(),
        repository: HydrusRepository(ref: ref),
      ),
    )
    ..register(
      BooruType.animePictures,
      BooruEngine(
        builder: AnimePicturesBuilder(),
        repository: AnimePicturesRepository(ref: ref),
      ),
    );

  return registry;
});
