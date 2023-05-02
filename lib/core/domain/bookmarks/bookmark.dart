// Package imports:
import 'package:equatable/equatable.dart';
import 'package:path/path.dart';

// Project imports:
import 'package:boorusama/core/domain/image.dart';

class Bookmark extends Equatable with ImageInfoMixin {
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

  bool get isVideo => ['.mp4', '.webm'].contains(extension(sampleUrl));

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
  });

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
    );
  }
}
