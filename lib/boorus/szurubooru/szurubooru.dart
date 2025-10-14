// Project imports:
import '../../core/boorus/booru/types.dart';
import '../../core/boorus/engine/types.dart';
import 'szurubooru_builder.dart';
import 'szurubooru_repository.dart';

BooruComponents createSzurubooru() => BooruComponents(
  parser: DefaultBooruParser(
    config: BooruYamlConfigs.szurubooru,
  ),
  createBuilder: SzurubooruBuilder.new,
  createRepository: (ref) => SzurubooruRepository(ref: ref),
);
