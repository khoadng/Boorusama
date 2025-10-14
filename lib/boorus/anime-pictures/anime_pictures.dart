// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import '../../core/boorus/booru/providers.dart';
import '../../core/boorus/booru/types.dart';
import '../../core/boorus/engine/types.dart';
import 'anime_pictures_builder.dart';
import 'anime_pictures_repository.dart';

final animePicturesProvider = Provider<Booru>(
  (ref) {
    final booruDb = ref.watch(booruDbProvider);
    final booru = booruDb.getBooru(BooruType.animePictures);

    if (booru == null) {
      throw Exception('Booru not found for type: ${BooruType.animePictures}');
    }

    return booru;
  },
);

BooruComponents createAnimePictures() => BooruComponents(
  parser: DefaultBooruParser(
    config: BooruYamlConfigs.animePictures,
  ),
  createBuilder: AnimePicturesBuilder.new,
  createRepository: (ref) => AnimePicturesRepository(ref: ref),
);
