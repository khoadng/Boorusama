// Project imports:
import '../../core/boorus/booru/types.dart';
import '../../core/boorus/engine/types.dart';
import 'hybooru_builder.dart';
import 'hybooru_repository.dart';

BooruComponents createHybooru() => BooruComponents(
  parser: DefaultBooruParser(
    config: BooruYamlConfigs.hybooru,
  ),
  createBuilder: HybooruBuilder.new,
  createRepository: (ref) => HybooruRepository(ref: ref),
);
