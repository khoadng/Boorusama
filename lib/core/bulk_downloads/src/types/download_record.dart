// Package imports:
import 'package:equatable/equatable.dart';

enum DownloadRecordStatus {
  pending,
  downloading,
  paused,
  completed,
  failed,
  cancelled;

  static DownloadRecordStatus fromString(String value) {
    return DownloadRecordStatus.values.firstWhere(
      (e) => e.name == value,
      orElse: () => DownloadRecordStatus.pending,
    );
  }
}

class DownloadRecord extends Equatable {
  const DownloadRecord({
    required this.url,
    required this.sessionId,
    required this.status,
    required this.page,
    required this.pageIndex,
    required this.createdAt,
    required this.fileName,
    this.fileSize,
    this.extension,
    this.error,
    this.downloadId,
    this.headers,
    this.thumbnailImageUrl,
    this.sourceUrl,
  });

  final String url;
  final String sessionId;
  final DownloadRecordStatus status;
  final int page;
  final int pageIndex;
  final DateTime createdAt;
  final int? fileSize;
  final String fileName;
  final String? extension;
  final String? error;
  final String? downloadId;
  final Map<String, String>? headers;
  final String? thumbnailImageUrl;
  final String? sourceUrl;

  DownloadRecord copyWith({
    String? url,
    String? sessionId,
    DownloadRecordStatus? status,
    int? page,
    int? pageIndex,
    DateTime? createdAt,
    int? fileSize,
    String? fileName,
    String? extension,
    String? error,
    String? downloadId,
    Map<String, String>? headers,
    String? thumbnailImageUrl,
    String? sourceUrl,
  }) {
    return DownloadRecord(
      url: url ?? this.url,
      sessionId: sessionId ?? this.sessionId,
      status: status ?? this.status,
      page: page ?? this.page,
      pageIndex: pageIndex ?? this.pageIndex,
      createdAt: createdAt ?? this.createdAt,
      fileSize: fileSize ?? this.fileSize,
      fileName: fileName ?? this.fileName,
      extension: extension ?? this.extension,
      error: error ?? this.error,
      downloadId: downloadId ?? this.downloadId,
      headers: headers ?? this.headers,
      thumbnailImageUrl: thumbnailImageUrl ?? this.thumbnailImageUrl,
      sourceUrl: sourceUrl ?? this.sourceUrl,
    );
  }

  @override
  List<Object?> get props => [
        url,
        sessionId,
        status,
        page,
        pageIndex,
        createdAt,
        fileSize,
        fileName,
        extension,
        error,
        downloadId,
        headers,
        thumbnailImageUrl,
        sourceUrl,
      ];

  @override
  String toString() => 'url: $url, status: $status';
}
