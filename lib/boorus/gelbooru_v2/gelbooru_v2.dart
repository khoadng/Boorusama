// Project imports:
import '../../core/boorus/booru/booru.dart';
import '../../core/boorus/engine/engine.dart';
import 'gelbooru_v2_builder.dart';
import 'gelbooru_v2_repository.dart';

BooruComponents createGelbooruV2() => BooruComponents(
  parser: CustomBooruParser(
    parseFn: () => GelbooruV2(
      config: BooruYamlConfigs.gelbooruV2,
      globalUserParams: BooruYamlConfigs.gelbooruV2.globalUserParams ?? {},
    ),
  ),
  createBuilder: GelbooruV2Builder.new,
  createRepository: (ref) => GelbooruV2Repository(ref: ref),
);

class GelbooruV2 extends FeatureAwareBooru {
  const GelbooruV2({
    required super.config,
    required super.globalUserParams,
  });
}
