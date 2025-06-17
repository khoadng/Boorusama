import 'post_summary_dto.dart';

class PostDto {
  const PostDto({
    this.id,
    this.sha256,
    this.hash,
    this.md5,
    this.extension,
    this.size,
    this.width,
    this.height,
    this.duration,
    this.numFrames,
    this.hasAudio,
    this.rating,
    this.mime,
    this.posted,
    this.tags,
    this.sources,
    this.relations,
    this.notes,
  });

  factory PostDto.fromJson(Map<String, dynamic> json) {
    return PostDto(
      id: json['id'] as int?,
      sha256: json['sha256'] as String?,
      hash: json['hash'] as String?, // deprecated
      md5: json['md5'] as String?,
      extension: json['extension'] as String?,
      size: json['size'] as int?,
      width: json['width'] as int?,
      height: json['height'] as int?,
      duration: json['duration'] as int?,
      numFrames: json['nunFrames'] as int?, // Note: API has typo "nunFrames"
      hasAudio: json['hasAudio'] as bool?,
      rating: (json['rating'] as num?)?.toDouble(),
      mime: json['mime'] as int?,
      posted: json['posted'] as String?,
      tags: json['tags'] as Map<String, dynamic>?,
      sources:
          (json['sources'] as List<dynamic>?)?.map((e) => e as String).toList(),
      relations: (json['relations'] as List<dynamic>?)
          ?.map((e) => PostRelationDto.fromJson(e as Map<String, dynamic>))
          .toList(),
      notes: (json['notes'] as List<dynamic>?)
          ?.map((e) => PostNoteDto.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  final int? id;
  final String? sha256;
  final String? hash; // deprecated
  final String? md5;
  final String? extension;
  final int? size;
  final int? width;
  final int? height;
  final int? duration;
  final int? numFrames;
  final bool? hasAudio;
  final double? rating;
  final int? mime;
  final String? posted;
  final Map<String, dynamic>? tags;
  final List<String>? sources;
  final List<PostRelationDto>? relations;
  final List<PostNoteDto>? notes;

  @override
  String toString() => '$id: ${sha256 ?? hash}';
}

class PostRelationDto extends PostSummaryDto {
  const PostRelationDto({
    super.id,
    super.sha256,
    super.hash,
    super.md5,
    super.blurhash,
    super.width,
    super.height,
    super.extension,
    super.mime,
    super.posted,
    this.kind,
  });

  factory PostRelationDto.fromJson(Map<String, dynamic> json) {
    return PostRelationDto(
      id: json['id'] as int?,
      sha256: json['sha256'] as String?,
      hash: json['hash'] as String?,
      md5: json['md5'] as String?,
      blurhash: json['blurhash'] as String?,
      width: json['width'] as int?,
      height: json['height'] as int?,
      extension: json['extension'] as String?,
      mime: json['mime'] as int?,
      posted: json['posted'] as String?,
      kind: json['kind'] as String?,
    );
  }

  final String? kind; // "DUPLICATE", "DUPLICATE_BEST", "ALTERNATE"
}

class PostNoteDto {
  const PostNoteDto({
    this.label,
    this.note,
    this.rect,
  });

  factory PostNoteDto.fromJson(Map<String, dynamic> json) {
    return PostNoteDto(
      label: json['label'] as String?,
      note: json['note'] as String?,
      rect: json['rect'] != null
          ? PostNoteRectDto.fromJson(json['rect'] as Map<String, dynamic>)
          : null,
    );
  }

  final String? label;
  final String? note;
  final PostNoteRectDto? rect;
}

class PostNoteRectDto {
  const PostNoteRectDto({
    this.top,
    this.left,
    this.width,
    this.height,
  });

  factory PostNoteRectDto.fromJson(Map<String, dynamic> json) {
    return PostNoteRectDto(
      top: (json['top'] as num?)?.toDouble(),
      left: (json['left'] as num?)?.toDouble(),
      width: (json['width'] as num?)?.toDouble(),
      height: (json['height'] as num?)?.toDouble(),
    );
  }

  final double? top;
  final double? left;
  final double? width;
  final double? height;
}
