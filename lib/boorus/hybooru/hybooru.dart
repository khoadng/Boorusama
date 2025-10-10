// Project imports:
import '../../core/boorus/booru/booru.dart';
import '../../core/boorus/engine/engine.dart';
import 'hybooru_builder.dart';
import 'hybooru_repository.dart';

BooruComponents createHybooru() => BooruComponents(
  parser: DefaultBooruParser(
    config: BooruYamlConfigs.hybooru,
  ),
  createBuilder: HybooruBuilder.new,
  createRepository: (ref) => HybooruRepository(ref: ref),
);
