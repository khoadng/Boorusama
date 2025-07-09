// Project imports:
import '../../core/boorus/booru/booru.dart';
import '../../core/boorus/engine/engine.dart';
import 'hydrus_builder.dart';
import 'hydrus_repository.dart';

BooruComponents createHydrus() => BooruComponents(
  parser: YamlBooruParser.standard(
    type: BooruType.hydrus,
    constructor: (siteDef) => Hydrus(
      name: siteDef.name,
      protocol: siteDef.protocol,
    ),
  ),
  createBuilder: HydrusBuilder.new,
  createRepository: (ref) => HydrusRepository(ref: ref),
);

class Hydrus extends Booru {
  const Hydrus({
    required super.name,
    required super.protocol,
  });

  @override
  Iterable<String> get sites => const [];

  @override
  BooruType get type => BooruType.hydrus;
}
