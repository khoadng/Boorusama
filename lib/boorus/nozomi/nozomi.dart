// Project imports:
import '../../core/boorus/booru/types.dart';
import '../../core/boorus/engine/types.dart';
import 'nozomi_builder.dart';
import 'nozomi_repository.dart';

BooruComponents createNozomi() => BooruComponents(
  parser: DefaultBooruParser(
    config: BooruYamlConfigs.nozomi,
  ),
  createBuilder: NozomiBuilder.new,
  createRepository: (ref) => NozomiRepository(ref: ref),
);
