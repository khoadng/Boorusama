// Project imports:
import '../../core/boorus/booru/booru.dart';
import '../../core/boorus/engine/engine.dart';
import 'zerochan_builder.dart';
import 'zerochan_repository.dart';

BooruComponents createZerochan() => BooruComponents(
      parser: YamlBooruParser.standard(
        type: BooruType.zerochan,
        constructor: (siteDef) => Zerochan(
          name: siteDef.name,
          protocol: siteDef.protocol,
          sites: siteDef.sites,
        ),
      ),
      createBuilder: ZerochanBuilder.new,
      createRepository: (ref) => ZerochanRepository(ref: ref),
    );

class Zerochan extends Booru {
  const Zerochan({
    required super.name,
    required super.protocol,
    required this.sites,
  });

  @override
  final List<String> sites;

  @override
  BooruType get type => BooruType.zerochan;
}
