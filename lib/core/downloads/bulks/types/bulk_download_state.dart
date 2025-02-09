// Package imports:
import 'package:equatable/equatable.dart';

// Project imports:
import 'bulk_download_session.dart';

class BulkDownloadState extends Equatable {
  const BulkDownloadState({
    this.sessions = const [],
    this.error,
    this.ready = false,
  });

  final List<BulkDownloadSession> sessions;
  final Object? error;
  final bool ready;

  BulkDownloadState copyWith({
    List<BulkDownloadSession>? sessions,
    Object? Function()? error,
    bool? ready,
  }) {
    return BulkDownloadState(
      sessions: sessions ?? this.sessions,
      error: error != null ? error() : this.error,
      ready: ready ?? this.ready,
    );
  }

  @override
  List<Object?> get props => [sessions, error, ready];
}
