// Package imports:
import 'package:equatable/equatable.dart';

// Project imports:
import 'package:boorusama/utils/collection_utils.dart';

class BooruData {
  BooruData({
    required this.name,
    required this.url,
    required this.cheatsheet,
    required this.loginType,
  });

  factory BooruData.fromJson(Map<String, dynamic> json) => BooruData(
        name: json['name'],
        url: json['url'],
        cheatsheet: json['cheatsheet'],
        loginType: json['login_type'],
      );

  final String name;
  final String url;
  final String cheatsheet;
  final String loginType;

  Map<String, dynamic> toJson() => {
        'name': name,
        'url': url,
        'cheatsheet': cheatsheet,
        'login_type': loginType,
      };
}

class BooruSaltData {
  final String booru;
  final String salt;

  BooruSaltData({
    required this.booru,
    required this.salt,
  });

  factory BooruSaltData.fromJson(Map<String, dynamic> json) {
    return BooruSaltData(
      booru: json['booru'],
      salt: json['salt'],
    );
  }
}

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
}

Booru safebooru() => booruDataToBooru(
      BooruData(
        name: 'safebooru',
        url: 'https://safebooru.donmai.us/',
        cheatsheet: 'https://safebooru.donmai.us/wiki_pages/help:cheatsheet',
        loginType: 'login_api_key',
      ),
    );

Booru unknownBooru() => booruDataToBooru(
      BooruData(
        name: '',
        url: '',
        cheatsheet: '',
        loginType: 'login_api_key',
      ),
    );

Booru booruDataToBooru(BooruData d) {
  return Booru(
    url: d.url,
    booruType: stringToBooruType(d.name),
    name: d.name,
    cheatsheet: d.cheatsheet,
    loginType: stringToLoginType(d.loginType),
  );
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

int booruTypeToInt(BooruType booru) => switch (booru) {
      BooruType.danbooru => 1,
      BooruType.safebooru => 2,
      BooruType.testbooru => 3,
      BooruType.gelbooru => 4,
      BooruType.aibooru => 5,
      BooruType.konachan => 6,
      BooruType.yandere => 7,
      BooruType.sakugabooru => 8,
      BooruType.rule34xxx => 9,
      _ => 0
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
