// Package imports:
import 'package:equatable/equatable.dart';

enum DownloadSessionStatus {
  pending,
  dryRun,
  running,
  completed,
  failed,
  interrupted,
  paused,
  cancelled;

  static DownloadSessionStatus fromString(String value) {
    return DownloadSessionStatus.values.firstWhere(
      (e) => e.name == value,
      orElse: () => DownloadSessionStatus.pending,
    );
  }
}

class DownloadSession extends Equatable {
  const DownloadSession({
    required this.id,
    required this.taskId,
    required this.startedAt,
    required this.currentPage,
    required this.status,
    this.completedAt,
    this.totalPages,
    this.error,
  });

  final String id;
  final String taskId;
  final DateTime startedAt;
  final DateTime? completedAt;
  final int currentPage;
  final int? totalPages;
  final DownloadSessionStatus status;
  final String? error;

  DownloadSession copyWith({
    String? id,
    String? taskId,
    DateTime? startedAt,
    DateTime? completedAt,
    int? currentPage,
    int? totalPages,
    DownloadSessionStatus? status,
    String? error,
  }) {
    return DownloadSession(
      id: id ?? this.id,
      taskId: taskId ?? this.taskId,
      startedAt: startedAt ?? this.startedAt,
      completedAt: completedAt ?? this.completedAt,
      currentPage: currentPage ?? this.currentPage,
      totalPages: totalPages ?? this.totalPages,
      status: status ?? this.status,
      error: error ?? this.error,
    );
  }

  @override
  List<Object?> get props => [
        id,
        taskId,
        startedAt,
        completedAt,
        currentPage,
        totalPages,
        status,
        error,
      ];
}
