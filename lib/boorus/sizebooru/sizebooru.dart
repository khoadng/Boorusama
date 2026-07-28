// Project imports:
import '../../core/boorus/booru/types.dart';
import '../../core/boorus/engine/types.dart';
import 'sizebooru_builder.dart';
import 'sizebooru_repository.dart';

BooruComponents createSizebooru() => BooruComponents(
  parser: DefaultBooruParser(
    config: BooruYamlConfigs.sizebooru,
  ),
  createBuilder: SizebooruBuilder.new,
  createRepository: (ref) => SizebooruRepository(ref: ref),
);
