// Package imports:
import 'package:collection/collection.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import '../../core/boorus/booru/providers.dart';
import '../../core/boorus/booru/types.dart';
import '../../core/boorus/engine/types.dart';
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
    final booru = booruDb.getBooru(BooruType.danbooru) as Danbooru?;

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
    required super.config,
    required List<DanbooruSite> sites,
  }) : _sites = sites;

  final List<DanbooruSite> _sites;

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
  Booru parse() {
    const config = BooruYamlConfigs.danbooru;
    final sites = <DanbooruSite>[];

    for (final siteConfig in config.sites) {
      final url = siteConfig.url;
      final aiTagSupport = siteConfig.metadata['ai-tag'] as bool?;
      final censoredTagsBanned =
          siteConfig.metadata['censored-tags-banned'] as bool?;

      sites.add(
        (
          url: url,
          aiTagSupport: aiTagSupport,
          censoredTagsBanned: censoredTagsBanned,
        ),
      );
    }

    return Danbooru(
      config: config,
      sites: sites,
    );
  }
}
