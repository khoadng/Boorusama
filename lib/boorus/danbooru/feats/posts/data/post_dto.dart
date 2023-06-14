class PostDto {
  PostDto({
    required this.id,
    required this.createdAt,
    required this.uploaderId,
    required this.score,
    required this.source,
    required this.md5,
    required this.lastCommentBumpedAt,
    required this.rating,
    required this.imageWidth,
    required this.imageHeight,
    required this.tagString,
    required this.favCount,
    required this.fileExt,
    required this.lastNotedAt,
    required this.parentId,
    required this.hasChildren,
    required this.approverId,
    required this.tagCountGeneral,
    required this.tagCountArtist,
    required this.tagCountCharacter,
    required this.tagCountCopyright,
    required this.fileSize,
    required this.upScore,
    required this.downScore,
    required this.isPending,
    required this.isFlagged,
    required this.isDeleted,
    required this.tagCount,
    required this.updatedAt,
    required this.isBanned,
    required this.pixivId,
    required this.lastCommentedAt,
    required this.hasActiveChildren,
    required this.bitFlags,
    required this.tagCountMeta,
    required this.hasLarge,
    required this.hasVisibleChildren,
    required this.mediaAsset,
    required this.tagStringGeneral,
    required this.tagStringCharacter,
    required this.tagStringCopyright,
    required this.tagStringArtist,
    required this.tagStringMeta,
    required this.fileUrl,
    required this.largeFileUrl,
    required this.previewFileUrl,
  });

  factory PostDto.fromJson(Map<String, dynamic> json) {
    return PostDto(
      id: json['id'],
      createdAt: json['created_at'],
      uploaderId: json['uploader_id'],
      score: json['score'],
      source: json['source'],
      md5: json['md5'],
      lastCommentBumpedAt: json['last_comment_bumped_at'],
      rating: json['rating'],
      imageWidth: json['image_width'],
      imageHeight: json['image_height'],
      tagString: json['tag_string'],
      favCount: json['fav_count'],
      fileExt: json['file_ext'],
      lastNotedAt: json['last_noted_at'],
      parentId: json['parent_id'],
      hasChildren: json['has_children'],
      approverId: json['approver_id'],
      tagCountGeneral: json['tag_count_general'],
      tagCountArtist: json['tag_count_artist'],
      tagCountCharacter: json['tag_count_character'],
      tagCountCopyright: json['tag_count_copyright'],
      fileSize: json['file_size'],
      upScore: json['up_score'],
      downScore: json['down_score'],
      isPending: json['is_pending'],
      isFlagged: json['is_flagged'],
      isDeleted: json['is_deleted'],
      tagCount: json['tag_count'],
      updatedAt: json['updated_at'],
      isBanned: json['is_banned'],
      pixivId: json['pixiv_id'],
      lastCommentedAt: json['last_commented_at'],
      hasActiveChildren: json['has_active_children'],
      bitFlags: json['bit_flags'],
      tagCountMeta: json['tag_count_meta'],
      hasLarge: json['has_large'],
      hasVisibleChildren: json['has_visible_children'],
      mediaAsset: json['media_asset'] != null
          ? MediaAssetDto.fromJson(json['media_asset'])
          : null,
      tagStringGeneral: json['tag_string_general'],
      tagStringCharacter: json['tag_string_character'],
      tagStringCopyright: json['tag_string_copyright'],
      tagStringArtist: json['tag_string_artist'],
      tagStringMeta: json['tag_string_meta'],
      fileUrl: json['file_url'],
      largeFileUrl: json['large_file_url'],
      previewFileUrl: json['preview_file_url'],
    );
  }

  final int? id;
  final String? createdAt;
  final int? uploaderId;
  final int? score;
  final String? source;
  final String? md5;
  final String? lastCommentBumpedAt;
  final String? rating;
  final int? imageWidth;
  final int? imageHeight;
  final String? tagString;
  final int? favCount;
  final String? fileExt;
  final String? lastNotedAt;
  final int? parentId;
  final bool? hasChildren;
  final int? approverId;
  final int? tagCountGeneral;
  final int? tagCountArtist;
  final int? tagCountCharacter;
  final int? tagCountCopyright;
  final int? fileSize;
  final int? upScore;
  final int? downScore;
  final bool? isPending;
  final bool? isFlagged;
  final bool? isDeleted;
  final int? tagCount;
  final String? updatedAt;
  final bool? isBanned;
  final int? pixivId;
  final String? lastCommentedAt;
  final bool? hasActiveChildren;
  final int? bitFlags;
  final int? tagCountMeta;
  final bool? hasLarge;
  final bool? hasVisibleChildren;
  final MediaAssetDto? mediaAsset;
  final String? tagStringGeneral;
  final String? tagStringCharacter;
  final String? tagStringCopyright;
  final String? tagStringArtist;
  final String? tagStringMeta;
  final String? fileUrl;
  final String? largeFileUrl;
  final String? previewFileUrl;
}

class MediaAssetDto {
  MediaAssetDto({
    this.id,
    this.createdAt,
    this.updatedAt,
    this.md5,
    this.fileExt,
    this.fileSize,
    this.imageWidth,
    this.imageHeight,
    this.duration,
    this.status,
    this.fileKey,
    this.isPublic,
    this.pixelHash,
    this.variants,
  });

  factory MediaAssetDto.fromJson(Map<String, dynamic> json) {
    return MediaAssetDto(
      id: json['id'],
      createdAt: json['created_at'],
      updatedAt: json['updated_at'],
      md5: json['md5'],
      fileExt: json['file_ext'],
      fileSize: json['file_size'],
      imageWidth: json['image_width'],
      imageHeight: json['image_height'],
      duration: json['duration'],
      status: json['status'],
      fileKey: json['file_key'],
      isPublic: json['is_public'],
      pixelHash: json['pixel_hash'],
      variants: json['variants'] != null
          ? (json['variants'] as List)
              .map((variant) => VariantDto.fromJson(variant))
              .toList()
          : null,
    );
  }

  final int? id;
  final String? createdAt;
  final String? updatedAt;
  final String? md5;
  final String? fileExt;
  final int? fileSize;
  final int? imageWidth;
  final int? imageHeight;
  final double? duration;
  final String? status;
  final String? fileKey;
  final bool? isPublic;
  final String? pixelHash;
  final List<VariantDto>? variants;
}

class VariantDto {
  VariantDto({
    this.type,
    this.url,
    this.width,
    this.height,
    this.fileExt,
  });

  factory VariantDto.fromJson(Map<String, dynamic> json) {
    return VariantDto(
      type: json['type'],
      url: json['url'],
      width: json['width'],
      height: json['height'],
      fileExt: json['file_ext'],
    );
  }

  final String? type;
  final String? url;
  final int? width;
  final int? height;
  final String? fileExt;
}
