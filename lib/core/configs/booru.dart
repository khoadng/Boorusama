// Package imports:
import 'package:collection/collection.dart';
import 'package:equatable/equatable.dart';

const int kDanbooruId = 20;
const int kGelbooruId = 21;
const int kGelbooruV1Id = 22;
const int kGelbooruV2Id = 23;
const int kMoebooruId = 24;
const int kE621Id = 25;
const int kZerochanId = 26;
const int kSankaku = 27;
const int kPhilomenaId = 28;
const int kShimmie2Id = 29;
const int kSzurubooruId = 30;
const int kHydrusId = 31;
const int kAnimePicturesId = 32;

enum NetworkProtocol {
  https_1_1,
  https_2_0,
}

NetworkProtocol? stringToNetworkProtocol(String value) => switch (value) {
      'https_1_1' || 'https_1' => NetworkProtocol.https_1_1,
      'https_2_0' || 'https_2' => NetworkProtocol.https_2_0,
      _ => null,
    };

NetworkProtocol _parseProtocol(dynamic value) => switch (value) {
      final String s => stringToNetworkProtocol(s) ?? NetworkProtocol.https_1_1,
      _ => NetworkProtocol.https_1_1,
    };

Future<List<Booru>> loadBoorus(dynamic yaml) async {
  final boorus = <Booru>[];

  for (final item in yaml) {
    final name = item.keys.first as String;
    final values = item[name];

    boorus.add(Booru.from(name, values));
  }

  return boorus;
}

sealed class Booru extends Equatable {
  const Booru({
    required this.name,
    required this.protocol,
  });

  factory Booru.from(String name, dynamic data) => switch (name.toLowerCase()) {
        'danbooru' => Danbooru.from(name, data),
        'gelbooru' => Gelbooru.from(name, data),
        'moebooru' => Moebooru.from(name, data),
        'gelbooru_v1' => GelbooruV1.from(name, data),
        'gelbooru_v2' => GelbooruV2.from(name, data),
        'e621' => E621.from(name, data),
        'zerochan' => Zerochan.from(name, data),
        'sankaku' => Sankaku.from(name, data),
        'philomena' => Philomena.from(name, data),
        'shimmie2' => Shimmie2.from(name, data),
        'szurubooru' => Szurubooru.from(name, data),
        'anime-pictures' => AnimePictures.from(name, data),
        _ => throw Exception('Unknown booru: $name'),
      };

  final String name;
  final NetworkProtocol protocol;

  @override
  List<Object?> get props => [name];
}

extension BooruX on Booru {
  String? cheetsheet(String url) => switch (this) {
        Danbooru _ => '$url/wiki_pages/help:cheatsheet',
        _ => null,
      };

  int get id => switch (this) {
        Danbooru _ => kDanbooruId,
        Gelbooru _ => kGelbooruId,
        GelbooruV1 _ => kGelbooruV1Id,
        GelbooruV2 _ => kGelbooruV2Id,
        Moebooru _ => kMoebooruId,
        E621 _ => kE621Id,
        Zerochan _ => kZerochanId,
        Sankaku _ => kSankaku,
        Philomena _ => kPhilomenaId,
        Shimmie2 _ => kShimmie2Id,
        Szurubooru _ => kSzurubooruId,
        Hydrus _ => kHydrusId,
        AnimePictures _ => kAnimePicturesId,
      };

  bool hasSite(String url) => switch (this) {
        final Danbooru d => d.sites.any((e) => e.url == url),
        final Gelbooru g => g.sites.contains(url),
        final GelbooruV1 g => g.sites.contains(url),
        final GelbooruV2 g => g.sites.any((e) => e.url == url),
        final Moebooru m => m.sites.any((e) => e.url == url),
        final E621 e => e.sites.contains(url),
        final Zerochan z => z.sites.contains(url),
        final Sankaku s => s.sites.contains(url),
        final Philomena p => p.sites.contains(url),
        final Shimmie2 s => s.sites.contains(url),
        final Szurubooru s => s.sites.contains(url),
        final Hydrus h => h.sites.contains(url),
        final AnimePictures a => a.sites.contains(url),
      };

