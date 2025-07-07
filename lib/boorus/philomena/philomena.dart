// Project imports:
import '../../core/boorus/booru/booru.dart';
import '../../core/boorus/engine/engine.dart';
import 'philomena_builder.dart';
import 'philomena_repository.dart';

BooruComponents createPhilomena() => BooruComponents(
  parser: YamlBooruParser.standard(
    type: BooruType.philomena,
    constructor: (siteDef) => Philomena(
      name: siteDef.name,
      protocol: siteDef.protocol,
      sites: siteDef.sites,
    ),
  ),
  createBuilder: PhilomenaBuilder.new,
  createRepository: (ref) => PhilomenaRepository(ref: ref),
);

class Philomena extends Booru {
  const Philomena({
    required super.name,
    required super.protocol,
    required this.sites,
  });

  @override
  final List<String> sites;

  @override
  BooruType get type => BooruType.philomena;
}
