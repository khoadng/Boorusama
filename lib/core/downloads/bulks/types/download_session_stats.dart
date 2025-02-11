// Package imports:
import 'package:equatable/equatable.dart';

class DownloadSessionStats extends Equatable {
  const DownloadSessionStats({
    required this.id,
    required this.sessionId,
    this.coverUrl,
    this.totalItems = 0,
    this.siteUrl,
    this.totalSize,
    this.averageDuration,
    this.averageFileSize,
    this.largestFileSize,
    this.smallestFileSize,
    this.medianFileSize,
    this.avgFilesPerPage,
    this.maxFilesPerPage,
    this.minFilesPerPage,
    this.extensionCounts = const {},
  });

  // If null, the session is not saved in the database.
  final int? id;
  final String? sessionId;
  final String? coverUrl;
  final int totalItems;
  final String? siteUrl;
  final int? totalSize;
  final Duration? averageDuration;
  final int? averageFileSize;
  final int? largestFileSize;
  final int? smallestFileSize;
  final int? medianFileSize;
  final double? avgFilesPerPage;
  final int? maxFilesPerPage;
  final int? minFilesPerPage;
  final Map<String, int> extensionCounts;

  int? get estimatedDownloadSize => totalSize;

  static const empty = DownloadSessionStats(id: -1, sessionId: '');

  @override
  List<Object?> get props => [
        id,
        sessionId,
        coverUrl,
        totalItems,
        siteUrl,
        totalSize,
        averageDuration,
        averageFileSize,
        largestFileSize,
        smallestFileSize,
        medianFileSize,
        avgFilesPerPage,
        maxFilesPerPage,
        minFilesPerPage,
        extensionCounts,
      ];
}
