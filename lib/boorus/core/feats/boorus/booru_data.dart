// Project imports:
import 'booru.dart';

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
