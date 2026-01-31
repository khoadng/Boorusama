// Project imports:
import 'types.dart';

class PoolDto {
  PoolDto({
    this.version,
    this.id,
    this.names,
    this.category,
    this.posts,
    this.creationTime,
    this.lastEditTime,
    this.postCount,
    this.description,
  });

  factory PoolDto.fromJson(Map<String, dynamic> json, {String? baseUrl}) {
    return PoolDto(
      version: SzurubooruVersion.maybeFrom(json['version']),
      id: json['id'] as int?,
      names: (json['names'] as List?)?.map((e) => e as String).toList(),
      category: json['category'] as String?,
      posts: json['posts'] != null
          ? (json['posts'] as List)
                .map(
                  (e) => MicroPostDto.fromJson(
                    e as Map<String, dynamic>,
                    baseUrl: baseUrl,
                  ),
                )
                .toList()
          : null,
      creationTime: json['creationTime'] as String?,
      lastEditTime: json['lastEditTime'] as String?,
      postCount: json['postCount'] as int?,
      description: json['description'] as String?,
    );
  }

  final SzurubooruVersion? version;
  final int? id;
  final List<String>? names;
  final String? category;
  final List<MicroPostDto>? posts;
  final String? creationTime;
  final String? lastEditTime;
  final int? postCount;
  final String? description;
}
