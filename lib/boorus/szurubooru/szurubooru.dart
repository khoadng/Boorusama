// Project imports:
import '../../core/boorus/booru/booru.dart';
import '../../core/boorus/engine/engine.dart';
import 'szurubooru_builder.dart';
import 'szurubooru_repository.dart';

BooruComponents createSzurubooru() => BooruComponents(
      parser: YamlBooruParser.standard(
        type: BooruType.szurubooru,
        constructor: (siteDef) => Szurubooru(
          name: siteDef.name,
          protocol: siteDef.protocol,
        ),
      ),
      createBuilder: SzurubooruBuilder.new,
      createRepository: (ref) => SzurubooruRepository(ref: ref),
    );

class Szurubooru extends Booru {
  const Szurubooru({
    required super.name,
    required super.protocol,
  });

  @override
  Iterable<String> get sites => const [];

  @override
  BooruType get type => BooruType.szurubooru;
}
