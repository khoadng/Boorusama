// Package imports:
import 'package:collection/collection.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import '../../core/boorus/booru/booru.dart';
import '../../core/boorus/booru/providers.dart';
import '../../core/boorus/engine/engine.dart';
import 'moebooru_builder.dart';
import 'moebooru_repository.dart';

BooruComponents createMoebooru() => BooruComponents(
  parser: MoebooruParser(),
  createBuilder: MoebooruBuilder.new,
  createRepository: (ref) => MoebooruRepository(ref: ref),
);

final moebooruProvider = Provider<Moebooru>((ref) {
  final booruDb = ref.watch(booruDbProvider);
  final booru = booruDb.getBooru(BooruType.moebooru) as Moebooru?;

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
    required super.config,
    required List<MoebooruSite> sites,
  }) : _sites = sites;

  final List<MoebooruSite> _sites;

  String? getSalt(String url) =>
      _sites.firstWhereOrNull((e) => url.contains(e.url))?.salt;

  bool supportsFavorite(String url) =>
      _sites.firstWhereOrNull((e) => url.contains(e.url))?.favoriteSupport ??
      false;

  @override
  NetworkProtocol? getSiteProtocol(String url) =>
      _sites.firstWhereOrNull((e) => url.contains(e.url))?.overrideProtocol ??
      super.getSiteProtocol(url);
}

class MoebooruParser extends BooruParser {
  @override
  Booru parse() {
    const config = BooruYamlConfigs.moebooru;
    final sites = <MoebooruSite>[];

    for (final siteConfig in config.sites) {
      final url = siteConfig.url;
      final salt = siteConfig.metadata['salt'] as String;
      final favoriteSupport = siteConfig.metadata['favorite-support'] as bool?;
      final overrideProtocol = siteConfig.metadata['protocol'];

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
      config: config,
      sites: sites,
    );
  }
}
