class Post {
  final Uri _previewImageUri;
  final Uri _normalImageUri;

  Post([this._previewImageUri, this._normalImageUri]);

  Uri get previewImageUri {
    return _previewImageUri;
  }

  Uri get normalImageUri {
    return _normalImageUri;
  }

  factory Post.fromJson(Map<String, dynamic> json) {
    return new Post(
      Uri.parse(json["preview_file_url"]),
      Uri.parse(json["large_file_url"]),
    );
  }
}
