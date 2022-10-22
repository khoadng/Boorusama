class PostDto {
  PostDto({
    this.id,
    required this.createdAt,
    required this.uploaderId,
    required this.score,
    required this.source,
    required this.md5,
    this.lastCommentBumpedAt,
    required this.rating,
    required this.imageWidth,
    required this.imageHeight,
    required this.tags,
    required this.favCount,
    required this.fileExt,
    this.lastNotedAt,
    this.parentId,
    required this.hasChildren,
    this.approverId,
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
    this.pixivId,
    this.lastCommentedAt,
    required this.hasActiveChildren,
    required this.bitFlags,
    required this.tagCountMeta,
    required this.hasLarge,
    required this.hasVisibleChildren,
    required this.generalTags,
    required this.characterTags,
    required this.copyrightTags,
    required this.artistTags,
    required this.tagsMeta,
    required this.fileUrl,
    required this.largeFileUrl,
    required this.previewFileUrl,
    required this.comments,
    this.artistCommentary,
  });

  factory PostDto.fromJson(Map<String, dynamic> json) => PostDto(
        id: json['id'],
        createdAt: DateTime.parse(json['created_at']),
        uploaderId: json['uploader_id'],
        score: json['score'],
        source: json['source'],
        md5: json['md5'],
        lastCommentBumpedAt: json['last_comment_bumped_at'] != null
            ? DateTime.parse(json['last_comment_bumped_at'])
            : null,
        rating: json['rating'],
        imageWidth: json['image_width'],
        imageHeight: json['image_height'],
        tags: json['tag_string'],
        favCount: json['fav_count'],
        fileExt: json['file_ext'],
        lastNotedAt: json['last_noted_at'] != null
            ? DateTime.parse(json['last_noted_at'])
            : null,
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
        updatedAt: DateTime.parse(json['updated_at']),
        isBanned: json['is_banned'],
        pixivId: json['pixiv_id'],
        lastCommentedAt: json['last_commented_at'] != null
            ? DateTime.parse(json['last_commented_at'])
            : null,
        hasActiveChildren: json['has_active_children'],
        bitFlags: json['bit_flags'],
        tagCountMeta: json['tag_count_meta'],
        hasLarge: json['has_large'],
        hasVisibleChildren: json['has_visible_children'],
        generalTags: json['tag_string_general'],
        characterTags: json['tag_string_character'],
        copyrightTags: json['tag_string_copyright'],
        artistTags: json['tag_string_artist'],
        tagsMeta: json['tag_string_meta'],
        fileUrl: json['file_url'],
        largeFileUrl: json['large_file_url'],
        previewFileUrl: json['preview_file_url'],
        comments: json['comments'],
        artistCommentary: json['artist_commentary'],
      );

  final int? id;
  final DateTime createdAt;
  final int uploaderId;
  final int score;
  final String source;
  final String? md5;
  final DateTime? lastCommentBumpedAt;
  final String rating;
  final int imageWidth;
  final int imageHeight;
  final String tags;
  final int favCount;
  final String fileExt;
  final DateTime? lastNotedAt;
  final int? parentId;
  final bool hasChildren;
  final int? approverId;
  final int tagCountGeneral;
  final int tagCountArtist;
  final int tagCountCharacter;
  final int tagCountCopyright;
  final int fileSize;
  final int upScore;
  final int downScore;
  final bool isPending;
  final bool isFlagged;
  final bool isDeleted;
  final int tagCount;
  final DateTime updatedAt;
  final bool isBanned;
  final int? pixivId;
  final DateTime? lastCommentedAt;
  final bool hasActiveChildren;
  final int bitFlags;
  final int tagCountMeta;
  final bool? hasLarge;
  final bool hasVisibleChildren;
  final String generalTags;
  final String characterTags;
  final String copyrightTags;
  final String artistTags;
  final String tagsMeta;
  final String? fileUrl;
  final String? largeFileUrl;
  final String? previewFileUrl;
  final List<dynamic> comments;
  final dynamic artistCommentary;
}
