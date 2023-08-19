// Project imports:
import 'package:boorusama/utils/utils.dart';

class Rule34xxxPostDto {
  final String? previewUrl;
  final String? sampleUrl;
  final String? fileUrl;
  final int? directory;
  final String? hash;
  final int? width;
  final int? height;
  final int? id;
  final String? image;
  final int? change;
  final String? owner;
  final int? parentId;
  final String? rating;
  final bool? sample;
  final int? sampleHeight;
  final int? sampleWidth;
  final int? score;
  final String? tags;
  final String? source;
  final String? status;
  final bool? hasNotes;
  final int? commentCount;

  Rule34xxxPostDto({
    this.previewUrl,
    this.sampleUrl,
    this.fileUrl,
    this.directory,
    this.hash,
    this.width,
    this.height,
    this.id,
    this.image,
    this.change,
    this.owner,
    this.parentId,
    this.rating,
    this.sample,
    this.sampleHeight,
    this.sampleWidth,
    this.score,
    this.tags,
    this.source,
    this.status,
    this.hasNotes,
    this.commentCount,
  });

  factory Rule34xxxPostDto.fromJson(Map<String, dynamic> json) {
    json['sample'] = 1;
    return Rule34xxxPostDto(
      previewUrl: json['preview_url'],
      sampleUrl: json['sample_url'],
      fileUrl: json['file_url'],
      directory: json['directory'],
      hash: json['hash'],
      width: json['width'],
      height: json['height'],
      id: json['id'],
      image: json['image'],
      change: json['change'],
      owner: json['owner'],
      parentId: json['parent_id'],
      rating: json['rating'],
      // Not necessary, but it's here to err on the side of caution.
      sample: json['sample'] != null
          ? castOrFallback<bool>(json['sample'], false)
          : null,
      sampleHeight: json['sample_height'],
      sampleWidth: json['sample_width'],
      score: json['score'],
      tags: json['tags'],
      source: json['source'],
      status: json['status'],
      hasNotes: json['has_notes'],
      commentCount: json['comment_count'],
    );
  }
}
