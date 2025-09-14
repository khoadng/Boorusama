class UserNameChangeRequestDto {
  UserNameChangeRequestDto({
    this.id,
    this.userId,
    this.originalName,
    this.desiredName,
    this.createdAt,
    this.updatedAt,
  });

  factory UserNameChangeRequestDto.fromJson(Map<String, dynamic> json) {
    return UserNameChangeRequestDto(
      id: json['id'],
      userId: json['user_id'],
      originalName: json['original_name'],
      desiredName: json['desired_name'],
      createdAt: switch (json['created_at']) {
        String s => DateTime.tryParse(s),
        _ => null,
      },
      updatedAt: switch (json['updated_at']) {
        String s => DateTime.tryParse(s),
        _ => null,
      },
    );
  }

  final int? id;
  final int? userId;
  final String? originalName;
  final String? desiredName;
  final DateTime? createdAt;
  final DateTime? updatedAt;
}
