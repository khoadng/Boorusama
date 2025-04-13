// Project imports:
import 'common.dart';

class TagDto {
  TagDto({
    this.id,
    this.nameEn,
    this.nameJa,
    this.type,
    this.count,
    this.postCount,
    this.poolCount,
    this.seriesCount,
    this.locale,
    this.rating,
    this.version,
    this.tagName,
    this.totalPostCount,
    this.totalPoolCount,
    this.name,
    this.aliasOf,
  });

  factory TagDto.fromJson(Map<String, dynamic> json) {
    return TagDto(
      id: SankakuId.maybeFrom(json['id']),
      nameEn: json['name_en'],
      nameJa: json['name_ja'],
      type: json['type'],
      count: json['count'],
      postCount: json['post_count'],
      poolCount: json['pool_count'],
      seriesCount: json['series_count'],
      locale: json['locale'],
      rating: json['rating'],
      version: json['version'],
      tagName: json['tagName'],
      totalPostCount: json['total_post_count'],
      totalPoolCount: json['total_pool_count'],
      name: json['name'],
      aliasOf: json['alias_of'] != null
          ? MicroTagDto.fromJson(json['alias_of'])
          : null,
    );
  }

  final SankakuId? id;
  final String? nameEn;
  final String? nameJa;
  final int? type;
  final int? count;
  final int? postCount;
  final int? poolCount;
  final int? seriesCount;
  final String? locale;
  final String? rating;
  final int? version;
  final String? tagName;
  final int? totalPostCount;
  final int? totalPoolCount;
  final String? name;
  final MicroTagDto? aliasOf;

  @override
  String toString() => '$name ($count)';
}

class MicroTagDto {
  MicroTagDto({
    required this.id,
    this.tagName,
    this.postCount,
    this.type,
    this.rating,
  });

  factory MicroTagDto.fromJson(Map<String, dynamic> json) {
    return MicroTagDto(
      id: SankakuId.maybeFrom(json['id']),
      tagName: json['tagName'],
      postCount: json['post_count'],
      type: json['type'],
      rating: json['rating'],
    );
  }

  final SankakuId? id;
  final String? tagName;
  final int? postCount;
  final int? type;
  final String? rating;
}
