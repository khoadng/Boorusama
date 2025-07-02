// Project imports:
import '../../core/boorus/booru/booru.dart';
import '../../core/boorus/engine/engine.dart';
import 'shimmie2_builder.dart';
import 'shimmie2_repository.dart';

BooruComponents createShimmie2() => BooruComponents(
      parser: YamlBooruParser.standard(
        type: BooruType.shimmie2,
        constructor: (siteDef) => Shimmie2(
          name: siteDef.name,
          protocol: siteDef.protocol,
          sites: siteDef.sites,
        ),
      ),
      createBuilder: Shimmie2Builder.new,
      createRepository: (ref) => Shimmie2Repository(ref: ref),
    );

class Shimmie2 extends Booru {
  const Shimmie2({
    required super.name,
    required super.protocol,
    required this.sites,
  });

  @override
  final List<String> sites;

  @override
  BooruType get type => BooruType.shimmie2;
}
