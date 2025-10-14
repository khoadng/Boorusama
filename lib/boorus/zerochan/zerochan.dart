// Project imports:
import '../../core/boorus/booru/types.dart';
import '../../core/boorus/engine/types.dart';
import 'zerochan_builder.dart';
import 'zerochan_repository.dart';

BooruComponents createZerochan() => BooruComponents(
  parser: DefaultBooruParser(
    config: BooruYamlConfigs.zerochan,
  ),
  createBuilder: ZerochanBuilder.new,
  createRepository: (ref) => ZerochanRepository(ref: ref),
);
