//TODO: handle other kind of video format
final _supportVideoFormat = {'mp4', 'webm', 'zip'};

mixin VideoInfoMixin {
  String get format;
  bool get isFlash => format == 'swf' || format == '.swf';
  bool get isWebm => format == 'webm' || format == '.webm';
  bool get isGif => format == 'gif' || format == '.gif';
  double get duration;
  bool? get hasSound;
  String get videoUrl;
  String get videoThumbnailUrl;

  bool get isMp4 => format == 'mp4' || format == '.mp4';
}

bool isFormatVideo(String? format) {
  if (format == null) return false;
  final supportFormatWithDot = _supportVideoFormat.map((e) => '.$e');
  return _supportVideoFormat.contains(format) ||
      supportFormatWithDot.contains(format);
}
