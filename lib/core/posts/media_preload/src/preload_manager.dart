// Dart imports:
import 'dart:async';
import 'dart:math' as math;

// Flutter imports:
import 'package:flutter/foundation.dart';

// Package imports:
import 'package:collection/collection.dart';
import 'package:dio/dio.dart';
import 'package:equatable/equatable.dart';

// Project imports:
import 'preload_media.dart';
import 'preload_strategy.dart';
import 'types.dart';

const kEnablePreloadLogging = true;

class PreloadManager {
  PreloadManager({
    required Preloader preloader,
    DownloadConfiguration? downloadConfiguration,
  }) : _preloader = preloader,
       _downloadConfiguration =
           downloadConfiguration ?? const DownloadConfiguration();

  final Preloader _preloader;
  final DownloadConfiguration _downloadConfiguration;

  void _log(String message) {
    if (kEnablePreloadLogging) {
      debugPrint(message);
    }
  }

  final Map<String, CancelToken> _activeCancelTokens = {};
  final Set<String> _activeDownloads = {};
  final Set<String> _completedUrls = {}; // URLs that completed successfully
  final _pendingQueue = PriorityQueue<PrioritizedUrl>();
  Set<String> _currentSkipUrls = {};

  void preloadMedias(PreloadResult result) {
    final skipUrls = result.skipUrls;
    final cancelUrls = result.cancelUrls;

    for (final urlToCancel in cancelUrls) {
      if (_activeCancelTokens.containsKey(urlToCancel)) {
        _log(
          '[IPM] Cancellation: ${urlToCancel.split('/').last}',
        );
        _activeCancelTokens[urlToCancel]?.cancel();
        _activeCancelTokens.remove(urlToCancel);
        _activeDownloads.remove(urlToCancel);
      }
    }

    // Store current state
    _currentSkipUrls = Set.from(skipUrls);

    // Rebuild priority queue using strategy-provided priorities
    _rebuildPriorityQueue(result.prioritizedUrls, skipUrls);

    if (_pendingQueue.isEmpty) return;

    _logState(
      'Starting preload batch',
      pending: _pendingQueue.length,
      active: _activeDownloads.length,
      completed: _completedUrls.length,
    );
    _startNextDownloads();
  }

  /// Rebuild priority queue using strategy-provided priorities
  void _rebuildPriorityQueue(
    List<PrioritizedUrl> prioritizedUrls,
    Set<String> skipUrls,
  ) {
    _pendingQueue.clear();

    for (final prioritizedUrl in prioritizedUrls) {
      if (!skipUrls.contains(prioritizedUrl.url) &&
          !_completedUrls.contains(prioritizedUrl.url) &&
          !_activeDownloads.contains(prioritizedUrl.url)) {
        _pendingQueue.add(prioritizedUrl);
      }
    }

    if (kEnablePreloadLogging && _pendingQueue.isNotEmpty) {
      _log(
        '[IPM] Rebuilt priority queue with ${_pendingQueue.length} URLs',
      );
      final items = _pendingQueue.toList()..sort();
      for (var i = 0; i < math.min(3, items.length); i++) {
        _log('[IPM] Priority #${i + 1}: ${items[i]}');
      }
    }
  }

  /// Convenience method to calculate and preload using a strategy
  void preloadWithStrategy({
    required PreloadStrategy strategy,
    required int currentPage,
    required int itemCount,
    required PreloadMedia? Function(int index) mediaBuilder,
  }) {
    final context = PreloadContext(
      currentPage: currentPage,
      itemCount: itemCount,
      mediaBuilder: mediaBuilder,
      activeDownloads: Set.from(_activeDownloads),
      completedUrls: Set.from(_completedUrls),
    );
    final result = strategy.calculatePreload(context);
    preloadMedias(result);
  }