  NetworkProtocol? getSiteProtocol(String url) => switch (this) {
        final Moebooru m => m.sites
                .firstWhereOrNull((e) => url.contains(e.url))
                ?.overrideProtocol ??
            protocol,
        _ => protocol,
      };

  String? getSalt(String url) => switch (this) {
        final Moebooru m =>
          m.sites.firstWhereOrNull((e) => url.contains(e.url))?.salt,
        _ => null,
      };

  bool? hasAiTagSupported(String url) => switch (this) {
        final Danbooru d =>
          d.sites.firstWhereOrNull((e) => url.contains(e.url))?.aiTagSupport ??
              false,
        _ => null,
      };

  String getApiUrl(String url) => switch (this) {
        final GelbooruV2 g =>
          g.sites.firstWhereOrNull((e) => url.contains(e.url))?.apiUrl ?? url,
        _ => url,
      };

  bool? hasCensoredTagsBanned(String url) => switch (this) {
        final Danbooru d => d.sites
                .firstWhereOrNull((e) => url.contains(e.url))
                ?.censoredTagsBanned ??
            false,
        _ => null,
      };

  //TODO: This is fine for now, but we must have a different url for each site, currently there is only one site for each booru
  String? getLoginUrl() => switch (this) {
        final Gelbooru g => g.loginUrl,
        final AnimePictures a => a.loginUrl,
        _ => null,
      };

  T whenMoebooru<T>({
    required T Function(Moebooru moe) data,
    required T Function() orElse,
  }) {
    if (this is Moebooru) {
      return data(this as Moebooru);
    } else {
      return orElse();
    }
  }
}

typedef DanbooruSite = ({
  String url,
  bool? aiTagSupport,
  bool? censoredTagsBanned,
});

typedef GelbooruV2Site = ({
  String url,
  String? apiUrl,
});

final class Danbooru extends Booru {
  const Danbooru({
    required super.name,
    required super.protocol,
    required this.sites,
  });

  factory Danbooru.from(String name, dynamic data) {
    final sites = <DanbooruSite>[];

    for (final item in data['sites']) {
      final url = item['url'] as String;
      final aiTagSupport = item['ai-tag'];
      final censoredTagsBanned = item['censored-tags-banned'];

      sites.add((
        url: url,
        aiTagSupport: aiTagSupport,
        censoredTagsBanned: censoredTagsBanned,
      ));
    }

    return Danbooru(
      name: name,
      protocol: _parseProtocol(data['protocol']),
      sites: sites,
    );
  }

  final List<DanbooruSite> sites;
}

final class Gelbooru extends Booru with PassHashAuthMixin {
  const Gelbooru({
    required super.name,
    required super.protocol,
    required this.sites,
    required this.loginUrl,
  });

  factory Gelbooru.from(String name, dynamic data) {
    return Gelbooru(
      name: name,
      protocol: _parseProtocol(data['protocol']),
      sites: List.from(data['sites']),
      loginUrl: data['login-url'],
    );
  }

  final List<String> sites;
  @override
  final String? loginUrl;
}

final class GelbooruV1 extends Booru {
  const GelbooruV1({
    required super.name,
    required super.protocol,
    required this.sites,
  });

  factory GelbooruV1.from(String name, dynamic data) {
    return GelbooruV1(
      name: name,
      protocol: _parseProtocol(data['protocol']),
      sites: List.from(data['sites']),
    );
  }

  final List<String> sites;
}

class GelbooruV2 extends Booru {
  const GelbooruV2({
    required super.name,
    required super.protocol,
    required this.sites,
  });

  factory GelbooruV2.from(String name, dynamic data) {
    final sites = <GelbooruV2Site>[];

    for (final item in data['sites']) {
      final url = item['url'] as String;
      final apiUrl = item['api-url'];

      sites.add((
        url: url,
        apiUrl: apiUrl,
      ));
    }

    return GelbooruV2(
      name: name,
      protocol: _parseProtocol(data['protocol']),
      sites: sites,
    );
  }

  final List<GelbooruV2Site> sites;
}

