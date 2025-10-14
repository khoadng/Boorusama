// Project imports:
import '../../core/boorus/booru/types.dart';
import '../../core/boorus/engine/types.dart';
import 'sankaku_builder.dart';
import 'sankaku_repository.dart';

BooruComponents createSankaku() => BooruComponents(
  parser: DefaultBooruParser(
    config: BooruYamlConfigs.sankaku,
  ),
  createBuilder: SankakuBuilder.new,
  createRepository: (ref) => SankakuRepository(ref: ref),
);
