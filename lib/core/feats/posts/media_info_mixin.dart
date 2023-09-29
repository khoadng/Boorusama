//TODO: handle other kind of video format
final _supportVideoFormat = {'mp4', 'webm', 'zip'};

mixin MediaInfoMixin {
  String get format;
  String get md5;
  int get fileSize;

  bool get isVideo {
    return _supportVideoFormat.contains(format);
  }

  bool get isFlash => format == 'swf';

  bool get isWebm => format == 'webm';
  bool get isMp4 => format == 'mp4';

  bool get isAnimated {
    return isVideo || (format == 'gif');
  }
}
