enum BooruType {
  unknown(0),
  danbooru(20),
  gelbooru(21),
  gelbooruV1(22),
  gelbooruV2(23),
  moebooru(24),
  e621(25),
  zerochan(26),
  sankaku(27),
  philomena(28),
  shimmie2(29),
  szurubooru(30),
  hydrus(31),
  animePictures(32);

  const BooruType(this.id);
  final int id;

  /// Maps legacy IDs to the corresponding BooruType
  static BooruType fromLegacyId(int? value) => switch (value) {
        1 || 2 || 3 || 5 || 20 => BooruType.danbooru,
        4 || 21 => BooruType.gelbooru,
        6 || 7 || 8 || 10 || 24 => BooruType.moebooru,
        9 || 23 => BooruType.gelbooruV2,
        11 || 12 || 25 => BooruType.e621,
        13 || 26 => BooruType.zerochan,
        14 || 22 => BooruType.gelbooruV1,
        27 => BooruType.sankaku,
        28 => BooruType.philomena,
        29 => BooruType.shimmie2,
        30 => BooruType.szurubooru,
        31 => BooruType.hydrus,
        32 => BooruType.animePictures,
        _ => BooruType.unknown
      };

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

  PostCountMethod get postCountMethod => switch (this) {
        BooruType.danbooru => PostCountMethod.endpoint,
        BooruType.gelbooru => PostCountMethod.search,
        BooruType.moebooru => PostCountMethod.notSupported,
        BooruType.gelbooruV2 => PostCountMethod.notSupported,
        BooruType.e621 => PostCountMethod.notSupported,
        BooruType.zerochan => PostCountMethod.notSupported,
        BooruType.gelbooruV1 => PostCountMethod.notSupported,
        BooruType.sankaku => PostCountMethod.notSupported,
        BooruType.philomena => PostCountMethod.search,
        BooruType.shimmie2 => PostCountMethod.notSupported,
        BooruType.szurubooru => PostCountMethod.search,
        BooruType.hydrus => PostCountMethod.notSupported,
        BooruType.animePictures => PostCountMethod.notSupported,
        BooruType.unknown => PostCountMethod.notSupported,
      };
}

// Backwards compatibility function - replaced by BooruType.fromLegacyId
BooruType intToBooruType(int? value) => BooruType.fromLegacyId(value);

enum PostCountMethod {
  notSupported,
  endpoint,
  search,
}
