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

enum PostCountMethod {
  notSupported,
  endpoint,
  search,
}
