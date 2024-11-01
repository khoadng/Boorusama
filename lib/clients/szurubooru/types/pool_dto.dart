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
      version: json['version'] as int?,
      id: json['id'] as int?,
      names: (json['names'] as List?)?.map((e) => e as String).toList(),
      category: json['category'] as String?,
      posts: json['posts'] != null
          ? (json['posts'] as List)
              .map((e) => MicroPostDto.fromJson(
                    e as Map<String, dynamic>,
                    baseUrl: baseUrl,
                  ))
              .toList()
          : null,
      creationTime: json['creationTime'] as String?,
      lastEditTime: json['lastEditTime'] as String?,
      postCount: json['postCount'] as int?,
      description: json['description'] as String?,
    );
  }

  final int? version;
  final int? id;
  final List<String>? names;
  final String? category;
  final List<MicroPostDto>? posts;
  final String? creationTime;
  final String? lastEditTime;
  final int? postCount;
  final String? description;
}

class PoolUpdateRequest {
  PoolUpdateRequest({
    required this.version,
    this.names,
    this.category,
    this.description,
    this.postIds,
  });

  PoolUpdateRequest copyWith({
    List<String>? Function()? names,
    String? Function()? category,
    String? Function()? description,
    List<int>? Function()? postIds,
  }) {
    return PoolUpdateRequest(
      version: version,
      names: names != null ? names() : this.names,
      category: category != null ? category() : this.category,
      description: description != null ? description() : this.description,
      postIds: postIds != null ? postIds() : this.postIds,
    );
  }

  final int version;
  final List<String>? names;
  final String? category;
  final String? description;
  final List<int>? postIds;

  Map<String, dynamic> toJson() {
    return {
      'version': version,
      if (names != null) 'names': names,
      if (category != null) 'category': category,
      if (description != null) 'description': description,
      if (postIds != null) 'posts': postIds,
    };
  }
}
