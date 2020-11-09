class Comment {
  final int _id;
  final String _createdAt;
  final int _postId;
  final int _creatorId;
  final String _body;
  final int _score;
  final String _updatedAt;
  final int _updaterId;

  Comment(
      {int id,
      String createdAt,
      int postId,
      int creatorId,
      String body,
      int score,
      String updatedAt,
      int updaterId})
      : _id = id,
        _createdAt = createdAt,
        _postId = postId,
        _creatorId = creatorId,
        _body = body,
        _score = score,
        _updatedAt = updatedAt,
        _updaterId = updaterId;

  int get id => _id;
  int get postId => _postId;
  int get creatorId => _creatorId;
  int get score => _score;
  //TODO: handler error when parsing
  DateTime get createdAt => DateTime.parse(_createdAt);
  //TODO: should use ADT instead of String
  String get body => _body;

  factory Comment.fromJson(Map<String, dynamic> json) {
    assert(json != null);

    return Comment(
      id: json["id"],
      createdAt: json["created_at"],
      postId: json["post_id"],
      creatorId: json["creator_id"],
      body: json["body"],
      score: json["score"],
      updatedAt: json["updated_at"],
      updaterId: json["updater_id"],
    );
  }
}
