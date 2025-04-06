// Package imports:
import 'package:collection/collection.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import '../../../../boorus/anime-pictures/anime_pictures.dart';
import '../../../../boorus/danbooru/danbooru.dart';
import '../../../../boorus/e621/e621.dart';
import '../../../../boorus/gelbooru/gelbooru.dart';
import '../../../../boorus/gelbooru_v1/gelbooru_v1.dart';
import '../../../../boorus/gelbooru_v2/gelbooru_v2.dart';
import '../../../../boorus/hydrus/hydrus.dart';
import '../../../../boorus/moebooru/moebooru.dart';
import '../../../../boorus/philomena/philomena.dart';
import '../../../../boorus/sankaku/sankaku.dart';
import '../../../../boorus/shimmie2/shimmie2.dart';
import '../../../../boorus/szurubooru/szurubooru.dart';
import '../../../../boorus/zerochan/zerochan.dart';
import '../../../http/http.dart';
import '../../engine/engine.dart';
import 'booru_type.dart';
import 'parser.dart';

abstract class Booru extends Equatable {
  const Booru({
    required this.name,
    required this.protocol,
  });

  final String name;
  final NetworkProtocol protocol;

  Iterable<String> get sites;

  /// The BooruType associated with this Booru implementation
  BooruType get type;

  /// The ID of the Booru type
  int get id => type.id;

  /// Creates a builder for this Booru type
  BooruBuilder createBuilder();

  /// Creates a repository for this Booru type
  BooruRepository createRepository(Ref ref);

  NetworkProtocol? getSiteProtocol(String url) => protocol;

  String getApiUrl(String url) => url;

  String? getLoginUrl() => null;

  bool hasSite(String url) => sites.any((site) => url == site);

  @override
  List<Object?> get props => [name];
}

typedef GelbooruV2Site = ({
  String url,
  String? apiUrl,
});

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

  @override
  BooruBuilder createBuilder() => DanbooruBuilder();

  @override
  BooruRepository createRepository(Ref ref) =>
      DanbooruRepository(ref: ref, booru: this);

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
  String get booruType => 'danbooru';

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

final class Gelbooru extends Booru with PassHashAuthMixin {
  const Gelbooru({
    required super.name,
    required super.protocol,
    required this.sites,
    required this.loginUrl,
  });

  @override
  final List<String> sites;
  @override
  final String? loginUrl;

  @override
  BooruType get type => BooruType.gelbooru;

  @override
  BooruBuilder createBuilder() => GelbooruBuilder();

  @override
  BooruRepository createRepository(Ref ref) => GelbooruRepository(ref: ref);

  @override
  String? getLoginUrl() => loginUrl;
}

class GelbooruParser extends BooruParser {
  @override
  String get booruType => 'gelbooru';

  @override
  Booru parse(String name, dynamic data) {
    return Gelbooru(
      name: name,
      protocol: parseProtocol(data['protocol']),
      sites: List.from(data['sites']),
      loginUrl: data['login-url'],
    );
  }
}

final class GelbooruV1 extends Booru {
  const GelbooruV1({
    required super.name,
    required super.protocol,
    required this.sites,
  });

  @override
  final List<String> sites;

  @override
  BooruType get type => BooruType.gelbooruV1;

  @override
  BooruBuilder createBuilder() => GelbooruV1Builder();

  @override
  BooruRepository createRepository(Ref ref) => GelbooruV1Repository(ref: ref);
}

class GelbooruV1Parser extends BooruParser {
  @override
  String get booruType => 'gelbooru_v1';

  @override
  Booru parse(String name, dynamic data) {
    return GelbooruV1(
      name: name,
      protocol: parseProtocol(data['protocol']),
      sites: List.from(data['sites']),
    );
  }
}

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
  BooruBuilder createBuilder() => GelbooruV2Builder();

  @override
  BooruRepository createRepository(Ref ref) => GelbooruV2Repository(ref: ref);

  @override
  String getApiUrl(String url) =>
      _sites.firstWhereOrNull((e) => url.contains(e.url))?.apiUrl ?? url;
}

class GelbooruV2Parser extends BooruParser {
  @override
  String get booruType => 'gelbooru_v2';

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

  @override
  BooruBuilder createBuilder() => E621Builder();

  @override
  BooruRepository createRepository(Ref ref) => E621Repository(ref: ref);
}

class E621Parser extends BooruParser {
  @override
  String get booruType => 'e621';

  @override
  Booru parse(String name, dynamic data) {
    return E621(
      name: name,
      protocol: parseProtocol(data['protocol']),
      sites: List.from(data['sites']),
    );
  }
}

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

  @override
  BooruBuilder createBuilder() => ZerochanBuilder();

  @override
  BooruRepository createRepository(Ref ref) => ZerochanRepository(ref: ref);
}

class ZerochanParser extends BooruParser {
  @override
  String get booruType => 'zerochan';

