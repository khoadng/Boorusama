// Project imports:
import 'tag_dto.dart';

class PostDto {

  PostDto({
    this.id,
    this.rating,
    this.status,
    this.author,
    this.sampleUrl,
    this.sampleWidth,
    this.sampleHeight,
    this.previewUrl,
    this.previewWidth,
    this.previewHeight,
    this.fileUrl,
    this.width,
    this.height,
    this.fileSize,
    this.fileType,
    this.createdAt,
    this.hasChildren,
    this.hasComments,
    this.hasNotes,
    this.isFavorited,
    // this.userVote,
    this.md5,
    this.parentId,
    this.change,
    this.favCount,
    this.recommendedPosts,
    this.recommendedScore,
    this.voteCount,
    this.totalScore,
    this.commentCount,
    this.source,
    this.inVisiblePool,
    this.isPremium,
    this.isRatingLocked,
    this.isNoteLocked,
    this.isStatusLocked,
    this.redirectToSignup,
    // this.sequence,
    this.tags,
    this.videoDuration,
    this.reactions,
  });

  factory PostDto.fromJson(Map<String, dynamic> json) {
    return PostDto(
      id: json['id'],
      rating: json['rating'],
      status: json['status'],
      author:
          json['author'] != null ? AuthorDto.fromJson(json['author']) : null,
      sampleUrl: json['sample_url'],
      sampleWidth: json['sample_width'],
      sampleHeight: json['sample_height'],
      previewUrl: json['preview_url'],
      previewWidth: json['preview_width'],
      previewHeight: json['preview_height'],
      fileUrl: json['file_url'],
      width: json['width'],
      height: json['height'],
      fileSize: json['file_size'],
      fileType: json['file_type'],
      createdAt: json['created_at'] != null
          ? CreatedAtDto.fromJson(json['created_at'])
          : null,
      hasChildren: json['has_children'],
      hasComments: json['has_comments'],
      hasNotes: json['has_notes'],
      isFavorited: json['is_favorited'],
      md5: json['md5'],
      parentId: json['parent_id'],
      change: json['change'],
      favCount: json['fav_count'],
      recommendedPosts: json['recommended_posts'],
      recommendedScore: json['recommended_score'],
      voteCount: json['vote_count'],
      totalScore: json['total_score'],
      commentCount: json['comment_count'],
      source: json['source'],
      inVisiblePool: json['in_visible_pool'],
      isPremium: json['is_premium'],
      isRatingLocked: json['is_rating_locked'],
      isNoteLocked: json['is_note_locked'],
      isStatusLocked: json['is_status_locked'],
      redirectToSignup: json['redirect_to_signup'],
      tags: (json['tags'] as List<dynamic>?)
          ?.map((e) => TagDto.fromJson(e))
          .toList(),
      videoDuration: switch (json['video_duration']) {
        double v => v,
        int v => v.toDouble(),
        String v => double.tryParse(v),
        _ => null,
      },
      reactions: (json['reactions'] as List<dynamic>?)
          ?.map((e) => ReactionDto.fromJson(e))
          .toList(),
    );
  }
  final int? id;
  final String? rating;
  final String? status;
  final AuthorDto? author;
  final String? sampleUrl;
  final int? sampleWidth;
  final int? sampleHeight;
  final String? previewUrl;
  final int? previewWidth;
  final int? previewHeight;
  final String? fileUrl;
  final int? width;
  final int? height;
  final int? fileSize;
  final String? fileType;
  final CreatedAtDto? createdAt;
  final bool? hasChildren;
  final bool? hasComments;
  final bool? hasNotes;
  final bool? isFavorited;
  // final dynamic userVote; // Change this to the actual type if known
  final String? md5;
  final int? parentId;
  final int? change;
  final int? favCount;
  final int? recommendedPosts;
  final int? recommendedScore;
  final int? voteCount;
  final int? totalScore;
  final int? commentCount;
  final String? source;
  final bool? inVisiblePool;
  final bool? isPremium;
  final bool? isRatingLocked;
  final bool? isNoteLocked;
  final bool? isStatusLocked;
  final bool? redirectToSignup;
  // final dynamic sequence; // Change this to the actual type if known
  final List<TagDto>? tags;
  final double? videoDuration;
  final List<ReactionDto>? reactions;

  @override
  String toString() => '$id: $fileUrl';
}

class ReactionDto {

  ReactionDto({
    this.id,
    this.userId,
    this.reaction,
  });

  factory ReactionDto.fromJson(Map<String, dynamic> json) {
    return ReactionDto(
      id: json['id'] as int?,
      userId: json['user_id'] as int?,
      reaction: json['reaction'] as String?,
    );
  }
  final int? id;
  final int? userId;
  final String? reaction;
}

class AuthorDto {

  AuthorDto({
    this.id,
    this.name,
    this.avatar,
    this.avatarRating,
  });

  factory AuthorDto.fromJson(Map<String, dynamic> json) {
    return AuthorDto(
      id: json['id'] as int?,
      name: json['name'] as String?,
      avatar: json['avatar'] as String?,
      avatarRating: json['avatar_rating'] as String?,
    );
  }
  final int? id;
  final String? name;
  final String? avatar;
  final String? avatarRating;
}

class CreatedAtDto {

  CreatedAtDto({
    this.jsonClass,
    this.s,
    this.n,
  });

  factory CreatedAtDto.fromJson(Map<String, dynamic> json) {
    return CreatedAtDto(
      jsonClass: json['json_class'] as String?,
      s: json['s'] as int?,
      n: json['n'] as int?,
    );
  }
  final String? jsonClass;
  final int? s;
  final int? n;
}
