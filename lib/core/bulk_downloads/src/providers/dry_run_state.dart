// Package imports:
import 'package:equatable/equatable.dart';

// Project imports:
import '../types/download_record.dart';

sealed class DryRunStatus {
  const DryRunStatus();
}

class DryRunStatusNotFound extends DryRunStatus {
  const DryRunStatusNotFound();
}

class DryRunStatusIdle extends DryRunStatus {
  const DryRunStatusIdle();
}

class DryRunStatusRunning extends DryRunStatus {
  const DryRunStatusRunning({
    this.isSlowRun = false,
    this.isPreparing = false,
  });

  const DryRunStatusRunning.slowRun() : isSlowRun = true, isPreparing = false;

  const DryRunStatusRunning.preparing() : isSlowRun = false, isPreparing = true;

  final bool isSlowRun;
  final bool isPreparing;
}

class DryRunStatusCompleted extends DryRunStatus {
  const DryRunStatusCompleted();
}

class DryRunStatusCancelled extends DryRunStatus {
  const DryRunStatusCancelled();
}

class DryRunStatusFailed extends DryRunStatus {
  const DryRunStatusFailed();
}

class DryRunState extends Equatable {
  const DryRunState({
    required this.status,
    required this.currentPage,
    required this.totalPages,
    this.currentItemIndex,
    this.error,
    this.allRecords = const [],
  });

  const DryRunState.notFound()
    : status = const DryRunStatusNotFound(),
      currentPage = null,
      currentItemIndex = null,
      totalPages = 0,
      error = null,
      allRecords = const [];

  factory DryRunState.initial() => const DryRunState(
    status: DryRunStatusIdle(),
    currentPage: null,
    totalPages: 0,
  );

  final DryRunStatus status;
  final int? currentPage;
  final int? currentItemIndex;
  final int totalPages;
  final String? error;
  final List<DownloadRecord> allRecords;

  DryRunState copyWith({
    DryRunStatus? status,
    int? Function()? currentPage,
    int? Function()? currentItemIndex,
    int? totalPages,
    String? error,
    List<DownloadRecord>? allRecords,
  }) {
    return DryRunState(
      status: status ?? this.status,
      currentPage: currentPage != null ? currentPage() : this.currentPage,
      currentItemIndex: currentItemIndex != null
          ? currentItemIndex()
          : this.currentItemIndex,
      totalPages: totalPages ?? this.totalPages,
      error: error ?? this.error,
      allRecords: allRecords ?? this.allRecords,
    );
  }

  @override
  List<Object?> get props => [
    status,
    currentPage,
    currentItemIndex,
    totalPages,
    error,
    allRecords,
  ];
}
