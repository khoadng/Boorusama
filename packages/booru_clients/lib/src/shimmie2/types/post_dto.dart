// Package imports:
import 'package:xml/xml.dart';

class PostDto {

  PostDto({
    this.id,
    this.md5,
    this.fileName,
    this.fileUrl,
    this.height,
    this.width,
    this.previewUrl,
    this.previewHeight,
    this.previewWidth,
    this.rating,
    this.date,
    this.tags,
    this.source,
    this.score,
    this.author,
  });

  factory PostDto.fromXml(
    XmlElement xml, {
    String? baseUrl,
  }) {
    final previewUrl = xml.getAttribute('preview_url');

    return PostDto(
      id: int.tryParse(xml.getAttribute('id') ?? ''),
      md5: xml.getAttribute('md5'),
      fileName: xml.getAttribute('file_name'),
      fileUrl: xml.getAttribute('file_url'),
      height: int.tryParse(xml.getAttribute('height') ?? ''),
      width: int.tryParse(xml.getAttribute('width') ?? ''),
      previewUrl: previewUrl?.startsWith('http') == true
          ? previewUrl
          : baseUrl != null
              ? '$baseUrl$previewUrl'
              : null,
      previewHeight: int.tryParse(xml.getAttribute('preview_height') ?? ''),
      previewWidth: int.tryParse(xml.getAttribute('preview_width') ?? ''),
      rating: xml.getAttribute('rating'),
      date: DateTime.tryParse(xml.getAttribute('date') ?? ''),
      tags: xml.getAttribute('tags')?.split(' '),
      source: xml.getAttribute('source'),
      score: int.tryParse(xml.getAttribute('score') ?? ''),
      author: xml.getAttribute('author'),
    );
  }
  final int? id;
  final String? md5;
  final String? fileName;
  final String? fileUrl;
  final int? height;
  final int? width;
  final String? previewUrl;
  final int? previewHeight;
  final int? previewWidth;
  final String? rating;
  final DateTime? date;
  final List<String>? tags;
  final String? source;
  final int? score;
  final String? author;

  @override
  String toString() => '$id: $fileUrl';
}
