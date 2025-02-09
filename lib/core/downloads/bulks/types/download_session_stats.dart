// Package imports:
import 'package:equatable/equatable.dart';

class DownloadSessionStats extends Equatable {
  const DownloadSessionStats({
    required this.sessionId,
    this.coverUrl,
    this.totalItems = 0,
    this.siteUrl,
    this.estimatedDownloadSize,
  });

  final String sessionId;
  final String? coverUrl;
  final int totalItems;
  final String? siteUrl;
  final int? estimatedDownloadSize;

  static const empty = DownloadSessionStats(sessionId: '');

  @override
  List<Object?> get props => [
        sessionId,
        coverUrl,
        totalItems,
        siteUrl,
        estimatedDownloadSize,
      ];
}
