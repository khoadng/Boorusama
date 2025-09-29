// Project imports:
import '../../../../downloads/urls/sanitizer.dart';

mixin VideoInfoMixin {
  String get format;
  bool get isGif => _format() == 'gif' || _format() == '.gif';
  double get duration;
  bool? get hasSound;
  String get videoUrl;
  String get videoThumbnailUrl;

  String _format() {
    final ext = sanitizedExtension(videoUrl);
    if (ext.isEmpty) return format;

    return ext.substring(1);
  }
}

bool isFormatVideo(String? format) {
  if (format == null) return false;
  final supportFormatWithDot = _supportVideoFormat.map((e) => '.$e');
  return _supportVideoFormat.contains(format) ||
      supportFormatWithDot.contains(format);
}

//TODO: handle other kind of video format
final _supportVideoFormat = {'mp4', 'webm', 'zip'};
