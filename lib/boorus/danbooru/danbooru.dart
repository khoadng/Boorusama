// Package imports:
import 'package:collection/collection.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import '../../core/boorus/booru/booru.dart';
import '../../core/boorus/booru/providers.dart';
import '../../core/boorus/engine/engine.dart';
import '../../core/http/http.dart';
import 'danbooru_builder.dart';
import 'danbooru_repository.dart';

BooruComponents createDanbooru() => BooruComponents(
  parser: DanbooruParser(),
  createBuilder: DanbooruBuilder.new,
  createRepository: (ref) => DanbooruRepository(ref: ref),
);

final danbooruProvider = Provider<Danbooru>(
  (ref) {
    final booruDb = ref.watch(booruDbProvider);
    final booru = booruDb.getBooru<Danbooru>();

    if (booru == null) {
      throw Exception('Booru not found for type: ${BooruType.danbooru}');
    }

    return booru;
  },
);

typedef DanbooruSite = ({
  String url,
  bool? aiTagSupport,
  bool? censoredTagsBanned,
});

final class Danbooru extends Booru {
  const Danbooru({
    required super.name,
    required super.protocol,
    required List<DanbooruSite> sites,
  }) : _sites = sites;

  final List<DanbooruSite> _sites;

  @override
  Iterable<String> get sites => _sites.map((e) => e.url);

  @override
  BooruType get type => BooruType.danbooru;

  bool hasAiTagSupported(String url) =>
      _sites.firstWhereOrNull((e) => url.contains(e.url))?.aiTagSupport ??
      false;

  bool hasCensoredTagsBanned(String url) =>
      _sites.firstWhereOrNull((e) => url.contains(e.url))?.censoredTagsBanned ??
      false;

  String cheetsheet(String url) {
    return '$url/wiki_pages/help:cheatsheet';
  }
}

class DanbooruParser extends BooruParser {
  @override
  BooruType get booruType => BooruType.danbooru;

  @override
  Booru parse(String name, dynamic data) {
    final sites = <DanbooruSite>[];

    for (final item in data['sites']) {
      final url = item['url'] as String;
      final aiTagSupport = item['ai-tag'];
      final censoredTagsBanned = item['censored-tags-banned'];

      sites.add(
        (
          url: url,
          aiTagSupport: aiTagSupport,
          censoredTagsBanned: censoredTagsBanned,
        ),
      );
    }

    return Danbooru(
      name: name,
      protocol: parseProtocol(data['protocol']),
      sites: sites,
    );
  }
}
