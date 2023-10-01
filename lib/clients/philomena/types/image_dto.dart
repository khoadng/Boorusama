class ImageDto {
  final int? tagCount;
  final dynamic deletionReason;
  final List<String>? sourceUrls;
  final String? mimeType;
  final int? downvotes;
  final IntensitiesDto? intensities;
  final double? duration;
  final dynamic duplicateOf;
  final int? id;
  final String? name;
  final RepresentationsDto? representations;
  final DateTime? createdAt;
  final String? origSha512Hash;
  final int? commentCount;
  final double? wilsonScore;
  final DateTime? firstSeenAt;
  final List<int>? tagIds;
  final bool? thumbnailsGenerated;
  final String? description;
  final String? viewUrl;
  final DateTime? updatedAt;
  final String? uploader;
  final int? width;
  final int? uploaderId;
  final List<String>? tags;
  final int? height;
  final String? sha512Hash;
  final int? size;
  final int? score;
  final int? faves;
  final bool? animated;
  final bool? spoilered;
  final String? sourceUrl;
  final bool? hiddenFromUsers;
  final double? aspectRatio;
  final int? upvotes;
  final String? format;
  final bool? processed;

  ImageDto({
    this.tagCount,
    this.deletionReason,
    this.sourceUrls,
    this.mimeType,
    this.downvotes,
    this.intensities,
    this.duration,
    this.duplicateOf,
    this.id,
    this.name,
    this.representations,
    this.createdAt,
    this.origSha512Hash,
    this.commentCount,
    this.wilsonScore,
    this.firstSeenAt,
    this.tagIds,
    this.thumbnailsGenerated,
    this.description,
    this.viewUrl,
    this.updatedAt,
    this.uploader,
    this.width,
    this.uploaderId,
    this.tags,
    this.height,
    this.sha512Hash,
    this.size,
    this.score,
    this.faves,
    this.animated,
    this.spoilered,
    this.sourceUrl,
    this.hiddenFromUsers,
    this.aspectRatio,
    this.upvotes,
    this.format,
    this.processed,
  });

  factory ImageDto.fromJson(Map<String, dynamic> json) {
    try {
      return ImageDto(
        tagCount: json['tag_count'],
        deletionReason: json['deletion_reason'],
        sourceUrls:
            (json['source_urls'] as List?)?.map((e) => e as String).toList(),
        mimeType: json['mime_type'],
        downvotes: json['downvotes'],
        intensities: IntensitiesDto.fromJson(json['intensities']),
        duration: json['duration'],
        duplicateOf: json['duplicate_of'],
        id: json['id'],
        name: json['name'],
        representations: RepresentationsDto.fromJson(json['representations']),
        createdAt: json['created_at'] != null
            ? DateTime.tryParse(json['created_at'])
            : null,
        origSha512Hash: json['orig_sha512_hash'],
        commentCount: json['comment_count'],
        wilsonScore: switch (json['wilson_score']) {
          int n => n.toDouble(),
          double n => n,
          _ => null,
        },
        firstSeenAt: json['first_seen_at'] != null
            ? DateTime.tryParse(json['first_seen_at'])
            : null,
        tagIds: (json['tag_ids'] as List?)?.map((e) => e as int).toList(),
        thumbnailsGenerated: json['thumbnails_generated'],
        description: json['description'],
        viewUrl: json['view_url'],
        updatedAt: json['updated_at'] != null
            ? DateTime.tryParse(json['updated_at'])
            : null,
        uploader: json['uploader'],
        width: json['width'],
        uploaderId: json['uploader_id'],
        tags: (json['tags'] as List?)?.map((e) => e as String).toList(),
        height: json['height'],
        sha512Hash: json['sha512_hash'],
        size: json['size'],
        score: json['score'],
        faves: json['faves'],
        animated: json['animated'],
        spoilered: json['spoilered'],
        sourceUrl: json['source_url'],
        hiddenFromUsers: json['hidden_from_users'],
        aspectRatio: json['aspect_ratio'],
        upvotes: json['upvotes'],
        format: json['format'],
        processed: json['processed'],
      );
    } catch (e) {
      // Silently ignore error and return empty object
      return ImageDto();
    }
  }

  @override
  String toString() => '$id: $name';
}

class RepresentationsDto {
  final String? full;
  final String? large;
  final String? medium;
  final String? small;
  final String? tall;
  final String? thumb;
  final String? thumbSmall;
  final String? thumbTiny;

  RepresentationsDto({
    this.full,
    this.large,
    this.medium,
    this.small,
    this.tall,
    this.thumb,
    this.thumbSmall,
    this.thumbTiny,
  });

  factory RepresentationsDto.fromJson(Map<String, dynamic> json) {
    return RepresentationsDto(
      full: json['full'],
      large: json['large'],
      medium: json['medium'],
      small: json['small'],
      tall: json['tall'],
      thumb: json['thumb'],
      thumbSmall: json['thumb_small'],
      thumbTiny: json['thumb_tiny'],
    );
  }
}

class IntensitiesDto {
  final double? ne;
  final double? nw;
  final double? se;
  final double? sw;

  IntensitiesDto({
    this.ne,
    this.nw,
    this.se,
    this.sw,
  });

  factory IntensitiesDto.fromJson(Map<String, dynamic> json) {
    return IntensitiesDto(
      ne: json['ne'],
      nw: json['nw'],
      se: json['se'],
      sw: json['sw'],
    );
  }
}
