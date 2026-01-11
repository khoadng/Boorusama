// Project imports:
import '../../core/boorus/booru/types.dart';
import '../../core/boorus/engine/types.dart';
import '../szurubooru/szurubooru_builder.dart';
import '../szurubooru/szurubooru_repository.dart';

BooruComponents createOxibooru() => BooruComponents(
  parser: DefaultBooruParser(
    config: BooruYamlConfigs.oxibooru,
  ),
  createBuilder: SzurubooruBuilder.new,
  createRepository: (ref) => SzurubooruRepository(ref: ref),
);
