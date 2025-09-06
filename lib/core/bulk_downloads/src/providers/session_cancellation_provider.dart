// Package imports:
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class SessionCancellationState {
  const SessionCancellationState({
    this.cancelTokens = const {},
  });

  final Map<String, CancelToken> cancelTokens;

  SessionCancellationState copyWith({
    Map<String, CancelToken>? cancelTokens,
  }) {
    return SessionCancellationState(
      cancelTokens: cancelTokens ?? this.cancelTokens,
    );
  }
}

/// Manages cancellation tokens for download sessions
final sessionCancellationProvider =
    NotifierProvider<SessionCancellationNotifier, SessionCancellationState>(
      SessionCancellationNotifier.new,
    );

class SessionCancellationNotifier extends Notifier<SessionCancellationState> {
  @override
  SessionCancellationState build() {
    return const SessionCancellationState();
  }

  CancelToken createToken(String sessionId) {
    final cancelToken = CancelToken();
    state = state.copyWith(
      cancelTokens: {...state.cancelTokens, sessionId: cancelToken},
    );
    return cancelToken;
  }

  Future<void> cancelToken(String sessionId) async {
    final cancelToken = state.cancelTokens[sessionId];
    if (cancelToken != null && !cancelToken.isCancelled) {
      cancelToken.cancel();

      state = state.copyWith(
        cancelTokens: {
          ...state.cancelTokens..remove(sessionId),
        },
      );
    }
  }

  CancelToken? getToken(String sessionId) {
    return state.cancelTokens[sessionId];
  }

  Future<void> cancelAll() async {
    for (final cancelToken in state.cancelTokens.values) {
      if (!cancelToken.isCancelled) {
        cancelToken.cancel();
      }
    }

    state = const SessionCancellationState();
  }
}
