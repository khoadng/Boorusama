sealed class PreloadMedia {
  const PreloadMedia({
    required this.thumbnailUrl,
    required this.originalUrl,
    this.sampleUrl,
    this.estimatedSizeBytes,
  });

  final String thumbnailUrl;
  final String? sampleUrl;
  final String originalUrl;
  final int? estimatedSizeBytes;

  Set<String> get allUrls => {
    thumbnailUrl,
    ?sampleUrl,
    originalUrl,
  };
}

class ImageMedia extends PreloadMedia {
  const ImageMedia({
    required super.thumbnailUrl,
    required super.originalUrl,
    super.sampleUrl,
    super.estimatedSizeBytes,
  });

  const ImageMedia.fromUrl(
    String url, {
    super.estimatedSizeBytes,
  }) : super(
         thumbnailUrl: url,
         originalUrl: url,
       );
}

class VideoMedia extends PreloadMedia {
  const VideoMedia({
    required String videoUrl,
    required String videoThumbnailUrl,
    this.estimatedDuration,
    super.estimatedSizeBytes,
  }) : super(
         thumbnailUrl: videoThumbnailUrl,
         originalUrl: videoUrl,
       );

  final Duration? estimatedDuration;
}
