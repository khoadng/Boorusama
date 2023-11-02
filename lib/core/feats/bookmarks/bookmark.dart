// Package imports:

// Package imports:
import 'package:equatable/equatable.dart';

// Project imports:
import 'package:boorusama/core/feats/posts/posts.dart';
import 'package:boorusama/foundation/image.dart';
import 'package:boorusama/foundation/path.dart';

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
  final List<String> tags;

  bool get isVideo => ['.mp4', '.webm'].contains(extension(sampleUrl));

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
    tags: const [],
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
    List<String>? tags,
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
      'tags': tags,
    };
  }
}
