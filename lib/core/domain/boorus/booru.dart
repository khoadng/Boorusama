// Package imports:
import 'package:equatable/equatable.dart';

class BooruData {
  BooruData({
    required this.name,
    required this.url,
  });

  factory BooruData.fromJson(Map<String, dynamic> json) => BooruData(
        name: json['name'],
        url: json['url'],
      );

  final String name;
  final String url;

  Map<String, dynamic> toJson() => {
        'name': name,
        'url': url,
      };
}

class Booru extends Equatable {
  const Booru({
    required this.url,
    required this.booruType,
    required this.name,
  });

  final String url;
  final BooruType booruType;
  final String name;

  static const Booru empty = Booru(
    url: '',
    booruType: BooruType.unknown,
    name: '',
  );

  @override
  List<Object?> get props => [url, booruType, name];
}

enum BooruType {
  unknown,
  danbooru,
  safebooru,
  testbooru,
  gelbooru,
  aibooru,
}

Booru safebooru() => booruDataToBooru(
      BooruData(
        name: 'safebooru',
        url: 'https://safebooru.donmai.us/',
      ),
    );

List<BooruType> getSelectableBoorus() => [
      BooruType.danbooru,
      BooruType.gelbooru,
      BooruType.aibooru,
      BooruType.safebooru,
    ];

Booru booruDataToBooru(BooruData d) {
  return Booru(
    url: d.url,
    booruType: _stringToBooruType(d.name),
    name: d.name,
  );
}

BooruType intToBooruType(int value) {
  switch (value) {
    case 1:
      return BooruType.danbooru;
    case 2:
      return BooruType.safebooru;
    case 3:
      return BooruType.testbooru;
    case 4:
      return BooruType.gelbooru;
    case 5:
      return BooruType.aibooru;
    default:
      return BooruType.unknown;
  }
}

BooruType _stringToBooruType(String value) {
  switch (value) {
    case 'danbooru':
      return BooruType.danbooru;
    case 'safebooru':
      return BooruType.safebooru;
    case 'testbooru':
      return BooruType.testbooru;
    case 'gelbooru':
      return BooruType.gelbooru;
    case 'aibooru':
      return BooruType.aibooru;
    default:
      return BooruType.unknown;
  }
}