class E621 extends Booru {
  const E621({
    required super.name,
    required super.protocol,
    required this.sites,
  });

  factory E621.from(String name, dynamic data) {
    return E621(
      name: name,
      protocol: _parseProtocol(data['protocol']),
      sites: List.from(data['sites']),
    );
  }

  final List<String> sites;
}

class Zerochan extends Booru {
  const Zerochan({
    required super.name,
    required super.protocol,
    required this.sites,
  });

  factory Zerochan.from(String name, dynamic data) {
    return Zerochan(
      name: name,
      protocol: _parseProtocol(data['protocol']),
      sites: List.from(data['sites']),
    );
  }

  final List<String> sites;
}

typedef MoebooruSite = ({
  String url,
  String salt,
  bool? favoriteSupport,
  NetworkProtocol? overrideProtocol,
});

extension MoebooruX on Moebooru {
  bool supportsFavorite(String url) =>
      sites.firstWhereOrNull((e) => url.contains(e.url))?.favoriteSupport ??
      false;
}

final class Moebooru extends Booru {
  const Moebooru({
    required super.name,
    required super.protocol,
    required this.sites,
  });

  factory Moebooru.from(String name, dynamic data) {
    final sites = <MoebooruSite>[];

    for (final item in data['sites']) {
      final url = item['url'] as String;
      final salt = item['salt'] as String;
      final favoriteSupport = item['favorite-support'] as bool?;
      final overrideProtocol = item['protocol'];

      sites.add((
        url: url,
        salt: salt,
        favoriteSupport: favoriteSupport,
        overrideProtocol:
            overrideProtocol != null ? _parseProtocol(overrideProtocol) : null,
      ));
    }

    return Moebooru(
      name: name,
      protocol: _parseProtocol(data['protocol']),
      sites: sites,
    );
  }

  final List<MoebooruSite> sites;
}

class Sankaku extends Booru {
  const Sankaku({
    required super.name,
    required super.protocol,
    required this.sites,
    required this.headers,
  });

  factory Sankaku.from(String name, dynamic data) {
    final headers = data['headers'];

    final map = <String, dynamic>{};

    for (final item in headers) {
      final key = item.keys.first;
      final value = item[item.keys.first];

      map[key] = value;
    }

    return Sankaku(
      name: name,
      protocol: _parseProtocol(data['protocol']),
      sites: List.from(data['sites']),
      headers: map,
    );
  }

  final List<String> sites;
  final Map<String, dynamic> headers;
}

class Philomena extends Booru {
  const Philomena({
    required super.name,
    required super.protocol,
    required this.sites,
  });

  factory Philomena.from(String name, dynamic data) {
    return Philomena(
      name: name,
      protocol: _parseProtocol(data['protocol']),
      sites: List.from(data['sites']),
    );
  }

  final List<String> sites;
}

class Shimmie2 extends Booru {
  const Shimmie2({
    required super.name,
    required super.protocol,
    required this.sites,
  });

  factory Shimmie2.from(String name, dynamic data) {
    return Shimmie2(
      name: name,
      protocol: _parseProtocol(data['protocol']),
      sites: List.from(data['sites']),
    );
  }

  final List<String> sites;
}

class Szurubooru extends Booru {
  const Szurubooru({
    required super.name,
    required super.protocol,
    required this.sites,
  });

  factory Szurubooru.from(String name, dynamic data) {
    return Szurubooru(
      name: name,
      protocol: _parseProtocol(data['protocol']),
      sites: List.from(data['sites']),
    );
  }

  final List<String> sites;
}

class Hydrus extends Booru {
  const Hydrus({
    required super.name,
    required super.protocol,
    required this.sites,
  });

  factory Hydrus.from(String name, dynamic data) {
    return Hydrus(
      name: name,
      protocol: _parseProtocol(data['protocol']),
      sites: List.from(data['sites']),
    );
  }

  final List<String> sites;
}

class AnimePictures extends Booru with PassHashAuthMixin {
  const AnimePictures({
    required super.name,
    required super.protocol,
    required this.sites,
    required this.loginUrl,
  });

