// Project imports:
import '../../core/boorus/booru/booru.dart';
import '../../core/boorus/engine/engine.dart';
import 'gelbooru_v1_builder.dart';
import 'gelbooru_v1_repository.dart';

BooruComponents createGelbooruV1() => BooruComponents(
  parser: YamlBooruParser.standard(
    type: BooruType.gelbooruV1,
    constructor: (siteDef) => GelbooruV1(
      name: siteDef.name,
      protocol: siteDef.protocol,
      sites: siteDef.sites,
    ),
  ),
  createBuilder: GelbooruV1Builder.new,
  createRepository: (ref) => GelbooruV1Repository(ref: ref),
);

final class GelbooruV1 extends Booru {
  const GelbooruV1({
    required super.name,
    required super.protocol,
    required this.sites,
  });

  @override
  final List<String> sites;

  @override
  BooruType get type => BooruType.gelbooruV1;
}
