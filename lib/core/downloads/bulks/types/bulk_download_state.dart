// Package imports:
import 'package:equatable/equatable.dart';

// Project imports:
import 'bulk_download_session.dart';

class BulkDownloadState extends Equatable {
  const BulkDownloadState({
    this.sessions = const [],
    this.error,
    this.ready = false,
    this.hasUnseenFinishedSessions = false,
  });

  final List<BulkDownloadSession> sessions;
  final Object? error;
  final bool ready;
  final bool hasUnseenFinishedSessions;

  BulkDownloadState copyWith({
    List<BulkDownloadSession>? sessions,
    Object? Function()? error,
    bool? ready,
    bool? hasUnseenFinishedSessions,
  }) {
    return BulkDownloadState(
      sessions: sessions ?? this.sessions,
      error: error != null ? error() : this.error,
      ready: ready ?? this.ready,
      hasUnseenFinishedSessions:
          hasUnseenFinishedSessions ?? this.hasUnseenFinishedSessions,
    );
  }

  @override
  List<Object?> get props => [
        sessions,
        error,
        ready,
        hasUnseenFinishedSessions,
      ];
}
