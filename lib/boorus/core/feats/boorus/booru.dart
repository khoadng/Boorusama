// Package imports:
import 'package:equatable/equatable.dart';

// Project imports:
import 'package:boorusama/utils/collection_utils.dart';
import 'booru_data.dart';

class Booru extends Equatable {
  const Booru({
    required this.url,
    required this.booruType,
    required this.name,
    required this.cheatsheet,
    required this.loginType,
  });

  final String url;
  final BooruType booruType;
  final String name;
  final String cheatsheet;
  final LoginType loginType;

  static const Booru empty = Booru(
    url: '',
    booruType: BooruType.unknown,
    name: '',
    cheatsheet: '',
    loginType: LoginType.loginAndApiKey,
  );

  @override
  List<Object?> get props => [url, booruType, name, cheatsheet, loginType];
}

enum BooruType {
  unknown,
  danbooru,
  safebooru,
  testbooru,
  gelbooru,
  aibooru,
  konachan,
  yandere,
  sakugabooru,
  rule34xxx,
}

enum BooruEngine {
  danbooru,
  gelbooru,
  gelbooruV0Dot2,
  moebooru,
}

enum LoginType {
  loginAndApiKey,
  loginAndPasswordHashed,
}

extension BooruEngineX on BooruEngine {
  String stringify() => switch (this) {
        BooruEngine.danbooru => 'Danbooru',
        BooruEngine.gelbooru => 'Gelbooru',
        BooruEngine.gelbooruV0Dot2 => 'Gelbooru v0.2',
        BooruEngine.moebooru => 'Moebooru',
      };
}

extension BooruTypeX on BooruType {
  String stringify() => switch (this) {
        BooruType.unknown => '<UNKNOWN>',
        BooruType.danbooru => 'Danbooru',
        BooruType.safebooru => 'Danbooru (G)',
        BooruType.testbooru => 'Testbooru',
        BooruType.gelbooru => 'Gelbooru',
        BooruType.rule34xxx => 'Rule34',
        BooruType.aibooru => 'AIBooru',
        BooruType.konachan => 'Konachan',
        BooruType.yandere => 'Yandere',
        BooruType.sakugabooru => 'Sakugabooru'
      };

  bool get isGelbooruBased =>
      this == BooruType.gelbooru || this == BooruType.rule34xxx;

  bool get isMoeBooruBased => [
        BooruType.sakugabooru,
        BooruType.yandere,
        BooruType.konachan,
      ].contains(this);

  bool get isDanbooruBased => [
        BooruType.aibooru,
        BooruType.danbooru,
        BooruType.testbooru,
        BooruType.safebooru,
      ].contains(this);

  bool get supportTagDetails => this == BooruType.gelbooru || isDanbooruBased;

  int toBooruId() => switch (this) {
        BooruType.danbooru => 1,
        BooruType.safebooru => 2,
        BooruType.testbooru => 3,
        BooruType.gelbooru => 4,
        BooruType.aibooru => 5,
        BooruType.konachan => 6,
        BooruType.yandere => 7,
        BooruType.sakugabooru => 8,
        BooruType.rule34xxx => 9,
        BooruType.unknown => 0,
      };
}

LoginType stringToLoginType(String value) => switch (value) {
      'login_api_key' => LoginType.loginAndApiKey,
      'login_password_hashed' => LoginType.loginAndPasswordHashed,
      _ => throw ArgumentError('Invalid login type: $value')
    };

BooruType intToBooruType(int value) => switch (value) {
      1 => BooruType.danbooru,
      2 => BooruType.safebooru,
      3 => BooruType.testbooru,
      4 => BooruType.gelbooru,
      5 => BooruType.aibooru,
      6 => BooruType.konachan,
      7 => BooruType.yandere,
      8 => BooruType.sakugabooru,
      9 => BooruType.rule34xxx,
      _ => BooruType.unknown
    };

BooruType stringToBooruType(String value) => switch (value) {
      'danbooru' => BooruType.danbooru,
      'safebooru' => BooruType.safebooru,
      'testbooru' => BooruType.testbooru,
      'gelbooru' => BooruType.gelbooru,
      'rule34xxx' => BooruType.rule34xxx,
      'aibooru' => BooruType.aibooru,
      'konachan' => BooruType.konachan,
      'yandere' => BooruType.yandere,
      'sakugabooru' => BooruType.sakugabooru,
      _ => BooruType.unknown
    };

BooruType getBooruType(String url, List<BooruData> booruDataList) =>
    stringToBooruType(
        booruDataList.firstOrNull((e) => e.url == url)?.name ?? '');

BooruType booruEngineToBooruType(BooruEngine engine) => switch (engine) {
      BooruEngine.danbooru => BooruType.danbooru,
      BooruEngine.gelbooru => BooruType.gelbooru,
      BooruEngine.gelbooruV0Dot2 => BooruType.rule34xxx,
      BooruEngine.moebooru => BooruType.yandere
    };
