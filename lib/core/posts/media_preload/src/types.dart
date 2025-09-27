// Dart imports:
import 'dart:math' as math;

// Flutter imports:
import 'package:flutter/foundation.dart';

// Package imports:
import 'package:dio/dio.dart';
import 'package:equatable/equatable.dart';

// Project imports:
import 'preload_media.dart';

// Forward declaration to avoid circular imports
class DirectionHistoryOptions {
  const DirectionHistoryOptions({
    this.maxHistorySize = 10,
    this.decayFactor = 0.8,
    this.minWeight = 0.1,
    this.weightedHistorySize = 8,
    this.mediumConfidenceThreshold = 4,
    this.highConfidenceThreshold = 8,
  });

  final int maxHistorySize;
  final double decayFactor;
  final double minWeight;
  final int weightedHistorySize;
  final int mediumConfidenceThreshold;
  final int highConfidenceThreshold;
}

typedef Preloader =
    Future<void> Function(
      String url,
      CancelToken cancelToken,
    );

enum ScrollSpeed {
  crawling, // < 0.2 pages/sec (very deliberate reading)
  slow, // 0.2-0.5 pages/sec (careful browsing)
  normal, // 0.5-1.0 pages/sec (regular browsing)
  fast, // 1.0-2.0 pages/sec (quick scanning)
  rapid, // 2.0-5.0 pages/sec (keyboard rapid fire)
  blazing, // > 5.0 pages/sec (slideshow/automation)
}

const Map<ScrollSpeed, double> kBiasThresholds = {
  ScrollSpeed.crawling: 1.1, // easiest direction detection
  ScrollSpeed.slow: 1.2, // easier direction detection
  ScrollSpeed.normal: 1.5, // current default
  ScrollSpeed.fast: 2.0, // harder direction detection
  ScrollSpeed.rapid: 2.5, // much harder direction detection
  ScrollSpeed.blazing: 3.0, // hardest direction detection for automation
};

class PriorityCalculator {
  static const double _maxPriority = 1000;

  double calculatePriority({
    required int distance,
    required ScrollDirection direction,
    required DirectionConfidence confidence,
    required ScrollSpeed scrollSpeed,
    required int currentPage,
    required int targetPage,
  }) {
    // Start with base score (distance is primary factor)
    var score = _maxPriority * (1.0 / (1.0 + distance));

    // Apply direction factor (secondary)
    score *= _getDirectionMultiplier(direction, currentPage, targetPage);

    // Apply confidence factor (tertiary)
    score *= _getConfidenceMultiplier(confidence);

    // Apply speed adjustment (minor)
    score += _getSpeedAdjustment(scrollSpeed) * 50;

    return score.clamp(0.0, _maxPriority);
  }

  double _getDirectionMultiplier(
    ScrollDirection direction,
    int current,
    int target,
  ) {
    final isForward = target > current;
    return switch ((direction, isForward)) {
      (ScrollDirection.forward, true) => 1.0, // Perfect alignment
      (ScrollDirection.backward, false) => 1.0, // Perfect alignment
      (ScrollDirection.forward, false) => 0.3, // Against direction
      (ScrollDirection.backward, true) => 0.3, // Against direction
      (ScrollDirection.bidirectional, _) => 0.7, // No clear direction
    };
  }

  double _getConfidenceMultiplier(DirectionConfidence confidence) {
    return switch (confidence) {
      DirectionConfidence.high => 1.0,
      DirectionConfidence.medium => 0.9,
      DirectionConfidence.low => 0.8,
    };
  }

  double _getSpeedAdjustment(ScrollSpeed speed) {
    // Fast scrolling = prioritize further ahead
    // Slow scrolling = prioritize nearby
    return switch (speed) {
      ScrollSpeed.crawling => -1.0, // heavily prioritize immediate vicinity
      ScrollSpeed.slow => -0.5, // prioritize nearby
      ScrollSpeed.normal => 0.0, // neutral
      ScrollSpeed.fast => 0.5, // prioritize further ahead
      ScrollSpeed.rapid => 1.0, // heavily prioritize further ahead
      ScrollSpeed.blazing => 1.5, // extremely prioritize further ahead
    };
  }
}

