class FavoriteDto {
  FavoriteDto({
    required this.id,
    required this.juserId,
    required this.post,
    required this.addtime,
    required this.folder,
  });

  factory FavoriteDto.fromJson(Map<String, dynamic> json) {
    final addtime =
        json['addtime'] != null ? DateTime.tryParse(json['addtime']) : null;

    return FavoriteDto(
      id: json['id'],
      juserId: json['juser_id'],
      post: json['post'],
      addtime: addtime,
      folder: json['folder'],
    );
  }

  final int? id;
  final int? juserId;
  final int? post;
  final DateTime? addtime;
  final dynamic folder;
}
