// Project imports:
import '../../core/boorus/booru/booru.dart';
import '../../core/boorus/engine/engine.dart';
import 'philomena_builder.dart';
import 'philomena_repository.dart';

BooruComponents createPhilomena() => BooruComponents(
  parser: DefaultBooruParser(
    config: BooruYamlConfigs.philomena,
  ),
  createBuilder: PhilomenaBuilder.new,
  createRepository: (ref) => PhilomenaRepository(ref: ref),
);
