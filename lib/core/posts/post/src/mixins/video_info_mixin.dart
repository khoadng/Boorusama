// Package imports:
import 'package:coreutils/coreutils.dart';

mixin VideoInfoMixin {
  String get format;
  bool get isFlash => _format() == 'swf' || _format() == '.swf';
  bool get isWebm => _format() == 'webm' || _format() == '.webm';
  bool get isGif => _format() == 'gif' || _format() == '.gif';
  double get duration;
  bool? get hasSound;
  String get videoUrl;
  String get videoThumbnailUrl;

  String _format() {
    final ext = urlExtension(videoUrl);
    if (ext.isEmpty) return format;

    return ext.substring(1);
  }

  bool get isMp4 => _format() == 'mp4' || _format() == '.mp4';
}

bool isFormatVideo(String? format) {
  if (format == null) return false;
  final supportFormatWithDot = _supportVideoFormat.map((e) => '.$e');
  return _supportVideoFormat.contains(format) ||
      supportFormatWithDot.contains(format);
}

//TODO: handle other kind of video format
final _supportVideoFormat = {'mp4', 'webm', 'zip'};
