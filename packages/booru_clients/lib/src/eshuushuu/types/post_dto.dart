class PostDto {
  PostDto({
    this.imageId,
    this.filename,
    this.ext,
    this.originalFilename,
    this.md5Hash,
    this.filesize,
    this.width,
    this.height,
    this.caption,
    this.miscmeta,
    this.status,
    this.rating,
    this.userId,
    this.username,
    this.userAvatarUrl,
    this.dateAdded,
    this.locked,
    this.posts,
    this.favorites,
    this.bayesianRating,
    this.numRatings,
    this.medium,
    this.large,
    this.replacementId,
    this.isFavorited,
    this.userRating,
    this.prevImageId,
    this.nextImageId,
    this.url,
    this.thumbnailUrl,
    this.mediumUrl,
    this.largeUrl,
    this.tags,
  });

  final int? imageId;
  final String? filename;
  final String? ext;
  final String? originalFilename;
  final String? md5Hash;
  final int? filesize;
  final int? width;
  final int? height;
  final String? caption;
  final String? miscmeta;
  final int? status;
  final double? rating;
  final int? userId;
  final String? username;
  final String? userAvatarUrl;
  final DateTime? dateAdded;
  final int? locked;
  final int? posts;
  final int? favorites;
  final double? bayesianRating;
  final int? numRatings;
  final int? medium;
  final int? large;
  final int? replacementId;
  final bool? isFavorited;
  final double? userRating;
  final int? prevImageId;
  final int? nextImageId;
  final String? url;
  final String? thumbnailUrl;
  final String? mediumUrl;
  final String? largeUrl;
  final List<PostTagDto>? tags;

  factory PostDto.fromJson(Map<String, dynamic> json) {
    final user = json['user'] as Map<String, dynamic>?;
    final tagsList = json['tags'] as List?;

    return PostDto(
      imageId: json['image_id'] as int?,
      filename: json['filename'] as String?,
      ext: json['ext'] as String?,
      originalFilename: json['original_filename'] as String?,
      md5Hash: json['md5_hash'] as String?,
      filesize: json['filesize'] as int?,
      width: json['width'] as int?,
      height: json['height'] as int?,
      caption: json['caption'] as String?,
      miscmeta: json['miscmeta'] as String?,
      status: json['status'] as int?,
      rating: (json['rating'] as num?)?.toDouble(),
      userId: user?['user_id'] as int? ?? json['user_id'] as int?,
      username: user?['username'] as String?,
      userAvatarUrl: user?['avatar_url'] as String?,
      dateAdded: _parseDate(json['date_added'] as String?),
      locked: json['locked'] as int?,
      posts: json['posts'] as int?,
      favorites: json['favorites'] as int?,
      bayesianRating: (json['bayesian_rating'] as num?)?.toDouble(),
      numRatings: json['num_ratings'] as int?,
      medium: json['medium'] as int?,
      large: json['large'] as int?,
      replacementId: json['replacement_id'] as int?,
      isFavorited: json['is_favorited'] as bool?,
      userRating: (json['user_rating'] as num?)?.toDouble(),
      prevImageId: json['prev_image_id'] as int?,
      nextImageId: json['next_image_id'] as int?,
      url: json['url'] as String?,
      thumbnailUrl: json['thumbnail_url'] as String?,
      mediumUrl: json['medium_url'] as String?,
      largeUrl: json['large_url'] as String?,
      tags: tagsList
          ?.whereType<Map<String, dynamic>>()
          .map(PostTagDto.fromJson)
          .toList(),
    );
  }
}

class PostTagDto {
  PostTagDto({
    this.tagId,
    this.title,
    this.type,
    this.typeName,
  });

  final int? tagId;
  final String? title;
  final int? type;
  final String? typeName;

  factory PostTagDto.fromJson(Map<String, dynamic> json) {
    return PostTagDto(
      tagId: json['tag_id'] as int?,
      title: json['title'] as String?,
      type: json['type'] as int?,
      typeName: json['type_name'] as String?,
    );
  }
}

DateTime? _parseDate(String? dateString) {
  if (dateString == null) return null;
  return DateTime.tryParse(dateString);
}
