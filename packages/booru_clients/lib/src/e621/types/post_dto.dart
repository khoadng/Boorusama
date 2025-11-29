class PostDto {
  PostDto({
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
    this.uploaderName,
    this.description,
    this.commentCount,
    this.isFavorited,
    this.hasNotes,
    this.duration,
  });

  factory PostDto.fromJson(Map<String, dynamic> json) {
    return PostDto(
      id: json['id'],
      createdAt: json['created_at'],
      updatedAt: json['updated_at'],
      file: switch (json['file']) {
        final Map<String, dynamic> m => E621FileDto.fromJson(m),
        _ => E621FileDto(
          width: json['image_width'],
          height: json['image_height'],
          ext: json['file_ext'],
          size: json['file_size'],
          md5: json['md5'],
          url: json['file_url'],
        ),
      },
      preview: switch (json['preview']) {
        final Map<String, dynamic> m => E621PreviewDto.fromJson(m),
        _ => E621PreviewDto(
          width: json['preview_width'],
          height: json['preview_height'],
          url: json['preview_file_url'],
          alt: null,
        ),
      },
      sample: switch (json['sample']) {
        final Map<String, dynamic> m => E621SampleDto.fromJson(m),
        _ => E621SampleDto(
          has: json['has_sample'],
          width: json['sample_width'],
          height: json['sample_height'],
          url: json['sample_url'],
          alt: null,
          alternates: null,
        ),
      },
      score: switch (json['score']) {
        final Map<String, dynamic> m => E621ScoreDto.fromJson(m),
        _ => E621ScoreDto(
          up: json['up_score'],
          down: json['down_score'],
          total: json['score'],
        ),
      },
      tags: switch (json['tags']) {
        final Map<String, dynamic> m => Map<String, List<dynamic>>.from(m),
        _ => _parseTagString(json['tag_string']),
      },
      lockedTags: switch (json['locked_tags']) {
        final List l => List<String>.from(l),
        final String s when s.isNotEmpty => s.split(' '),
        _ => null,
      },
      changeSeq: json['change_seq'],
      flags: switch (json['flags']) {
        final Map<String, dynamic> m => E621FlagsDto.fromJson(m),
        _ => E621FlagsDto(
          pending: json['is_pending'],
          flagged: json['is_flagged'],
          noteLocked: json['is_note_locked'],
          statusLocked: json['is_status_locked'],
          ratingLocked: json['is_rating_locked'],
          deleted: json['is_deleted'],
        ),
      },
      rating: json['rating'],
      favCount: json['fav_count'],
      sources: switch (json['sources']) {
        final List l => List<String>.from(l),
        final String s when s.isNotEmpty => s.split('\n'),
        _ => null,
      },
      pools: switch (json['pools']) {
        final List l => List<int>.from(l),
        _ => switch (json['pool_ids']) {
          final List p => List<int>.from(p),
          _ => null,
        },
      },
      relationships: switch (json['relationships']) {
        final Map<String, dynamic> m => E621RelationshipsDto.fromJson(m),
        _ => E621RelationshipsDto(
          parentId: json['parent_id'],
          hasChildren: json['has_children'],
          hasActiveChildren: json['has_active_children'],
          children: switch (json['children_ids']) {
            final String s when s.isNotEmpty =>
              s
                  .split(' ')
                  .map((e) => int.tryParse(e))
                  .whereType<int>()
                  .toList(),
            final List l => l.cast<int>(),
            _ => null,
          },
        ),
      },
      approverId: json['approver_id'],
      uploaderId: json['uploader_id'],
      uploaderName: json['uploader_name'] ?? json['uploader'],
      description: json['description'],
      commentCount: json['comment_count'],
      isFavorited: json['is_favorited'],
      hasNotes: json['has_notes'],
      duration: switch (json['duration']) {
        final num n => n.toDouble(),
        final String s => double.tryParse(s),
        _ => null,
      },
    );
  }

  static Map<String, List<dynamic>>? _parseTagString(dynamic tagString) {
    return switch (tagString) {
      final String s when s.isNotEmpty => {'general': s.split(' ')},
      _ => null,
    };
  }

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
  final String? uploaderName;
  final String? description;
  final int? commentCount;
  final bool? isFavorited;
  final bool? hasNotes;
  final double? duration;

  @override
  String toString() => '$id';
}

