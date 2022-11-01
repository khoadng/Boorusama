mixin MediaInfoMixin {
  String get format;
  double get width;
  double get height;
  String get md5;
  double get aspectRatio => width / height;

  bool get isVideo {
    //TODO: handle other kind of video format
    final supportVideoFormat = {'mp4', 'webm', 'zip'};

    return supportVideoFormat.contains(format);
  }

  bool get isAnimated {
    return isVideo || (format == 'gif');
  }
}
