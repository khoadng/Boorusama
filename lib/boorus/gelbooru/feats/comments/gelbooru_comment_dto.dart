// Package imports:
import 'package:xml/xml.dart' as xml;

class GelbooruCommentDto {
  final String? createdAt;
  final String? postId;
  final String? body;
  final String? creator;
  final String? id;
  final String? creatorId;

  GelbooruCommentDto({
    this.createdAt,
    this.postId,
    this.body,
    this.creator,
    this.id,
    this.creatorId,
  });

  factory GelbooruCommentDto.fromXml(xml.XmlElement element) {
    return GelbooruCommentDto(
      createdAt: element.getAttribute('created_at'),
      postId: element.getAttribute('post_id'),
      body: element.getAttribute('body'),
      creator: element.getAttribute('creator'),
      id: element.getAttribute('id'),
      creatorId: element.getAttribute('creator_id'),
    );
  }
}
