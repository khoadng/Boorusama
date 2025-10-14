// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import '../../core/boorus/booru/providers.dart';
import '../../core/boorus/booru/types.dart';
import '../../core/boorus/engine/types.dart';
import 'gelbooru_builder.dart';
import 'gelbooru_repository.dart';

String getGelbooruProfileUrl(String url) => url.endsWith('/')
    ? '${url}index.php?page=account&s=options'
    : '$url/index.php?page=account&s=options';

final gelbooruProvider = Provider<Booru>(
  (ref) {
    final booruDb = ref.watch(booruDbProvider);
    final booru = booruDb.getBooru(BooruType.gelbooru);

    if (booru == null) {
      throw Exception('Booru not found for type: ${BooruType.gelbooru}');
    }

    return booru;
  },
);

BooruComponents createGelbooru() => BooruComponents(
  parser: DefaultBooruParser(
    config: BooruYamlConfigs.gelbooru,
  ),
  createBuilder: GelbooruBuilder.new,
  createRepository: (ref) => GelbooruRepository(ref: ref),
);
