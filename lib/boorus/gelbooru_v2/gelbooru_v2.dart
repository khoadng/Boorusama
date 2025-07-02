// Package imports:
import 'package:collection/collection.dart';

// Project imports:
import '../../core/boorus/booru/booru.dart';
import '../../core/boorus/engine/engine.dart';
import '../../core/http/http.dart';
import 'gelbooru_v2_builder.dart';
import 'gelbooru_v2_repository.dart';

BooruComponents createGelbooruV2() => BooruComponents(
      parser: GelbooruV2Parser(),
      createBuilder: GelbooruV2Builder.new,
      createRepository: (ref) => GelbooruV2Repository(ref: ref),
    );

typedef GelbooruV2Site = ({
  String url,
  String? apiUrl,
});

class GelbooruV2 extends Booru {
  const GelbooruV2({
    required super.name,
    required super.protocol,
    required List<GelbooruV2Site> sites,
  }) : _sites = sites;

  final List<GelbooruV2Site> _sites;

  @override
  Iterable<String> get sites => _sites.map((e) => e.url);

  @override
  BooruType get type => BooruType.gelbooruV2;

  @override
  String getApiUrl(String url) =>
      _sites.firstWhereOrNull((e) => url.contains(e.url))?.apiUrl ?? url;
}

class GelbooruV2Parser extends BooruParser {
  @override
  BooruType get booruType => BooruType.gelbooruV2;

  @override
  Booru parse(String name, dynamic data) {
    final sites = <GelbooruV2Site>[];

    for (final item in data['sites']) {
      final url = item['url'] as String;
      final apiUrl = item['api-url'];

      sites.add(
        (
          url: url,
          apiUrl: apiUrl,
        ),
      );
    }

    return GelbooruV2(
      name: name,
      protocol: parseProtocol(data['protocol']),
      sites: sites,
    );
  }
}
