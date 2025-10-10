// Project imports:
import '../../core/boorus/booru/booru.dart';
import '../../core/boorus/engine/engine.dart';
import 'shimmie2_builder.dart';
import 'shimmie2_repository.dart';

BooruComponents createShimmie2() => BooruComponents(
  parser: DefaultBooruParser(
    config: BooruYamlConfigs.shimmie2,
  ),
  createBuilder: Shimmie2Builder.new,
  createRepository: (ref) => Shimmie2Repository(ref: ref),
);
