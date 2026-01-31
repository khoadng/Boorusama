// Project imports:
import 'types.dart';

class CommentDto {
  CommentDto({
    this.id,
    this.user,
    this.postId,
    this.version,
    this.text,
    this.creationTime,
    this.lastEditTime,
    this.score,
    this.ownScore,
  });

  factory CommentDto.fromJson(Map<String, dynamic> json) {
    return CommentDto(
      id: json['id'] as int?,
      user: json['user'] != null
          ? UserDto.fromJson(json['user'] as Map<String, dynamic>)
          : null,
      postId: json['postId'] as int?,
      version: SzurubooruVersion.maybeFrom(json['version']),
      text: json['text'] as String?,
      creationTime: json['creationTime'] as String?,
      lastEditTime: json['lastEditTime'] as String?,
      score: json['score'] as int?,
      ownScore: json['ownScore'] as int?,
    );
  }
  final int? id;
  final UserDto? user;
  final int? postId;
  final SzurubooruVersion? version;
  final String? text;
  final String? creationTime;
  final String? lastEditTime;
  final int? score;
  final int? ownScore;
}
