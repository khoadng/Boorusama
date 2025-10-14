// Project imports:
import '../../core/boorus/booru/types.dart';
import '../../core/boorus/engine/types.dart';
import 'shimmie2_builder.dart';
import 'shimmie2_repository.dart';

BooruComponents createShimmie2() => BooruComponents(
  parser: DefaultBooruParser(
    config: BooruYamlConfigs.shimmie2,
  ),
  createBuilder: Shimmie2Builder.new,
  createRepository: (ref) => Shimmie2Repository(ref: ref),
);
