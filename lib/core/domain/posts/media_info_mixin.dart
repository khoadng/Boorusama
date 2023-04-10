mixin MediaInfoMixin {
  String get format;
  String get md5;
  int get fileSize;

  bool get isVideo {
    //TODO: handle other kind of video format
    final supportVideoFormat = {'mp4', 'webm', 'zip'};

    return supportVideoFormat.contains(format);
  }

  bool get isFlash => format == 'swf';

  bool get isWebm => format == 'webm';

  bool get isAnimated {
    return isVideo || (format == 'gif');
  }
}
