// Project imports:
import '../../core/boorus/booru/booru.dart';
import '../../core/boorus/engine/engine.dart';
import 'e621_builder.dart';
import 'e621_repository.dart';

BooruComponents createE621() => BooruComponents(
      parser: YamlBooruParser.standard(
        type: BooruType.e621,
        constructor: (siteDef) => E621(
          name: siteDef.name,
          protocol: siteDef.protocol,
          sites: siteDef.sites,
        ),
      ),
      createBuilder: E621Builder.new,
      createRepository: (ref) => E621Repository(ref: ref),
    );

class E621 extends Booru {
  const E621({
    required super.name,
    required super.protocol,
    required this.sites,
  });

  @override
  final List<String> sites;

  @override
  BooruType get type => BooruType.e621;
}
