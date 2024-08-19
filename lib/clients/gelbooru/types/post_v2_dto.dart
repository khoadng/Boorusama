// Package imports:
import 'package:path/path.dart' as path;

class PostV2Dto {

  PostV2Dto({
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

  factory PostV2Dto.fromJson(Map<String, dynamic> json, String baseUrl) {
    var previewUrl = '';
    var sampleUrl = '';
    var fileUrl = '';

    if (json['preview_url'] != null) {
      previewUrl = json['preview_url'];
    } else if (json['directory'] != null && json['image'] != null) {
      previewUrl =
          '$baseUrl/thumbnails/${json['directory']}/thumbnail_${json['image']}';
      // Change the extension to jpg
      previewUrl = previewUrl.replaceAll(
        path.extension(previewUrl),
        '.jpg',
      );
    } else {
      previewUrl = '';
    }

    if (json['file_url'] != null) {
      fileUrl = json['file_url'];
    } else if (json['directory'] != null && json['image'] != null) {
      fileUrl = '$baseUrl/images/${json['directory']}/${json['image']}';
    } else {
      fileUrl = '';
    }

    if (json['sample_url'] != null) {
      sampleUrl = json['sample_url'];
    } else if (json['directory'] != null && json['image'] != null) {
      if (json['sample'] != null && json['sample'] == true) {
        sampleUrl =
            '$baseUrl/samples/${json['directory']}/sample_${json['image']}';
        // Change the extension to jpg
        sampleUrl = sampleUrl.replaceAll(
          path.extension(sampleUrl),
          '.jpg',
        );
      } else {
        sampleUrl = fileUrl;
      }
    } else {
      sampleUrl = '';
    }

    return PostV2Dto(
      previewUrl: previewUrl,
      sampleUrl: sampleUrl,
      fileUrl: fileUrl,
      directory: json['directory']?.toString(),
      hash: json['hash'],
      width: json['width'],
      height: json['height'],
      id: json['id'],
      image: json['image'],
      change: json['change'],
      owner: json['owner'],
      parentId: json['parent_id'],
      rating: json['rating'],
      sample: _parseBool(json['sample']),
      sampleHeight: json['sample_height'],
      sampleWidth: json['sample_width'],
      score: json['score'],
      tags: json['tags'],
      source: json['source'],
      status: json['status'],
      hasNotes: _parseBool(json['has_notes']),
      commentCount: json['comment_count'],
    );
  }
  final String? previewUrl;
  final String? sampleUrl;
  final String? fileUrl;
  final String? directory;
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

  @override
  String toString() => '$id: $fileUrl';
}

bool? _parseBool(dynamic value) => switch (value) {
      int i => i > 0 ? true : false,
      bool b => b,
      String s => bool.tryParse(s),
      _ => null,
    };
