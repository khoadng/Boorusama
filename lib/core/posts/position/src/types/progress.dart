// Package imports:
import 'package:equatable/equatable.dart';

// Project imports:
import 'location.dart';

sealed class PageFinderProgress extends Equatable {
  const PageFinderProgress();
}

class PageFinderIdle extends PageFinderProgress {
  const PageFinderIdle();

  @override
  List<Object?> get props => [];
}

class PageFinderSearchingProgress extends PageFinderProgress {
  const PageFinderSearchingProgress({
    required this.currentPage,
    required this.requestCount,
    required this.targetId,
  });
  final int currentPage;
  final int requestCount;
  final int targetId;

  @override
  List<Object?> get props => [currentPage, requestCount, targetId];
}

class PageFinderFetchingProgress extends PageFinderProgress {
  const PageFinderFetchingProgress({
    required this.page,
    required this.requestNumber,
  });
  final int page;
  final int requestNumber;

  @override
  List<Object?> get props => [page, requestNumber];
}

class PageFinderCompletedProgress extends PageFinderProgress {
  const PageFinderCompletedProgress({
    required this.location,
    required this.totalRequests,
  });
  final PageLocation location;
  final int totalRequests;

  @override
  List<Object?> get props => [location, totalRequests];
}

class PageFinderFailedProgress extends PageFinderProgress {
  const PageFinderFailedProgress(this.error);
  final Object error;

  @override
  List<Object?> get props => [error];
}

class PageFinderBeyondLimitProgress extends PageFinderProgress {
  const PageFinderBeyondLimitProgress(this.exception);
  final Object exception;

  @override
  List<Object?> get props => [exception];
}
