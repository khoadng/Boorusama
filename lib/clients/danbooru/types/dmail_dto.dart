class DmailDto {
  final int? id;
  final int? ownerId;
  final int? fromId;
  final int? toId;
  final String? title;
  final String? body;
  final bool? isRead;
  final bool? isDeleted;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final bool? isSpam;
  final String? key;

  DmailDto({
    this.id,
    this.ownerId,
    this.fromId,
    this.toId,
    this.title,
    this.body,
    this.isRead,
    this.isDeleted,
    this.createdAt,
    this.updatedAt,
    this.isSpam,
    this.key,
  });

  factory DmailDto.fromJson(Map<String, dynamic> json) {
    return DmailDto(
      id: json['id'],
      ownerId: json['owner_id'],
      fromId: json['from_id'],
      toId: json['to_id'],
      title: json['title'],
      body: json['body'],
      isRead: json['is_read'],
      isDeleted: json['is_deleted'],
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'])
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.tryParse(json['updated_at'])
          : null,
      isSpam: json['is_spam'],
      key: json['key'],
    );
  }
}
