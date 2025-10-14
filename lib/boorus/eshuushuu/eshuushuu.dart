// Project imports:
import '../../core/boorus/booru/types.dart';
import '../../core/boorus/engine/types.dart';
import 'eshuushuu_builder.dart';
import 'eshuushuu_repository.dart';

BooruComponents createEshuushuu() => BooruComponents(
  parser: DefaultBooruParser(
    config: BooruYamlConfigs.eshuushuu,
  ),
  createBuilder: EshuushuuBuilder.new,
  createRepository: (ref) => EshuushuuRepository(ref: ref),
);
