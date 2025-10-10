// Project imports:
import '../../core/boorus/booru/booru.dart';
import '../../core/boorus/engine/engine.dart';
import 'e621_builder.dart';
import 'e621_repository.dart';

BooruComponents createE621() => BooruComponents(
  parser: DefaultBooruParser(
    config: BooruYamlConfigs.e621,
  ),
  createBuilder: E621Builder.new,
  createRepository: (ref) => E621Repository(ref: ref),
);
