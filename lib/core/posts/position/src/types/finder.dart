// Dart imports:
import 'dart:async';

// Project imports:
import 'location.dart';

class PageFinderEmptyPageException implements Exception {
  @override
  String toString() => 'Empty page';
}

class PageFinderInvalidPageException implements Exception {
  @override
  String toString() => 'Invalid page';
}

class PageFinderBeyondLimitException implements Exception {
  PageFinderBeyondLimitException({
    required this.maxPage,
    required this.requestedPage,
  });

  final int maxPage;
  final int requestedPage;

  @override
  String toString() =>
      'Target is beyond pagination limit (requested: $requestedPage, max: $maxPage)';
}

class PageFinderServerException implements Exception {
  PageFinderServerException(this.message);

  final String message;

  @override
  String toString() => 'Server error: $message';
}

abstract class PageFinder {
  Future<PageLocation?> findPage(PaginationSnapshot snapshot);
}

class PaginationSnapshot {
  PaginationSnapshot({
    required this.targetId,
    required this.tags,
    this.historicalPage,
    this.historicalChunkSize,
    this.timestamp,
  });
  final int targetId;
  final String tags;
  final int? historicalPage;
  final int? historicalChunkSize;
  final DateTime? timestamp;
}
