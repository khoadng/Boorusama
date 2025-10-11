// Project imports:
import '../../core/boorus/booru/booru.dart';
import '../../core/boorus/engine/engine.dart';
import 'eshuushuu_builder.dart';
import 'eshuushuu_repository.dart';

BooruComponents createEshuushuu() => BooruComponents(
  parser: DefaultBooruParser(
    config: BooruYamlConfigs.eshuushuu,
  ),
  createBuilder: EshuushuuBuilder.new,
  createRepository: (ref) => EshuushuuRepository(ref: ref),
);