class E621FileDto {
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
  final int? width;
  final int? height;
  final String? ext;
  final int? size;
  final String? md5;
  final String? url;
}

class E621PreviewDto {
  E621PreviewDto({
    this.width,
    this.height,
    this.url,
    this.alt,
  });

  factory E621PreviewDto.fromJson(Map<String, dynamic> json) {
    return E621PreviewDto(
      width: json['width'],
      height: json['height'],
      url: json['url'],
      alt: json['alt'],
    );
  }
  final int? width;
  final int? height;
  final String? url;
  final String? alt;
}

class E621SampleDto {
  E621SampleDto({
    this.has,
    this.height,
    this.width,
    this.url,
    this.alt,
    this.alternates,
  });

  factory E621SampleDto.fromJson(Map<String, dynamic> json) {
    return E621SampleDto(
      has: json['has'],
      height: json['height'],
      width: json['width'],
      url: json['url'],
      alt: json['alt'],
      alternates: switch (json['alternates']) {
        Map<String, dynamic> m => E621AlternatesDto.fromJson(m),
        _ => null,
      },
    );
  }
  final bool? has;
  final int? height;
  final int? width;
  final String? url;
  final String? alt;
  final E621AlternatesDto? alternates;
}

class E621AlternatesDto {
  E621AlternatesDto({
    this.has,
    this.manifest,
    this.original,
    this.variants,
    this.samples,
  });

  factory E621AlternatesDto.fromJson(Map<String, dynamic> json) {
    return E621AlternatesDto(
      has: json['has'],
      manifest: json['manifest'],
      original: switch (json['original']) {
        Map<String, dynamic> m => E621VideoInfoDto.fromJson(m),
        _ => null,
      },
      variants: switch (json['variants']) {
        Map<String, dynamic> m => m.map(
          (key, value) => MapEntry(key, E621VideoInfoDto.fromJson(value)),
        ),
        _ => {},
      },
      samples: switch (json['samples']) {
        Map<String, dynamic> m => m.map(
          (key, value) => MapEntry(key, E621VideoInfoDto.fromJson(value)),
        ),
        _ => {},
      },
    );
  }
  final bool? has;
  final int? manifest;
  final E621VideoInfoDto? original;
  final Map<String, E621VideoInfoDto>? variants;
  final Map<String, E621VideoInfoDto>? samples;
}

class E621VideoInfoDto {
  E621VideoInfoDto({
    this.fps,
    this.codec,
    this.size,
    this.width,
    this.height,
    this.url,
  });

  factory E621VideoInfoDto.fromJson(Map<String, dynamic> json) {
    return E621VideoInfoDto(
      fps: switch (json['fps']) {
        num n => n.toDouble(),
        _ => null,
      },
      codec: json['codec'],
      size: json['size'],
      width: json['width'],
      height: json['height'],
      url: json['url'],
    );
  }
  final double? fps;
  final String? codec;
  final int? size;
  final int? width;
  final int? height;
  final String? url;
}

class E621ScoreDto {
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
  final int? up;
  final int? down;
  final int? total;
}

class E621FlagsDto {
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
  final bool? pending;
  final bool? flagged;
  final bool? noteLocked;
  final bool? statusLocked;
  final bool? ratingLocked;
  final bool? deleted;
}

class E621RelationshipsDto {
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
  final int? parentId;
  final bool? hasChildren;
  final bool? hasActiveChildren;
  final List<dynamic>? children;
}
