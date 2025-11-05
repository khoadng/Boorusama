class CommentDto {
  CommentDto({
    this.id,
    this.comment,
    this.posted,
    this.ownerName,
    this.ownerId,
  });

  factory CommentDto.fromGraphQL(Map<String, dynamic> json) {
    final owner = switch (json['owner']) {
      final Map<String, dynamic> o => o,
      _ => null,
    };

    return CommentDto(
      id: switch (json['comment_id']) {
        final num n => n.toInt(),
        _ => null,
      },
      comment: switch (json['comment']) {
        final String s => s,
        _ => null,
      },
      posted: switch (json['posted']) {
        final String s => DateTime.tryParse(s),
        _ => null,
      },
      ownerName: switch (owner?['name']) {
        final String s => s,
        _ => null,
      },
      ownerId: switch (owner?['id']) {
        final num n => n.toInt(),
        _ => null,
      },
    );
  }

  final int? id;
  final String? comment;
  final DateTime? posted;
  final String? ownerName;
  final int? ownerId;
}
