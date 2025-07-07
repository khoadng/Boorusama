// Package imports:
import 'package:collection/collection.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import '../../core/boorus/booru/booru.dart';
import '../../core/boorus/booru/providers.dart';
import '../../core/boorus/engine/engine.dart';
import '../../core/http/http.dart';
import 'moebooru_builder.dart';
import 'moebooru_repository.dart';

BooruComponents createMoebooru() => BooruComponents(
  parser: MoebooruParser(),
  createBuilder: MoebooruBuilder.new,
  createRepository: (ref) => MoebooruRepository(ref: ref),
);

final moebooruProvider = Provider<Moebooru>((ref) {
  final booruDb = ref.watch(booruDbProvider);
  final booru = booruDb.getBooru<Moebooru>();

  if (booru == null) {
    throw Exception('Booru not found for type: ${BooruType.moebooru}');
  }

  return booru;
});

typedef MoebooruSite = ({
  String url,
  String salt,
  bool? favoriteSupport,
  NetworkProtocol? overrideProtocol,
});

final class Moebooru extends Booru {
  const Moebooru({
    required super.name,
    required super.protocol,
    required List<MoebooruSite> sites,
  }) : _sites = sites;

  final List<MoebooruSite> _sites;

  @override
  Iterable<String> get sites => _sites.map((e) => e.url);

  @override
  BooruType get type => BooruType.moebooru;

  String? getSalt(String url) =>
      _sites.firstWhereOrNull((e) => url.contains(e.url))?.salt;

  bool supportsFavorite(String url) =>
      _sites.firstWhereOrNull((e) => url.contains(e.url))?.favoriteSupport ??
      false;

  @override
  NetworkProtocol? getSiteProtocol(String url) =>
      _sites.firstWhereOrNull((e) => url.contains(e.url))?.overrideProtocol ??
      protocol;
}

class MoebooruParser extends BooruParser {
  @override
  BooruType get booruType => BooruType.moebooru;

  @override
  Booru parse(String name, dynamic data) {
    final sites = <MoebooruSite>[];

    for (final item in data['sites']) {
      final url = item['url'] as String;
      final salt = item['salt'] as String;
      final favoriteSupport = item['favorite-support'] as bool?;
      final overrideProtocol = item['protocol'];

      sites.add(
        (
          url: url,
          salt: salt,
          favoriteSupport: favoriteSupport,
          overrideProtocol: overrideProtocol != null
              ? parseProtocol(overrideProtocol)
              : null,
        ),
      );
    }

    return Moebooru(
      name: name,
      protocol: parseProtocol(data['protocol']),
      sites: sites,
    );
  }
}
