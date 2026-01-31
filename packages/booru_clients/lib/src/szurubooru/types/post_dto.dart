// Project imports:
import 'types.dart';

class PostDto {
  PostDto({
    this.id,
    this.version,
    this.creationTime,
    this.lastEditTime,
    this.safety,
    this.source,
    this.type,
    this.mimeType,
    this.checksum,
    this.checksumMD5,
    this.fileSize,
    this.canvasWidth,
    this.canvasHeight,
    this.contentUrl,
    this.thumbnailUrl,
    this.flags,
    this.tags,
    this.user,
    this.score,
    this.ownScore,
    this.ownFavorite,
    this.tagCount,
    this.favoriteCount,
    this.commentCount,
    this.noteCount,
    this.relationCount,
    this.featureCount,
    this.lastFeatureTime,
    this.favoritedBy,
    this.hasCustomThumbnail,
    this.notes,
    this.comments,
    this.pools,
  });

  // fromJson
  factory PostDto.fromJson(
    Map<String, dynamic> json, {
    String? baseUrl,
  }) {
    final contentUrl = json['contentUrl'] as String?;
    final thumbnailUrl = json['thumbnailUrl'] as String?;

    return PostDto(
      id: json['id'] as int?,
      version: SzurubooruVersion.maybeFrom(json['version']),
      creationTime: json['creationTime'] as String?,
      lastEditTime: json['lastEditTime'] as String?,
      safety: json['safety'] as String?,
      source: json['source'] as String?,
      type: json['type'] as String?,
      mimeType: json['mimeType'] as String?,
      checksum: json['checksum'] as String?,
      checksumMD5: json['checksumMD5'] as String?,
      fileSize: json['fileSize'] as int?,
      canvasWidth: json['canvasWidth'] as int?,
      canvasHeight: json['canvasHeight'] as int?,
      contentUrl: contentUrl != null ? '$baseUrl$contentUrl' : null,
      thumbnailUrl: thumbnailUrl != null ? '$baseUrl$thumbnailUrl' : null,
      flags: json['flags'] as List<dynamic>?,
      tags: (json['tags'] as List<dynamic>?)
          ?.map((e) => TagDto.fromJson(e as Map<String, dynamic>))
          .toList(),
      user: json['user'] != null
          ? UserDto.fromJson(json['user'] as Map<String, dynamic>)
          : null,
      score: json['score'] as int?,
      ownScore: json['ownScore'] as int?,
      ownFavorite: json['ownFavorite'] as bool?,
      tagCount: json['tagCount'] as int?,
      favoriteCount: json['favoriteCount'] as int?,
      commentCount: json['commentCount'] as int?,
      noteCount: json['noteCount'] as int?,
      relationCount: json['relationCount'] as int?,
      featureCount: json['featureCount'] as int?,
      lastFeatureTime: json['lastFeatureTime'] as String?,
      favoritedBy: json['favoritedBy'] as List<dynamic>?,
      hasCustomThumbnail: json['hasCustomThumbnail'] as bool?,
      notes: switch (json['notes']) {
        List<dynamic> list =>
          list
              .whereType<Map<String, dynamic>>()
              .map((e) => NoteDto.fromJson(e))
              .toList(),
        _ => null,
      },
      comments: (json['comments'] as List<dynamic>?)
          ?.map((e) => CommentDto.fromJson(e as Map<String, dynamic>))
          .toList(),
      pools: json['pools'] as List<dynamic>?,
    );
  }
  final int? id;
  final SzurubooruVersion? version;
  final String? creationTime;
  final String? lastEditTime;
  final String? safety;
  final String? source;
  final String? type;
  final String? mimeType;
  final String? checksum;
  final String? checksumMD5;
  final int? fileSize;
  final int? canvasWidth;
  final int? canvasHeight;
  final String? contentUrl;
  final String? thumbnailUrl;
  final List<dynamic>? flags;
  final List<TagDto>? tags;
  final UserDto? user;
  final int? score;
  final int? ownScore;
  final bool? ownFavorite;
  final int? tagCount;
  final int? favoriteCount;
  final int? commentCount;
  final int? noteCount;
  final int? relationCount;
  final int? featureCount;
  final String? lastFeatureTime;
  final List<dynamic>? favoritedBy;
  final bool? hasCustomThumbnail;
  final List<NoteDto>? notes;
  final List<CommentDto>? comments;
  final List<dynamic>? pools;
}

class UserDto {
  UserDto({
    this.name,
    this.avatarUrl,
  });

  factory UserDto.fromJson(Map<String, dynamic> json) {
    return UserDto(
      name: json['name'] as String?,
      avatarUrl: json['avatarUrl'] as String?,
    );
  }
  final String? name;
  final String? avatarUrl;
}

// A post resource stripped down to id and thumbnailUrl fields.
class MicroPostDto {
  const MicroPostDto({
    this.id,
    this.thumbnailUrl,
  });

  factory MicroPostDto.fromJson(Map<String, dynamic> json, {String? baseUrl}) {
    final thumbnailUrl = json['thumbnailUrl'] as String?;
    return MicroPostDto(
      id: json['id'] as int?,
      thumbnailUrl: thumbnailUrl != null ? '$baseUrl$thumbnailUrl' : null,
    );
  }

  final int? id;
  final String? thumbnailUrl;
}
