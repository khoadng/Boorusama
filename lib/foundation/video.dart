mixin VideoInfoMixin {
  String get format;
  bool get isFlash => format == 'swf';
  bool get isWebm => format == 'webm';
  bool get isGif => format == 'gif';
  double get duration;
  bool? get hasSound;
  String get videoUrl;
  String get videoThumbnailUrl;
}
