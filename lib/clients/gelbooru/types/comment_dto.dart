// Package imports:
import 'package:xml/xml.dart' as xml;

class CommentDto {
  final String? createdAt;
  final String? postId;
  final String? body;
  final String? creator;
  final String? id;
  final String? creatorId;

  CommentDto({
    this.createdAt,
    this.postId,
    this.body,
    this.creator,
    this.id,
    this.creatorId,
  });

  factory CommentDto.fromXml(xml.XmlElement element) {
    return CommentDto(
      createdAt: element.getAttribute('created_at'),
      postId: element.getAttribute('post_id'),
      body: element.getAttribute('body'),
      creator: element.getAttribute('creator'),
      id: element.getAttribute('id'),
      creatorId: element.getAttribute('creator_id'),
    );
  }

  @override
  String toString() => body ?? '';
}
