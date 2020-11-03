class Comment {
  int _id;
  String _createdAt;
  int _postId;
  int _creatorId;
  String _body;
  int _score;
  String _updatedAt;
  int _updaterId;

  Comment(this._id, this._createdAt, this._postId, this._creatorId, this._body,
      this._score, this._updatedAt, this._updaterId);

  int get id => _id;
  int get postId => _postId;
  int get creatorId => _creatorId;
  int get score => _score;
  //TODO: handler error when parsing
  DateTime get createdAt => DateTime.parse(_createdAt);
  //TODO: should use ADT instead of String
  String get body => _body;

  factory Comment.fromJson(Map<String, dynamic> json) {
    return Comment(
      json["id"],
      json["created_at"],
      json["post_id"],
      json["creator_id"],
      json["body"],
      json["score"],
      json["updated_at"],
      json["updater_id"],
    );
  }
}
