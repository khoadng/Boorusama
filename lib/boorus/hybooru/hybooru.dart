// Project imports:
import '../../core/boorus/booru/booru.dart';
import '../../core/boorus/engine/engine.dart';
import 'hybooru_builder.dart';
import 'hybooru_repository.dart';

BooruComponents createHybooru() => BooruComponents(
  parser: YamlBooruParser.standard(
    type: BooruType.hybooru,
    constructor: (siteDef) => Hybooru(
      name: siteDef.name,
      protocol: siteDef.protocol,
      sites: siteDef.sites,
    ),
  ),
  createBuilder: HybooruBuilder.new,
  createRepository: (ref) => HybooruRepository(ref: ref),
);

class Hybooru extends Booru {
  const Hybooru({
    required super.name,
    required super.protocol,
    required this.sites,
  });

  @override
  final List<String> sites;

  @override
  BooruType get type => BooruType.hybooru;
}
