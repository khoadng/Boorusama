class E621PostDto {
  final int? id;
  final String? createdAt;
  final String? updatedAt;
  final E621FileDto? file;
  final E621PreviewDto? preview;
  final E621SampleDto? sample;
  final E621ScoreDto? score;
  final Map<String, List<dynamic>>? tags;
  final List<String>? lockedTags;
  final int? changeSeq;
  final E621FlagsDto? flags;
  final String? rating;
  final int? favCount;
  final List<String>? sources;
  final List<int>? pools;
  final E621RelationshipsDto? relationships;
  final int? approverId;
  final int? uploaderId;
  final String? description;
  final int? commentCount;
  final bool? isFavorited;
  final bool? hasNotes;
  final double? duration;

  E621PostDto({
    this.id,
    this.createdAt,
    this.updatedAt,
    this.file,
    this.preview,
    this.sample,
    this.score,
    this.tags,
    this.lockedTags,
    this.changeSeq,
    this.flags,
    this.rating,
    this.favCount,
    this.sources,
    this.pools,
    this.relationships,
    this.approverId,
    this.uploaderId,
    this.description,
    this.commentCount,
    this.isFavorited,
    this.hasNotes,
    this.duration,
  });

  factory E621PostDto.fromJson(Map<String, dynamic> json) {
    return E621PostDto(
      id: json['id'],
      createdAt: json['created_at'],
      updatedAt: json['updated_at'],
      file: E621FileDto.fromJson(json['file']),
      preview: E621PreviewDto.fromJson(json['preview']),
      sample: E621SampleDto.fromJson(json['sample']),
      score: E621ScoreDto.fromJson(json['score']),
      tags: Map<String, List<dynamic>>.from(json['tags']),
      lockedTags: List<String>.from(json['locked_tags']),
      changeSeq: json['change_seq'],
      flags: E621FlagsDto.fromJson(json['flags']),
      rating: json['rating'],
      favCount: json['fav_count'],
      sources: List<String>.from(json['sources']),
      pools: List<int>.from(json['pools']),
      relationships: E621RelationshipsDto.fromJson(json['relationships']),
      approverId: json['approver_id'],
      uploaderId: json['uploader_id'],
      description: json['description'],
      commentCount: json['comment_count'],
      isFavorited: json['is_favorited'],
      hasNotes: json['has_notes'],
      duration: json['duration'],
    );
  }
}

class E621FileDto {
  final int? width;
  final int? height;
  final String? ext;
  final int? size;
  final String? md5;
  final String? url;

  E621FileDto({
    this.width,
    this.height,
    this.ext,
    this.size,
    this.md5,
    this.url,
  });

  factory E621FileDto.fromJson(Map<String, dynamic> json) {
    return E621FileDto(
      width: json['width'],
      height: json['height'],
      ext: json['ext'],
      size: json['size'],
      md5: json['md5'],
      url: json['url'],
    );
  }
}

class E621PreviewDto {
  final int? width;
  final int? height;
  final String? url;

  E621PreviewDto({
    this.width,
    this.height,
    this.url,
  });

  factory E621PreviewDto.fromJson(Map<String, dynamic> json) {
    return E621PreviewDto(
      width: json['width'],
      height: json['height'],
      url: json['url'],
    );
  }
}

class E621SampleDto {
  final bool? has;
  final int? height;
  final int? width;
  final String? url;
  final Map<String, E621SampleAlternatesDto>? alternates;

  E621SampleDto({
    this.has,
    this.height,
    this.width,
    this.url,
    this.alternates,
  });

  factory E621SampleDto.fromJson(Map<String, dynamic> json) {
    return E621SampleDto(
      has: json['has'],
      height: json['height'],
      width: json['width'],
      url: json['url'],
      alternates: (json['alternates'] as Map<String, dynamic>).map(
        (key, value) => MapEntry(key, E621SampleAlternatesDto.fromJson(value)),
      ),
    );
  }
}

class E621SampleAlternatesDto {
  final String? type;
  final int? height;
  final int? width;
  final List<String>? urls;

  E621SampleAlternatesDto({
    this.type,
    this.height,
    this.width,
    this.urls,
  });

  factory E621SampleAlternatesDto.fromJson(Map<String, dynamic> json) {
    return E621SampleAlternatesDto(
      type: json['type'],
      height: json['height'],
      width: json['width'],
      urls: List<String>.from(json['urls'].where((x) => x != null)),
    );
  }
}

class E621ScoreDto {
  final int? up;
  final int? down;
  final int? total;

  E621ScoreDto({
    this.up,
    this.down,
    this.total,
  });

  factory E621ScoreDto.fromJson(Map<String, dynamic> json) {
    return E621ScoreDto(
      up: json['up'],
      down: json['down'],
      total: json['total'],
    );
  }
}

class E621FlagsDto {
  final bool? pending;
  final bool? flagged;
  final bool? noteLocked;
  final bool? statusLocked;
  final bool? ratingLocked;
  final bool? deleted;

  E621FlagsDto({
    this.pending,
    this.flagged,
    this.noteLocked,
    this.statusLocked,
    this.ratingLocked,
    this.deleted,
  });

  factory E621FlagsDto.fromJson(Map<String, dynamic> json) {
    return E621FlagsDto(
      pending: json['pending'],
      flagged: json['flagged'],
      noteLocked: json['note_locked'],
      statusLocked: json['status_locked'],
      ratingLocked: json['rating_locked'],
      deleted: json['deleted'],
    );
  }
}

class E621RelationshipsDto {
  final int? parentId;
  final bool? hasChildren;
  final bool? hasActiveChildren;
  final List<dynamic>? children;

  E621RelationshipsDto({
    this.parentId,
    this.hasChildren,
    this.hasActiveChildren,
    this.children,
  });

  factory E621RelationshipsDto.fromJson(Map<String, dynamic> json) {
    return E621RelationshipsDto(
      parentId: json['parent_id'],
      hasChildren: json['has_children'],
      hasActiveChildren: json['has_active_children'],
      children: json['children'],
    );
  }
}
