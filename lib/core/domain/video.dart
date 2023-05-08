mixin VideoInfoMixin {
  String get format;
  bool get isFlash => format == 'swf';
  bool get isWebm => format == 'webm';
  double get duration;
}