  factory AnimePictures.from(String name, dynamic data) {
    return AnimePictures(
      name: name,
      protocol: _parseProtocol(data['protocol']),
      sites: List.from(data['sites']),
      loginUrl: data['login-url'],
    );
  }

  final List<String> sites;

  @override
  final String? loginUrl;
}

enum BooruType {
  unknown,
  danbooru,
  gelbooru,
  moebooru,
  gelbooruV2,
  e621,
  zerochan,
  gelbooruV1,
  sankaku,
  philomena,
  shimmie2,
  szurubooru,
  hydrus,
  animePictures,
}

extension BooruTypeX on BooruType {
  String stringify() => switch (this) {
        BooruType.unknown => 'UNKNOWN',
        BooruType.danbooru => 'Danbooru',
        BooruType.gelbooruV1 => 'Gelbooru 0.1.x',
        BooruType.gelbooru => 'Gelbooru 0.2.5',
        BooruType.gelbooruV2 => 'Gelbooru 0.2',
        BooruType.moebooru => 'Moebooru',
        BooruType.e621 => 'e621',
        BooruType.zerochan => 'Zerochan',
        BooruType.sankaku => 'Sankaku',
        BooruType.philomena => 'Philomena',
        BooruType.shimmie2 => 'Shimmie2',
        BooruType.szurubooru => 'Szurubooru',
        BooruType.hydrus => 'Hydrus',
        BooruType.animePictures => 'Anime Pictures',
      };

  bool get isGelbooruBased =>
      this == BooruType.gelbooru ||
      this == BooruType.gelbooruV1 ||
      this == BooruType.gelbooruV2;

  bool get isMoeBooruBased => [
        BooruType.moebooru,
      ].contains(this);

  bool get isDanbooruBased => [
        BooruType.danbooru,
      ].contains(this);

  bool get isE621Based => this == BooruType.e621;

  bool get supportTagDetails => this == BooruType.gelbooru || isDanbooruBased;

  bool get supportBlacklistedTags => isDanbooruBased;

  bool get canDownloadMultipleFiles => this != BooruType.animePictures;

  bool get masonryLayoutUnsupported => this == BooruType.gelbooruV1;

  bool get hasUnknownFullImageUrl =>
      this == BooruType.zerochan || this == BooruType.gelbooruV1;

  int toBooruId() => switch (this) {
        BooruType.danbooru => kDanbooruId,
        BooruType.gelbooru => kGelbooruId,
        BooruType.moebooru => kMoebooruId,
        BooruType.gelbooruV2 => kGelbooruV2Id,
        BooruType.e621 => kE621Id,
        BooruType.zerochan => kZerochanId,
        BooruType.gelbooruV1 => kGelbooruV1Id,
        BooruType.sankaku => kSankaku,
        BooruType.philomena => kPhilomenaId,
        BooruType.shimmie2 => kShimmie2Id,
        BooruType.szurubooru => kSzurubooruId,
        BooruType.hydrus => kHydrusId,
        BooruType.animePictures => kAnimePicturesId,
        BooruType.unknown => 0,
      };
}

BooruType intToBooruType(int? value) => switch (value) {
      1 || 2 || 3 || 5 || kDanbooruId => BooruType.danbooru,
      4 || kGelbooruId => BooruType.gelbooru,
      6 || 7 || 8 || 10 || kMoebooruId => BooruType.moebooru,
      9 || kGelbooruV2Id => BooruType.gelbooruV2,
      11 || 12 || kE621Id => BooruType.e621,
      13 || kZerochanId => BooruType.zerochan,
      14 || kGelbooruV1Id => BooruType.gelbooruV1,
      kSankaku => BooruType.sankaku,
      kPhilomenaId => BooruType.philomena,
      kShimmie2Id => BooruType.shimmie2,
      kSzurubooruId => BooruType.szurubooru,
      kHydrusId => BooruType.hydrus,
      kAnimePicturesId => BooruType.animePictures,
      _ => BooruType.unknown
    };

mixin PassHashAuthMixin {
  String? get loginUrl;
}
