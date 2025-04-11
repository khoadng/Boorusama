abstract class ImageUrlResolver {
  String resolveImageUrl(String originalUrl);
  String resolvePreviewUrl(String originalUrl);
  String resolveThumbnailUrl(String originalUrl);
}

class DefaultImageUrlResolver implements ImageUrlResolver {
  const DefaultImageUrlResolver();

  @override
  String resolveImageUrl(String url) => url;
  @override
  String resolvePreviewUrl(String url) => url;
  @override
  String resolveThumbnailUrl(String url) => url;
}
