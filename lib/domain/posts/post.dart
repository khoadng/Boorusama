class Post {
  final Uri _previewImageUri;
  final Uri _normalImageUri;
  final int _width;
  final int _height;

  Post(
      [this._previewImageUri, this._normalImageUri, this._width, this._height]);

  Uri get previewImageUri {
    return _previewImageUri;
  }

  Uri get normalImageUri {
    return _normalImageUri;
  }

  int get width {
    return _width;
  }

  int get height {
    return _height;
  }

  factory Post.fromJson(Map<String, dynamic> json) {
    return new Post(
      Uri.parse(json["preview_file_url"]),
      Uri.parse(json["large_file_url"]),
      json["image_width"],
      json["image_height"],
    );
  }
}