@immutable
class PrioritizedUrl implements Comparable<PrioritizedUrl> {
  const PrioritizedUrl({
    required this.url,
    required this.priority,
    required this.distance,
    required this.relevanceZone,
  });

  final String url;
  final double priority; // Higher values = higher priority
  final int distance; // Distance from current page
  final RelevanceZone relevanceZone;

  @override
  int compareTo(PrioritizedUrl other) {
    // Higher priority comes first (reverse order for max-heap behavior)
    return other.priority.compareTo(priority);
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PrioritizedUrl &&
          runtimeType == other.runtimeType &&
          url == other.url;

  @override
  int get hashCode => url.hashCode;

  @override
  String toString() =>
      'PrioritizedUrl(url: ${url.split('/').last}, priority: $priority, distance: $distance, zone: ${relevanceZone.name})';
}

class DownloadConfiguration {
  const DownloadConfiguration({
    this.maxConcurrentDownloads = 2,
    this.relevanceZones = const RelevanceZones(),
  });

  final int maxConcurrentDownloads;
  final RelevanceZones relevanceZones;
}

class RelevanceZones {
  const RelevanceZones({
    this.immediateDistance = 1,
    this.nearbyDistance = 2,
    this.distantDistance = 4,
  });

  /// URLs within this distance are considered immediately relevant (never cancel)
  final int immediateDistance;

  /// URLs within this distance are considered nearby (cancel only if necessary)
  final int nearbyDistance;

  /// URLs beyond this distance are considered distant (cancel aggressively)
  final int distantDistance;

  RelevanceZone getZone(int distance) => switch (distance) {
    final d when d <= immediateDistance => RelevanceZone.immediate,
    final d when d <= nearbyDistance => RelevanceZone.nearby,
    final d when d <= distantDistance => RelevanceZone.distant,
    _ => RelevanceZone.irrelevant,
  };
}

enum RelevanceZone {
  immediate, // Never cancel
  nearby, // Cancel only if needed for immediate downloads
  distant, // Cancel aggressively
  irrelevant, // Cancel immediately
}

class PreloadContext {
  const PreloadContext({
    required this.currentPage,
    required this.itemCount,
    required this.mediaBuilder,
    required this.activeDownloads,
    required this.completedUrls,
  });

  final int currentPage;
  final int itemCount;
  final PreloadMedia? Function(int index) mediaBuilder;
  final Set<String> activeDownloads;
  final Set<String> completedUrls;

  /// Calculate distance from current page to target index
  int distanceFrom(int targetIndex) => (targetIndex - currentPage).abs();

  /// Check if an index is valid within bounds
  bool isValidIndex(int index) => index >= 0 && index < itemCount;

  /// Get the relevance zone for a target index
  RelevanceZone getRelevanceZone(int targetIndex) {
    final distance = distanceFrom(targetIndex);
    return const RelevanceZones().getZone(distance);
  }

  /// Build a map of URL to index for efficient lookup
  Map<String, int> buildUrlIndexMap() {
    final urlIndexMap = <String, int>{};
    for (var i = 0; i < itemCount; i++) {
      final urls = mediaBuilder(i)?.allUrls ?? <String>[];

      for (final url in urls) {
        urlIndexMap[url] = i;
      }
    }
    return urlIndexMap;
  }

  /// Safely get media at index, returns null if index is invalid
  PreloadMedia? getMediaItemAt(int index) =>
      isValidIndex(index) ? mediaBuilder(index) : null;
}

class PreloadResult extends Equatable {
  const PreloadResult({
    required this.prioritizedUrls,
    this.skipUrls = const {},
    this.cancelUrls = const {},
  });

  const PreloadResult.empty()
    : prioritizedUrls = const [],
      skipUrls = const {},
      cancelUrls = const {};

  final List<PrioritizedUrl> prioritizedUrls;
  final Set<String> skipUrls;
  final Set<String> cancelUrls;

  /// Get all URLs from prioritized format
  List<String> get allUrls => prioritizedUrls.map((p) => p.url).toList();

