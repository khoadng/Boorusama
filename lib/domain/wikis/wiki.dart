class Wiki {
  int _id;
  String _title;
  String _body;
  List<dynamic> _otherNames;

  Wiki(this._id, this._title, this._body, this._otherNames);

  String get title => _title;
  String get body => _body;

  factory Wiki.fromJson(Map<String, dynamic> json) {
    return Wiki(
      json["id"],
      json["title"],
      json["body"],
      json["other_names"],
    );
  }
}