  @override
  Booru parse(String name, dynamic data) {
    return Zerochan(
      name: name,
      protocol: parseProtocol(data['protocol']),
      sites: List.from(data['sites']),
    );
  }
}

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

  @override
  BooruBuilder createBuilder() => MoebooruBuilder();

  @override
  BooruRepository createRepository(Ref ref) => MoebooruRepository(ref: ref);

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
  String get booruType => 'moebooru';

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
          overrideProtocol:
              overrideProtocol != null ? parseProtocol(overrideProtocol) : null,
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

class Sankaku extends Booru {
  const Sankaku({
    required super.name,
    required super.protocol,
    required this.sites,
    required this.headers,
  });

  @override
  final List<String> sites;
  final Map<String, dynamic> headers;

  @override
  BooruType get type => BooruType.sankaku;

  @override
  BooruBuilder createBuilder() => SankakuBuilder();

  @override
  BooruRepository createRepository(Ref ref) => SankakuRepository(ref: ref);
}

class SankakuParser extends BooruParser {
  @override
  String get booruType => 'sankaku';

  @override
  Booru parse(String name, dynamic data) {
    final headers = data['headers'];

    final map = <String, dynamic>{};

    for (final item in headers) {
      final key = item.keys.first;
      final value = item[item.keys.first];

      map[key] = value;
    }

    return Sankaku(
      name: name,
      protocol: parseProtocol(data['protocol']),
      sites: List.from(data['sites']),
      headers: map,
    );
  }
}

class Philomena extends Booru {
  const Philomena({
    required super.name,
    required super.protocol,
    required this.sites,
  });

  @override
  final List<String> sites;

  @override
  BooruType get type => BooruType.philomena;

  @override
  BooruBuilder createBuilder() => PhilomenaBuilder();

  @override
  BooruRepository createRepository(Ref ref) => PhilomenaRepository(ref: ref);
}

class PhilomenaParser extends BooruParser {
  @override
  String get booruType => 'philomena';

  @override
  Booru parse(String name, dynamic data) {
    return Philomena(
      name: name,
      protocol: parseProtocol(data['protocol']),
      sites: List.from(data['sites']),
    );
  }
}

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

  @override
  BooruBuilder createBuilder() => Shimmie2Builder();

  @override
  BooruRepository createRepository(Ref ref) => Shimmie2Repository(ref: ref);
}

class Shimmie2Parser extends BooruParser {
  @override
  String get booruType => 'shimmie2';

  @override
  Booru parse(String name, dynamic data) {
    return Shimmie2(
      name: name,
      protocol: parseProtocol(data['protocol']),
      sites: List.from(data['sites']),
    );
  }
}

class Szurubooru extends Booru {
  const Szurubooru({
    required super.name,
    required super.protocol,
    required this.sites,
  });

  @override
  final List<String> sites;

  @override
  BooruType get type => BooruType.szurubooru;

  @override
  BooruBuilder createBuilder() => SzurubooruBuilder();

  @override
  BooruRepository createRepository(Ref ref) => SzurubooruRepository(ref: ref);
}

class SzurubooruParser extends BooruParser {
  @override
  String get booruType => 'szurubooru';

  @override
  Booru parse(String name, dynamic data) {
    return Szurubooru(
      name: name,
      protocol: parseProtocol(data['protocol']),
      sites: List.from(data['sites']),
    );
  }
}

class Hydrus extends Booru {
  const Hydrus({
    required super.name,
    required super.protocol,
    required this.sites,
  });

  @override
  final List<String> sites;

  @override
  BooruType get type => BooruType.hydrus;

  @override
  BooruBuilder createBuilder() => HydrusBuilder();

  @override
  BooruRepository createRepository(Ref ref) => HydrusRepository(ref: ref);
}

class HydrusParser extends BooruParser {
  @override
  String get booruType => 'hydrus';

  @override
  Booru parse(String name, dynamic data) {
    return Hydrus(
      name: name,
      protocol: parseProtocol(data['protocol']),
      sites: List.from(data['sites']),
    );
  }
}

class AnimePictures extends Booru with PassHashAuthMixin {
  const AnimePictures({
    required super.name,
    required super.protocol,
    required this.sites,
    required this.loginUrl,
  });

  @override
  final List<String> sites;

  @override
  final String? loginUrl;

  @override
  BooruType get type => BooruType.animePictures;

  @override
  BooruBuilder createBuilder() => AnimePicturesBuilder();

  @override
  BooruRepository createRepository(Ref ref) =>
      AnimePicturesRepository(ref: ref);

  @override
  String? getLoginUrl() => loginUrl;
}

class AnimePicturesParser extends BooruParser {
  @override
  String get booruType => 'anime-pictures';

  @override
  Booru parse(String name, dynamic data) {
    return AnimePictures(
      name: name,
      protocol: parseProtocol(data['protocol']),
      sites: List.from(data['sites']),
      loginUrl: data['login-url'],
    );
  }
}

mixin PassHashAuthMixin {
  String? get loginUrl;
}