  @override
  List<Object?> get props => [prioritizedUrls, skipUrls, cancelUrls];
}

enum ScrollDirection {
  forward,
  backward,
  bidirectional;

  static ScrollDirection fromDirectionHistory(
    List<int> directionHistory,
    DirectionHistoryOptions options, {
    ScrollSpeed? scrollSpeed,
  }) {
    if (directionHistory.isEmpty) return ScrollDirection.bidirectional;

    final biasThreshold = kBiasThresholds[scrollSpeed ?? ScrollSpeed.normal]!;

    final (forwardWeight, backwardWeight) = _calculateWeightedCounts(
      directionHistory,
      options,
    );

    // Require significant bias to be directional
    return switch ((forwardWeight, backwardWeight)) {
      (final forward, final backward) when forward > backward * biasThreshold =>
        ScrollDirection.forward,
      (final forward, final backward) when backward > forward * biasThreshold =>
        ScrollDirection.backward,
      _ => ScrollDirection.bidirectional,
    };
  }

  static (double, double) _calculateWeightedCounts(
    List<int> directionHistory,
    DirectionHistoryOptions options,
  ) {
    var forwardWeight = 0.0;
    var backwardWeight = 0.0;

    final historySize = math.min(
      directionHistory.length,
      options.weightedHistorySize,
    );

    for (var i = 0; i < historySize; i++) {
      final direction = directionHistory[directionHistory.length - 1 - i];
      final weight = math.pow(options.decayFactor, i).toDouble();

      if (weight < options.minWeight) break;

      if (direction > 0) {
        forwardWeight += weight;
      } else if (direction < 0) {
        backwardWeight += weight;
      }
    }

    return (forwardWeight, backwardWeight);
  }
}

enum EntryPattern {
  direct, // No movement history - user just opened
  initial, // Single move - still determining intent
  sequential, // Consistent direction - came from sequential browsing
  exploring, // Mixed movement - user is exploring/searching
}

enum DirectionConfidence {
  low,
  medium,
  high;

  static DirectionConfidence fromConsecutiveCount(
    int count,
    DirectionHistoryOptions options, {
    ScrollSpeed? scrollSpeed,
  }) {
    return switch (count) {
      final c when c >= options.highConfidenceThreshold =>
        DirectionConfidence.high,
      final c when c >= options.mediumConfidenceThreshold =>
        DirectionConfidence.medium,
      _ => DirectionConfidence.low,
    };
  }

  static DirectionConfidence fromDirectionHistory(
    List<int> directionHistory,
    ScrollDirection direction,
    DirectionHistoryOptions options, {
    ScrollSpeed? scrollSpeed,
  }) {
    if (directionHistory.length < 2) return DirectionConfidence.low;
    if (direction == ScrollDirection.bidirectional) {
      return DirectionConfidence.low;
    }

    final confidenceScore = _calculateWeightedConfidence(
      directionHistory,
      direction,
      options,
    );

    return switch (confidenceScore) {
      final score when score >= options.highConfidenceThreshold =>
        DirectionConfidence.high,
      final score when score >= options.mediumConfidenceThreshold =>
        DirectionConfidence.medium,
      _ => DirectionConfidence.low,
    };
  }

  static double _calculateWeightedConfidence(
    List<int> directionHistory,
    ScrollDirection direction,
    DirectionHistoryOptions options,
  ) {
    final targetDirection = switch (direction) {
      ScrollDirection.forward => 1,
      ScrollDirection.backward => -1,
      ScrollDirection.bidirectional => 0,
    };

    var weightedScore = 0.0;
    final historySize = math.min(
      directionHistory.length,
      options.weightedHistorySize,
    );

    for (var i = 0; i < historySize; i++) {
      final direction = directionHistory[directionHistory.length - 1 - i];
      final weight = math.pow(options.decayFactor, i).toDouble();

      if (weight < options.minWeight) break;

      if (direction == targetDirection) {
        weightedScore += weight;
      } else {
        // Penalize opposite direction movements more heavily for recent moves
        weightedScore -= weight * 0.5;
      }
    }

    return math.max(0, weightedScore);
  }
}
