import 'package:equatable/equatable.dart';

import '../../../../downloads/urls/sanitizer.dart';
import 'post.dart';

class VideoInfo extends Equatable {
  const VideoInfo({
    required this.videoUrl,
    required this.videoThumbnailUrl,
    required this.duration,
    required this.hasSound,
    required this.format,
  });

  final String videoUrl;
  final String videoThumbnailUrl;
  final double duration;
  final bool? hasSound;
  final String format;

  bool get isFlash => format == 'swf' || format == '.swf';
  bool get isWebm => format == 'webm' || format == '.webm';
  bool get isGif => format == 'gif' || format == '.gif';
  bool get isMp4 => format == 'mp4' || format == '.mp4';

  @override
  List<Object?> get props => [
    videoUrl,
    videoThumbnailUrl,
    duration,
    hasSound,
    format,
  ];
}

abstract class VideoInfoExtractor {
  VideoInfo extract(Post post);
}

class DefaultVideoInfoExtractor implements VideoInfoExtractor {
  const DefaultVideoInfoExtractor({
    this.hasSound,
  });

  final bool? Function(Post post)? hasSound;

  @override
  VideoInfo extract(Post post) {
    final format = _extractFormat(post);

    return VideoInfo(
      videoUrl: post.videoUrl,
      videoThumbnailUrl: post.videoThumbnailUrl,
      duration: post.duration,
      hasSound: hasSound?.call(post),
      format: format,
    );
  }

  String _extractFormat(Post post) {
    final ext = sanitizedExtension(post.videoUrl);
    if (ext.isEmpty) return post.format;
    return ext.substring(1);
  }
}
