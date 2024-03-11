// Dart imports:
import 'dart:convert';

// Package imports:
import 'package:equatable/equatable.dart';

// Project imports:
import 'package:boorusama/core/feats/posts/posts.dart';
import 'package:boorusama/foundation/image.dart';
import 'package:boorusama/foundation/path.dart';
import 'package:boorusama/foundation/video.dart';

class Bookmark extends Equatable with ImageInfoMixin, TagListCheckMixin {
  const Bookmark({
    required this.id,
    required this.booruId,
    required this.createdAt,
    required this.updatedAt,
    required this.thumbnailUrl,
    required this.sampleUrl,
    required this.originalUrl,
    required this.sourceUrl,
    required this.width,
    required this.height,
    required this.md5,
    required this.tags,
    required this.realSourceUrl,
  });

  final int id;
  final int booruId;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String thumbnailUrl;
  final String sampleUrl;
  final String originalUrl;
  final String sourceUrl;
  @override
  final double width;
  @override
  final double height;
  final String md5;
  @override
  final Set<String> tags;
  final String? realSourceUrl;

  bool get isVideo => isFormatVideo(extension(originalUrl));

  static Bookmark empty = Bookmark(
    id: -1,
    booruId: -10,
    createdAt: DateTime(1),
    updatedAt: DateTime(1),
    thumbnailUrl: '',
    sampleUrl: '',
    originalUrl: '',
    sourceUrl: '',
    width: -1,
    height: -1,
    md5: '',
    tags: const {},
    realSourceUrl: null,
  );

  @override
  List<Object?> get props => [
        id,
        booruId,
        createdAt,
        updatedAt,
        thumbnailUrl,
        sampleUrl,
        originalUrl,
        sourceUrl,
        width,
        height,
        md5,
        tags,
      ];

  Bookmark copyWith({
    int? id,
    int? booruId,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? thumbnailUrl,
    String? sampleUrl,
    String? originalUrl,
    String? sourceUrl,
    double? width,
    double? height,
    String? md5,
    Set<String>? tags,
  }) {
    return Bookmark(
      id: id ?? this.id,
      booruId: booruId ?? this.booruId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      thumbnailUrl: thumbnailUrl ?? this.thumbnailUrl,
      sampleUrl: sampleUrl ?? this.sampleUrl,
      originalUrl: originalUrl ?? this.originalUrl,
      sourceUrl: sourceUrl ?? this.sourceUrl,
      width: width ?? this.width,
      height: height ?? this.height,
      md5: md5 ?? this.md5,
      tags: tags ?? this.tags,
      realSourceUrl: realSourceUrl,
    );
  }

  factory Bookmark.fromJson(Map<String, dynamic> json) {
    return Bookmark(
      id: json['id'] as int,
      booruId: json['booruId'] as int,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
      thumbnailUrl: json['thumbnailUrl'] as String,
      sampleUrl: json['sampleUrl'] as String,
      originalUrl: json['originalUrl'] as String,
      sourceUrl: json['sourceUrl'] as String,
      width: (json['width'] as num).toDouble(),
      height: (json['height'] as num).toDouble(),
      md5: json['md5'] as String,
      tags: (json['tags'] as List<dynamic>).map((e) => e as String).toSet(),
      realSourceUrl: json['realSourceUrl'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'booruId': booruId,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'thumbnailUrl': thumbnailUrl,
      'sampleUrl': sampleUrl,
      'originalUrl': originalUrl,
      'sourceUrl': sourceUrl,
      'width': width,
      'height': height,
      'md5': md5,
      'tags': jsonEncode(tags.toList()),
    };
  }
}
