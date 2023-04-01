// Package imports:
import 'package:equatable/equatable.dart';

// Project imports:
import 'package:boorusama/utils/collection_utils.dart';

class BooruData {
  BooruData({
    required this.name,
    required this.url,
    required this.cheatsheet,
  });

  factory BooruData.fromJson(Map<String, dynamic> json) => BooruData(
        name: json['name'],
        url: json['url'],
        cheatsheet: json['cheatsheet'],
      );

  final String name;
  final String url;
  final String cheatsheet;

  Map<String, dynamic> toJson() => {
        'name': name,
        'url': url,
        'cheatsheet': cheatsheet,
      };
}

class Booru extends Equatable {
  const Booru({
    required this.url,
    required this.booruType,
    required this.name,
    required this.cheatsheet,
  });

  final String url;
  final BooruType booruType;
  final String name;
  final String cheatsheet;

  static const Booru empty = Booru(
    url: '',
    booruType: BooruType.unknown,
    name: '',
    cheatsheet: '',
  );

  @override
  List<Object?> get props => [url, booruType, name, cheatsheet];
}

enum BooruType {
  unknown,
  danbooru,
  safebooru,
  testbooru,
  gelbooru,
  aibooru,
  konachan,
}

extension BooruX on Booru {
  String getIconUrl({
    int? size,
  }) =>
      'https://www.google.com/s2/favicons?domain=${url}&sz=${size ?? 64}';
}

extension BooruTypeX on BooruType {
  String stringify() {
    switch (this) {
      case BooruType.unknown:
        return '<UNKNOWN>';
      case BooruType.danbooru:
        return 'Danbooru';
      case BooruType.safebooru:
        return 'Danbooru (G)';
      case BooruType.testbooru:
        return 'Testbooru';
      case BooruType.gelbooru:
        return 'Gelbooru';
      case BooruType.aibooru:
        return 'AIBooru';
      case BooruType.konachan:
        return 'Konachan';
    }
  }
}

Booru safebooru() => booruDataToBooru(
      BooruData(
        name: 'safebooru',
        url: 'https://safebooru.donmai.us/',
        cheatsheet: 'https://safebooru.donmai.us/wiki_pages/help:cheatsheet',
      ),
    );

List<BooruType> getSelectableBoorus() => [
      BooruType.danbooru,
      BooruType.gelbooru,
      BooruType.aibooru,
      BooruType.safebooru,
      BooruType.konachan,
    ];

Booru booruDataToBooru(BooruData d) {
  return Booru(
    url: d.url,
    booruType: _stringToBooruType(d.name),
    name: d.name,
    cheatsheet: d.cheatsheet,
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
    case 6:
      return BooruType.konachan;
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
    case 'konachan':
      return BooruType.konachan;
    default:
      return BooruType.unknown;
  }
}

BooruType getBooruType(String url, List<BooruData> booruDataList) {
  return _stringToBooruType(
      booruDataList.firstOrNull((e) => e.url == url)?.name ?? '');
}
