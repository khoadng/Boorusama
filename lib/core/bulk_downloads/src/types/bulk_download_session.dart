// Package imports:
import 'package:equatable/equatable.dart';

// Project imports:
import 'download_session.dart';
import 'download_session_stats.dart';
import 'download_task.dart';

class BulkDownloadSession extends Equatable {
  const BulkDownloadSession({
    required this.task,
    required this.session,
    required this.stats,
  });

  final DownloadTask task;
  final DownloadSession session;
  final DownloadSessionStats stats;

  BulkDownloadSession copyWith({
    DownloadTask? task,
    DownloadSession? session,
    DownloadSessionStats? stats,
  }) {
    return BulkDownloadSession(
      task: task ?? this.task,
      session: session ?? this.session,
      stats: stats ?? this.stats,
    );
  }

  String get id => session.id;

  @override
  List<Object?> get props => [task, session, stats];
}

class PageProgress extends Equatable {
  const PageProgress({
    required this.completed,
    required this.perPage,
  });

  PageProgress copyWith({
    int? completed,
    int? perPage,
  }) {
    return PageProgress(
      completed: completed ?? this.completed,
      perPage: perPage ?? this.perPage,
    );
  }

  final int completed;
  final int perPage;

  @override
  List<Object?> get props => [completed];
}
