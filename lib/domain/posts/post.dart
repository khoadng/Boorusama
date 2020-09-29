class Post {
  final Uri _previewImageUri;

  Post([this._previewImageUri]);

  Uri get previewImageUri {
    return _previewImageUri;
  }

  factory Post.fromJson(Map<String, dynamic> json) {
    return new Post(Uri.parse(json["preview_file_url"]));
  }
}
