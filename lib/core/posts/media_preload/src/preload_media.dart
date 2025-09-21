sealed class PreloadMedia {
  const PreloadMedia({
    required this.thumbnailUrl,
    required this.sampleUrl,
    required this.originalUrl,
    this.estimatedSizeBytes,
  });

  final String thumbnailUrl;
  final String sampleUrl;
  final String originalUrl;
  final int? estimatedSizeBytes;

  Set<String> get allUrls {
    return {thumbnailUrl, sampleUrl, originalUrl};
  }
}

class ImageMedia extends PreloadMedia {
  const ImageMedia({
    required super.thumbnailUrl,
    required super.sampleUrl,
    required super.originalUrl,
    super.estimatedSizeBytes,
  });

  const ImageMedia.fromUrl(
    String url, {
    super.estimatedSizeBytes,
  }) : super(
         thumbnailUrl: url,
         sampleUrl: url,
         originalUrl: url,
       );

  bool get allUrlsSame => thumbnailUrl == sampleUrl && sampleUrl == originalUrl;
}

class VideoMedia extends PreloadMedia {
  const VideoMedia({
    required String videoUrl,
    required String videoThumbnailUrl,
    this.estimatedDuration,
    super.estimatedSizeBytes,
  }) : super(
         thumbnailUrl: videoThumbnailUrl,
         sampleUrl: videoThumbnailUrl,
         originalUrl: videoUrl,
       );

  final Duration? estimatedDuration;
}
