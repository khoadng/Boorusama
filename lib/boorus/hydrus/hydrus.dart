// Project imports:
import '../../core/boorus/booru/booru.dart';
import '../../core/boorus/engine/engine.dart';
import 'hydrus_builder.dart';
import 'hydrus_repository.dart';

BooruComponents createHydrus() => BooruComponents(
  parser: DefaultBooruParser(
    config: BooruYamlConfigs.hydrus,
  ),
  createBuilder: HydrusBuilder.new,
  createRepository: (ref) => HydrusRepository(ref: ref),
);
