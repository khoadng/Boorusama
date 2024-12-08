class CreatorDto {
  CreatorDto({
    required this.id,
    required this.name,
    required this.level,
    required this.inviterId,
    required this.createdAt,
    required this.postUpdateCount,
    required this.noteUpdateCount,
    required this.postUploadCount,
    required this.isBanned,
    required this.canApprovePosts,
    required this.canUploadFree,
    required this.levelString,
  });

  factory CreatorDto.fromJson(Map<String, dynamic> json) => CreatorDto(
        id: json['id'],
        name: json['name'],
        level: json['level'],
        inviterId: json['inviter_id'],
        createdAt: json['created_at'] == null
            ? null
            : DateTime.parse(json['created_at']),
        postUpdateCount: json['post_update_count'],
        noteUpdateCount: json['note_update_count'],
        postUploadCount: json['post_upload_count'],
        isBanned: json['is_banned'],
        canApprovePosts: json['can_approve_posts'],
        canUploadFree: json['can_upload_free'],
        levelString: json['level_string'],
      );

  final int? id;
  final String? name;
  final int? level;
  final int? inviterId;
  final DateTime? createdAt;
  final int? postUpdateCount;
  final int? noteUpdateCount;
  final int? postUploadCount;
  final bool? isBanned;
  final bool? canApprovePosts;
  final bool? canUploadFree;
  final String? levelString;

  @override
  String toString() => '$name ($id)';
}
