// Package imports:
import 'package:equatable/equatable.dart';

class BooruType extends Equatable {
  const BooruType._({
    required this.name,
    required this.yamlName,
    required this.id,
    required this.displayName,
    this.canDownloadMultipleFiles = true,
    this.hasUnknownFullImageUrl = false,
    this.postCountMethod = PostCountMethod.notSupported,
    this.isSingleSite = false,
  });

  final String name;
  final String yamlName;
  final int id;
  final String displayName;
  final bool canDownloadMultipleFiles;
  final bool hasUnknownFullImageUrl;
  final PostCountMethod postCountMethod;
  final bool isSingleSite;

  static const unknown = BooruType._(
    name: 'unknown',
    yamlName: '',
    id: 0,
    displayName: 'UNKNOWN',
    isSingleSite: true,
  );

  static const danbooru = BooruType._(
    name: 'danbooru',
    yamlName: 'danbooru',
    id: 20,
    displayName: 'Danbooru',
    postCountMethod: PostCountMethod.endpoint,
  );

  static const gelbooru = BooruType._(
    name: 'gelbooru',
    yamlName: 'gelbooru',
    id: 21,
    displayName: 'Gelbooru 0.2.5',
    postCountMethod: PostCountMethod.search,
    isSingleSite: true,
  );

  static const gelbooruV1 = BooruType._(
    name: 'gelbooruV1',
    yamlName: 'gelbooru_v1',
    id: 22,
    displayName: 'Gelbooru 0.1.x',
    hasUnknownFullImageUrl: true,
  );

  static const gelbooruV2 = BooruType._(
    name: 'gelbooruV2',
    yamlName: 'gelbooru_v2',
    id: 23,
    displayName: 'Gelbooru 0.2',
  );

  static const moebooru = BooruType._(
    name: 'moebooru',
    yamlName: 'moebooru',
    id: 24,
    displayName: 'Moebooru',
  );

  static const e621 = BooruType._(
    name: 'e621',
    yamlName: 'e621',
    id: 25,
    displayName: 'e621',
  );

  static const zerochan = BooruType._(
    name: 'zerochan',
    yamlName: 'zerochan',
    id: 26,
    displayName: 'Zerochan',
    hasUnknownFullImageUrl: true,
  );

  static const sankaku = BooruType._(
    name: 'sankaku',
    yamlName: 'sankaku',
    id: 27,
    displayName: 'Sankaku',
  );

  static const philomena = BooruType._(
    name: 'philomena',
    yamlName: 'philomena',
    id: 28,
    displayName: 'Philomena',
  );

  static const shimmie2 = BooruType._(
    name: 'shimmie2',
    yamlName: 'shimmie2',
    id: 29,
    displayName: 'Shimmie2',
  );

  static const szurubooru = BooruType._(
    name: 'szurubooru',
    yamlName: 'szurubooru',
    id: 30,
    displayName: 'Szurubooru',
  );

  static const hydrus = BooruType._(
    name: 'hydrus',
    yamlName: 'hydrus',
    id: 31,
    displayName: 'Hydrus',
  );

  static const animePictures = BooruType._(
    name: 'animePictures',
    yamlName: 'anime-pictures',
    id: 32,
    displayName: 'Anime Pictures',
    canDownloadMultipleFiles: false,
    isSingleSite: true,
  );

  static const hybooru = BooruType._(
    name: 'hybooru',
    yamlName: 'hybooru',
    id: 33,
    displayName: 'Hybooru',
    postCountMethod: PostCountMethod.endpoint,
  );

  /// Maps legacy IDs to the corresponding BooruType
  static BooruType fromLegacyId(int? value) => switch (value) {
        1 || 2 || 3 || 5 || 20 => danbooru,
        4 || 21 => gelbooru,
        6 || 7 || 8 || 10 || 24 => moebooru,
        9 || 23 => gelbooruV2,
        11 || 12 || 25 => e621,
        13 || 26 => zerochan,
        14 || 22 => gelbooruV1,
        27 => sankaku,
        28 => philomena,
        29 => shimmie2,
        30 => szurubooru,
        31 => hydrus,
        32 => animePictures,
        33 => hybooru,
        _ => unknown
      };

  @override
  List<Object?> get props => [id, yamlName, name, isSingleSite];
}

// Backwards compatibility function - replaced by BooruType.fromLegacyId
BooruType intToBooruType(int? value) => BooruType.fromLegacyId(value);

enum PostCountMethod {
  notSupported,
  endpoint,
  search,
}
