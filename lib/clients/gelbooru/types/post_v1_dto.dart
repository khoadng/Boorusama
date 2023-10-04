// Package imports:
import 'package:html/dom.dart';

class PostV1Dto {
  PostV1Dto({
    this.previewUrl,
    this.sampleUrl,
    this.fileUrl,
    this.id,
    this.rating,
    this.score,
    this.tags,
    this.md5,
  });

  factory PostV1Dto.fromHTML(Element html) {
    var linkElement = html.firstChild!;
    var imageElement = linkElement.firstChild!;

    final id = linkElement.attributes["id"]!.substring(1);
    final thumbUrl = imageElement.attributes["src"]!;
    final fileUrl = thumbUrl
        .replaceFirst('thumbs', 'img')
        .replaceFirst('thumbnails', 'images')
        .replaceFirst('thumbnail_', '');

    final tags = imageElement.attributes["title"];

    final md5 = thumbUrl.substring(
        thumbUrl.lastIndexOf('_') + 1, thumbUrl.lastIndexOf('.'));

    int? score;
    String? rating;

    final tagList = tags?.split(' ') ?? <String>[];

    for (final tag in tagList) {
      if (tag.startsWith('score:')) {
        score = int.tryParse(tag.replaceAll('score:', ''));
        break;
      }
    }

    for (final tag in tagList) {
      if (tag.startsWith('rating:')) {
        rating = tag.replaceAll('rating:', '');
        break;
      }
    }

    return PostV1Dto(
      id: int.tryParse(id),
      fileUrl: fileUrl,
      sampleUrl: fileUrl,
      previewUrl: thumbUrl,
      tags: tagList
          .where((e) => e.isNotEmpty)
          .where((e) => !e.startsWith('rating:'))
          .where((e) => !e.startsWith('score:'))
          .join(' '),
      md5: md5,
      rating: rating,
      score: score,
    );
  }

  final String? previewUrl;
  final String? sampleUrl;
  final String? fileUrl;
  final int? id;
  final String? rating;
  final int? score;
  final String? tags;
  final String? md5;

  @override
  String toString() => '$id: $fileUrl';
}
