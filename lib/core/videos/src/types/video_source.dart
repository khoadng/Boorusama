// Dart imports:
import 'dart:convert';
import 'dart:io';

/// Result of getting optimal URL from a video source
sealed class VideoUrlResult {
  const VideoUrlResult({required this.url});
  final String url;
}

/// Successfully using cached content
class CachedUrlResult extends VideoUrlResult {
  const CachedUrlResult({required super.url, required this.isDataUrl});
  final bool isDataUrl;
}

/// Fallback to streaming due to error or constraints
class StreamingFallbackResult extends VideoUrlResult {
  const StreamingFallbackResult({required super.url, this.reason});
  final String? reason;
}

/// Video source information for players
sealed class VideoSource {
  const VideoSource({required this.originalUrl});

  /// The original streaming URL
  final String originalUrl;

  /// The URL to use for playback
  String get url;

  /// Whether the cached file is small enough for certain operations
  bool isSmallEnoughFor(int maxBytes);
}

/// Streaming video source (no caching)
class StreamingVideoSource extends VideoSource {
  const StreamingVideoSource(String url) : super(originalUrl: url);

  @override
  String get url => originalUrl;

  @override
  bool isSmallEnoughFor(int maxBytes) => false; // No size limit for streaming

  @override
  String toString() => 'StreamingVideoSource(url: $url)';
}

/// Cached video file source
class CachedVideoSource extends VideoSource {
  const CachedVideoSource({
    required this.cachedUrl,
    required super.originalUrl,
    this.fileSizeBytes,
  });

  /// Factory that automatically determines file size from cached URL
  factory CachedVideoSource.fromUrl({
    required String cachedUrl,
    required String originalUrl,
  }) {
    return CachedVideoSource(
      cachedUrl: cachedUrl,
      originalUrl: originalUrl,
      fileSizeBytes: _getFileSize(cachedUrl),
    );
  }

  /// Gets file size from cached file URL, returns null if not accessible
  static int? _getFileSize(String cachedUrl) {
    try {
      if (!cachedUrl.startsWith('file://')) return null;
      final file = File(cachedUrl.replaceFirst('file://', ''));
      return file.existsSync() ? file.lengthSync() : null;
    } catch (e) {
      return null;
    }
  }

  /// The cached file URL
  final String cachedUrl;

  /// Size of cached file in bytes (if available)
  final int? fileSizeBytes;

  @override
  String get url => cachedUrl;

  /// Size in MB for display purposes
  double? get fileSizeMB =>
      fileSizeBytes != null ? fileSizeBytes! / (1024 * 1024) : null;

  @override
  bool isSmallEnoughFor(int maxBytes) =>
      fileSizeBytes != null && fileSizeBytes! < maxBytes;

  /// Gets MIME type based on original URL extension
  String get mimeType {
    final lower = originalUrl.toLowerCase();
    if (lower.contains('.webm')) return 'video/webm';
    if (lower.contains('.mp4')) return 'video/mp4';
    if (lower.contains('.mov')) return 'video/quicktime';
    if (lower.contains('.avi')) return 'video/x-msvideo';
    return 'video/mp4'; // Default fallback
  }

  /// Reads cached file bytes, returns null if file doesn't exist or can't be read
  List<int>? readBytes() {
    try {
      if (!cachedUrl.startsWith('file://')) return null;
      final file = File(cachedUrl.replaceFirst('file://', ''));
      return file.existsSync() ? file.readAsBytesSync() : null;
    } catch (e) {
      return null;
    }
  }

  /// Converts cached file to data URL, returns null if conversion fails
  String? toDataUrl() {
    final bytes = readBytes();
    if (bytes == null) return null;

    try {
      final base64 = base64Encode(bytes);
      return 'data:$mimeType;base64,$base64';
    } catch (e) {
      return null;
    }
  }

  /// Gets optimal URL result for platform use
  VideoUrlResult getOptimalUrl({bool preferDataUrl = false}) =>
      switch (preferDataUrl) {
        true => switch (toDataUrl()) {
          null => StreamingFallbackResult(
            url: originalUrl,
            reason: 'Data URL conversion failed',
          ),
          final url => CachedUrlResult(url: url, isDataUrl: true),
        },
        false => CachedUrlResult(url: cachedUrl, isDataUrl: false),
      };

  @override
  String toString() =>
      'CachedVideoSource('
      'cachedUrl: $cachedUrl, '
      'originalUrl: $originalUrl'
      '${fileSizeBytes != null ? ', size: ${fileSizeMB!.toStringAsFixed(1)}MB' : ''}'
      ')';
}
