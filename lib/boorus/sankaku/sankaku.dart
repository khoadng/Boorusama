// Project imports:
import '../../core/boorus/booru/booru.dart';
import '../../core/boorus/engine/engine.dart';
import 'sankaku_builder.dart';
import 'sankaku_repository.dart';

BooruComponents createSankaku() => BooruComponents(
  parser: YamlBooruParser(
    type: BooruType.sankaku,
    mapper: (def) => Sankaku(
      name: def.name,
      protocol: def.getProtocol(),
      sites: def.getSites(),
      headers: def.getHeaders(),
    ),
  ),
  createBuilder: SankakuBuilder.new,
  createRepository: (ref) => SankakuRepository(ref: ref),
);

class Sankaku extends Booru {
  const Sankaku({
    required super.name,
    required super.protocol,
    required this.sites,
    required this.headers,
  });

  @override
  final List<String> sites;
  final Map<String, dynamic>? headers;

  @override
  BooruType get type => BooruType.sankaku;
}