  void cancelAll() {
    for (final cancelToken in _activeCancelTokens.values) {
      cancelToken.cancel();
    }

    final activeCount = _activeDownloads.length;
    final pendingCount = _pendingQueue.length;
    final tokenCount = _activeCancelTokens.length;

    _activeCancelTokens.clear();
    _activeDownloads.clear();
    _pendingQueue.clear();
    _currentSkipUrls.clear();

    if (kEnablePreloadLogging) {
      if (activeCount > 0 || pendingCount > 0) {
        _log(
          '[IPM] Resource cleanup: cancelled_active=$activeCount cancelled_pending=$pendingCount tokens_cleared=$tokenCount reason=cancel_all',
        );
      }
    }
    // Note: Don't clear _completedUrls as it represents persistent state
  }

  /// For testing/debugging
  PreloadManagerState get state => PreloadManagerState(
    activeDownloads: Set.from(_activeDownloads),
    completedUrls: Set.from(_completedUrls),
    activeCancelTokensCount: _activeCancelTokens.length,
  );

  void _startNextDownloads() {
    while (_activeDownloads.length <
            _downloadConfiguration.maxConcurrentDownloads &&
        _pendingQueue.isNotEmpty) {
      final prioritizedUrl = _pendingQueue.removeFirst();
      final url = prioritizedUrl.url;

      // Double-check the URL is still valid to preload
      if (!_currentSkipUrls.contains(url) &&
          !_completedUrls.contains(url) &&
          !_activeDownloads.contains(url)) {
        _logState(
          'Starting download',
          url: url,
          active: _activeDownloads.length + 1,
          extra: {
            'priority': prioritizedUrl.priority,
            'zone': prioritizedUrl.relevanceZone.name,
          },
        );
        // Fire and forget - we handle errors in the method itself
        _preloadSingleUrl(url);
      } else {
        if (kEnablePreloadLogging) {
          final reason = _currentSkipUrls.contains(url)
              ? 'in_skip_set'
              : _completedUrls.contains(url)
              ? 'already_completed'
              : 'already_active';
          _log(
            '[IPM] Skipped download: url=${url.split('/').last} reason=$reason priority=${prioritizedUrl.priority}',
          );
        }
      }
    }
  }

  Future<void> _preloadSingleUrl(String url) async {
    _activeDownloads.add(url);

    final cancelToken = CancelToken();
    _activeCancelTokens[url] = cancelToken;

    try {
      await _preloader(url, cancelToken);
      // Success: mark as completed
      _completedUrls.add(url);
      _logState(
        'Download completed',
        url: url,
        completed: _completedUrls.length,
      );
    } catch (error) {
      // Let caller handle all retries. If we get here, the preload failed
      // after all retries.
      _logState(
        'Download failed',
        url: url,
        extra: {'error': error.toString().split('\n').first},
      );
    } finally {
      // This block ALWAYS runs, ensuring cleanup
      _activeDownloads.remove(url);
      _activeCancelTokens.remove(url);
      _startNextDownloads();
    }
  }

  void dispose() {
    cancelAll();
  }

  void _logState(
    String action, {
    int? active,
    int? pending,
    int? completed,
    int? cancelled,
    String? url,
    Map<String, dynamic>? extra,
  }) {
    if (!kEnablePreloadLogging) return;

    final parts = <String>['[IPM]', action];
    if (url != null) parts.add('url=${url.split('/').last}');
    if (active != null) parts.add('active_downloads=$active');
    if (pending != null) parts.add('pending_downloads=$pending');
    if (completed != null) parts.add('completed_downloads=$completed');
    if (cancelled != null) parts.add('cancelled_downloads=$cancelled');
    if (extra != null) {
      extra.forEach((k, v) => parts.add('$k=$v'));
    }

    debugPrint(parts.join(' '));
  }
}

class PreloadManagerState extends Equatable {
  const PreloadManagerState({
    required this.activeDownloads,
    required this.completedUrls,
    required this.activeCancelTokensCount,
  });

  final Set<String> activeDownloads;
  final Set<String> completedUrls; // URLs that completed successfully
  final int activeCancelTokensCount;

  @override
  List<Object?> get props => [
    activeDownloads,
    completedUrls,
    activeCancelTokensCount,
  ];
}
