// Project imports:
import '../../core/boorus/booru/types.dart';
import '../../core/boorus/engine/types.dart';
import 'gelbooru_v1_builder.dart';
import 'gelbooru_v1_repository.dart';

BooruComponents createGelbooruV1() => BooruComponents(
  parser: DefaultBooruParser(
    config: BooruYamlConfigs.gelbooruV1,
  ),
  createBuilder: GelbooruV1Builder.new,
  createRepository: (ref) => GelbooruV1Repository(ref: ref),
);
