// Project imports:
import '../../sankaku/types/types.dart';

class PostIdolDto {
  PostIdolDto({
    this.id,
    this.createdAt,
    this.tags,
    this.author,
    this.approver,
    this.parent,
    this.change,
    this.hasChildren,
    this.inVisiblePool,
    this.recommendedPosts,
    this.duration,
    this.favCount,
    this.voteCount,
    this.voteAverage,
    this.totalScore,
    this.isFavorited,
    this.md5,
    this.fileSize,
    this.fileUrl,
    this.previewUrl,
    this.previewWidth,
    this.previewHeight,
    this.sampleUrl,
    this.sampleWidth,
    this.sampleHeight,
    this.width,
    this.height,
    this.rating,
    this.parentId,
    this.status,
    this.hasComments,
    this.commentCount,
    this.hasNotes,
    this.noteCount,
    this.tagCounts,
    this.isNoteLocked,
    this.isRatingLocked,
    this.isStatusLocked,
  });

  factory PostIdolDto.fromJson(Map<String, dynamic> json) {
    return PostIdolDto(
      id: SankakuId.maybeFrom(json['id']),
      createdAt: json['created_at'],
      tags: (json['tags'] as List<dynamic>?)
          ?.map((e) => TagIdolDto.fromJson(e))
          .toList(),
      author: json['author'],
      approver: json['approver'],
      parent: json['parent'] != null
          ? MicroPostIdolDto.fromJson(json['parent'] as Map<String, dynamic>)
          : null,
      change: json['change'],
      hasChildren: json['has_children'],
      inVisiblePool: json['in_visible_pool'],
      recommendedPosts: json['recommended_posts'],
      duration: json['duration']?.toDouble(),
      favCount: json['fav_count'],
      voteCount: json['vote_count'],
      voteAverage: json['vote_average']?.toDouble(),
      totalScore: json['total_score'],
      isFavorited: json['is_favorited'],
      md5: json['md5'],
      fileSize: json['file_size'],
      fileUrl: _appendProtocol(json['file_url']),
      previewUrl: _appendProtocol(json['preview_url']),
      previewWidth: json['preview_width'],
      previewHeight: json['preview_height'],
      sampleUrl: _appendProtocol(json['sample_url']),
      sampleWidth: json['sample_width'],
      sampleHeight: json['sample_height'],
      width: json['width'],
      height: json['height'],
      rating: json['rating'],
      parentId: SankakuId.maybeFrom(json['parent_id']),
      status: json['status'],
      hasComments: json['has_comments'],
      commentCount: json['comment_count'],
      hasNotes: json['has_notes'],
      noteCount: json['note_count'],
      tagCounts: json['tag_counts'] != null
          ? TagCountsDto.fromJson(json['tag_counts'])
          : null,
      isNoteLocked: json['is_note_locked'],
      isRatingLocked: json['is_rating_locked'],
      isStatusLocked: json['is_status_locked'],
    );
  }

  final SankakuId? id;
  final String? createdAt;
  final List<TagIdolDto>? tags;
  final String? author;
  final String? approver;
  final MicroPostIdolDto? parent;
  final int? change;
  final bool? hasChildren;
  final bool? inVisiblePool;
  final int? recommendedPosts;
  final double? duration;
  final int? favCount;
  final int? voteCount;
  final double? voteAverage;
  final int? totalScore;
  final bool? isFavorited;
  final String? md5;
  final int? fileSize;
  final String? fileUrl;
  final String? previewUrl;
  final int? previewWidth;
  final int? previewHeight;
  final String? sampleUrl;
  final int? sampleWidth;
  final int? sampleHeight;
  final int? width;
  final int? height;
  final String? rating;
  final SankakuId? parentId;
  final String? status;
  final bool? hasComments;
  final int? commentCount;
  final bool? hasNotes;
  final int? noteCount;
  final TagCountsDto? tagCounts;
  final bool? isNoteLocked;
  final bool? isRatingLocked;
  final bool? isStatusLocked;
}

String? _appendProtocol(String? url) {
  if (url == null) return null;

  return url.startsWith('http') ? url : 'https:$url';
}

class TagIdolDto {
  TagIdolDto({
    this.id,
    this.name,
    this.nameEn,
    this.nameJa,
    this.count,
    this.type,
    this.rating,
  });

  factory TagIdolDto.fromJson(Map<String, dynamic> json) => TagIdolDto(
    id: SankakuId.maybeFrom(json['id']),
    name: json['name'],
    nameEn: json['name_en'],
    nameJa: json['name_ja'],
    count: json['count'],
    type: json['type'],
    rating: json['rating'],
  );

  final SankakuId? id;
  final String? name;
  final String? nameEn;
  final String? nameJa;
  final int? count;
  final int? type;
  final String? rating;
}

class TagCountsDto {
  TagCountsDto({
    this.meta,
    this.pose,
    this.role,
    this.fauna,
    this.flora,
    this.genre,
    this.tagme,
    this.total,
    this.artist,
    this.entity,
    this.medium,
    this.object,
    this.studio,
    this.anatomy,
    this.fashion,
    this.general,
    this.setting,
    this.activity,
    this.language,
    this.automatic,
    this.character,
    this.copyright,
    this.substance,
  });

  factory TagCountsDto.fromJson(Map<String, dynamic> json) => TagCountsDto(
    meta: json['meta'],
    pose: json['pose'],
    role: json['role'],
    fauna: json['fauna'],
    flora: json['flora'],
    genre: json['genre'],
    tagme: json['tagme'],
    total: json['total'],
    artist: json['artist'],
    entity: json['entity'],
    medium: json['medium'],
    object: json['object'],
    studio: json['studio'],
    anatomy: json['anatomy'],
    fashion: json['fashion'],
    general: json['general'],
    setting: json['setting'],
    activity: json['activity'],
    language: json['language'],
    automatic: json['automatic'],
    character: json['character'],
    copyright: json['copyright'],
    substance: json['substance'],
  );

  final int? meta;
  final int? pose;
  final int? role;
  final int? fauna;
  final int? flora;
  final int? genre;
  final int? tagme;
  final int? total;
  final int? artist;
  final int? entity;
  final int? medium;
  final int? object;
  final int? studio;
  final int? anatomy;
  final int? fashion;
  final int? general;
  final int? setting;
  final int? activity;
  final int? language;
  final int? automatic;
  final int? character;
  final int? copyright;
  final int? substance;
}

class MicroPostIdolDto {
  MicroPostIdolDto({
    this.id,
    this.tags,
    this.author,
    this.rating,
    this.status,
  });

  factory MicroPostIdolDto.fromJson(Map<String, dynamic> json) {
    final tags = json['tags'];

    return MicroPostIdolDto(
      id: SankakuId.maybeFrom(json['id']),
      tags: tags is String
          ? tags
                .split(' ')
                .where((t) => t.isNotEmpty)
                .map((t) => t.trim())
                .toList()
          : null,
      author: json['author'],
      rating: json['rating'],
      status: json['status'],
    );
  }

  final SankakuId? id;
  final List<String>? tags;
  final String? author;
  final String? rating;
  final String? status;
}
