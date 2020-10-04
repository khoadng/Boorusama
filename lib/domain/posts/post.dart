class Post {
  final Uri _previewImageUri;
  final Uri _normalImageUri;
  final Uri _fullImageUri;
  final int _width;
  final int _height;
  //TODO: should use Enum instead of raw string
  final String _format;

//TODO: fix naming from Image to Post
  Post(
      [this._previewImageUri,
      this._normalImageUri,
      this._fullImageUri,
      this._width,
      this._height,
      this._format]);

  Uri get previewImageUri {
    return _previewImageUri;
  }

  Uri get normalImageUri {
    return _normalImageUri;
  }

  Uri get fullImageUri {
    return _fullImageUri;
  }

  int get width {
    return _width;
  }

  int get height {
    return _height;
  }

  double get aspectRatio {
    return width / height;
  }

  bool get isVideo {
    //TODO: handle other kind of video format
    final supportVideoFormat = ["mp4", "webm", "zip"];
    if (supportVideoFormat.contains(_format)) {
      return true;
    } else {
      return false;
    }
  }

  factory Post.fromJson(Map<String, dynamic> json) {
    //TODO: should use json deserialize library
    return new Post(
      Uri.parse(json["preview_file_url"]),
      Uri.parse(json["large_file_url"]),
      Uri.parse(json["file_url"]),
      json["image_width"],
      json["image_height"],
      json["file_ext"],
    );
  }
}
