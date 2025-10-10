// Project imports:
import '../../core/boorus/booru/booru.dart';
import '../../core/boorus/engine/engine.dart';
import 'sankaku_builder.dart';
import 'sankaku_repository.dart';

BooruComponents createSankaku() => BooruComponents(
  parser: DefaultBooruParser(
    config: BooruYamlConfigs.sankaku,
  ),
  createBuilder: SankakuBuilder.new,
  createRepository: (ref) => SankakuRepository(ref: ref),
);
