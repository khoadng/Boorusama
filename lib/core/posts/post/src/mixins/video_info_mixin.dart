mixin VideoInfoMixin {
  String get format;
  double get duration;
  bool? get hasSound;
  String get videoUrl;
  String get videoThumbnailUrl;
}

bool isFormatVideo(String? format) {
  if (format == null) return false;
  final supportFormatWithDot = _supportVideoFormat.map((e) => '.$e');
  return _supportVideoFormat.contains(format) ||
      supportFormatWithDot.contains(format);
}

//TODO: handle other kind of video format
final _supportVideoFormat = {'mp4', 'webm', 'zip'};
