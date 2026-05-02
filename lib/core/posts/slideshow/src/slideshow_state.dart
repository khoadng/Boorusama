// Project imports:
import 'slideshow_direction.dart';
import 'slideshow_options.dart';
sealed class SlideshowState {
  const SlideshowState();

  const factory SlideshowState.idle() = SlideshowIdle;

  factory SlideshowState.running({
    required int currentPage,
    required int totalPages,
    required SlideshowDirection direction,
    List<int>? randomSequence,
    int randomIndex,
  }) = SlideshowRunning;

  const factory SlideshowState.paused({
    required int currentPage,
    required int totalPages,
    List<int>? randomSequence,
    int randomIndex,
  }) = SlideshowPaused;

  bool get isRunning => switch (this) {
    SlideshowRunning() => true,
    _ => false,
  };

  bool get isPaused => switch (this) {
    SlideshowPaused() => true,
    _ => false,
  };

  bool get isIdle => switch (this) {
    SlideshowIdle() => true,
    _ => false,
  };

  int get currentPage => switch (this) {
    SlideshowRunning(:final currentPage) => currentPage,
    SlideshowPaused(:final currentPage) => currentPage,
    _ => 0,
  };

  SlideshowState withUpdatedTotalPages(int newTotalPages) => switch (this) {
    // ignore: prefer_final_locals
    SlideshowRunning s=> s._withUpdatedTotalPages(newTotalPages),
    // ignore: prefer_final_locals
    SlideshowPaused s => s._withUpdatedTotalPages(newTotalPages),
    SlideshowIdle() => this,
  };

  /// Common adjustment logic for [SlideshowRunning] and [SlideshowPaused].
  static ({
    int currentPage,
    List<int>? randomSequence,
    int randomIndex,
  }) _adjustForTotalPagesChange({
    required int oldTotalPages,
    required int newTotalPages,
    required int currentPage,
    List<int>? randomSequence,
    required int randomIndex,
  }) {

    // Clamp current page to new bounds
    final newCurrentPage = currentPage >= newTotalPages
        ? newTotalPages - 1
        : currentPage;

    var newSequence = randomSequence;

    if (randomSequence != null) {
      if (newTotalPages > oldTotalPages) {
        // Append newly added pages shuffled
        final newPages = List.generate(
          newTotalPages - oldTotalPages,
          (i) => oldTotalPages + i,
        )..shuffle();
        newSequence = [...randomSequence, ...newPages];
      } else if (newTotalPages < oldTotalPages) {
        // Remove any pages beyond the new total
        newSequence = randomSequence.where((p) => p < newTotalPages).toList();
      }
    }

    var newRandomIndex = randomIndex;
    if (newSequence != null && randomIndex >= newSequence.length) {
      newRandomIndex = newSequence.length - 1;
    }

    return (
      currentPage: newCurrentPage,
      randomSequence: newSequence,
      randomIndex: newRandomIndex,
    );
  }
}

final class SlideshowIdle extends SlideshowState {
  const SlideshowIdle();
}

final class SlideshowRunning extends SlideshowState {
  SlideshowRunning({
    required this.currentPage,
    required this.totalPages,
    required this.direction,
    this.randomSequence,
    this.randomIndex = 0,
  });

  factory SlideshowRunning.initial({
    required int startPage,
    required int totalPages,
    required SlideshowDirection direction,
  }) {
    final sequence = direction == SlideshowDirection.random
        ? _generateRandomSequence(totalPages)
        : null;

    final randomIndex = sequence?.indexOf(startPage) ?? 0;

    return SlideshowRunning(
      currentPage: startPage,
      totalPages: totalPages,
      direction: direction,
      randomSequence: sequence,
      randomIndex: randomIndex != -1 ? randomIndex : 0,
    );
  }

  @override
  final int currentPage;
  final int totalPages;
  final SlideshowDirection direction;
  final List<int>? randomSequence;
  final int randomIndex;

  static List<int> _generateRandomSequence(int totalPages) {
    final pages = List.generate(totalPages, (index) => index)..shuffle();
    return pages;
  }

  SlideshowRunning advance() {
    final nextPage = _calculateNextPage();
    final newRandomIndex = direction == SlideshowDirection.random
        ? (randomIndex + 1) % (randomSequence?.length ?? 1)
        : randomIndex;

    return copyWith(
      currentPage: nextPage,
      randomIndex: newRandomIndex,
    );
  }

  int _calculateNextPage() {
    return switch (direction) {
      SlideshowDirection.forward => (currentPage + 1) % totalPages,
      SlideshowDirection.backward => (currentPage - 1 + totalPages) % totalPages,
      SlideshowDirection.random => _calculateRandomNextPage(),
    };
  }

  int _calculateRandomNextPage() {
    final sequence = randomSequence;
    if (sequence == null) return currentPage;

    final nextIndex = (randomIndex + 1) % sequence.length;
    return sequence[nextIndex];
  }

  bool shouldSkipAnimation(SlideshowOptions options) {
    // Always skip animation in random mode to avoid page-flipping effect
    if (direction == SlideshowDirection.random) return true;

    // Skip animation for duration less than 1 second
    if (options.duration.inSeconds < 1) return true;

    return options.skipTransition;
  }

  SlideshowPaused pause() {
    return SlideshowPaused(
      currentPage: currentPage,
      totalPages: totalPages,
      randomSequence: randomSequence,
      randomIndex: randomIndex,
    );
  }

  SlideshowRunning copyWith({
    int? currentPage,
    int? totalPages,
    SlideshowDirection? direction,
    List<int>? randomSequence,
    int? randomIndex,
  }) {
    return SlideshowRunning(
      currentPage: currentPage ?? this.currentPage,
      totalPages: totalPages ?? this.totalPages,
      direction: direction ?? this.direction,
      randomSequence: randomSequence ?? this.randomSequence,
      randomIndex: randomIndex ?? this.randomIndex,
    );
  }

  SlideshowRunning _withUpdatedTotalPages(int newTotalPages) {
    final adjusted = SlideshowState._adjustForTotalPagesChange(
      oldTotalPages: totalPages,
      newTotalPages: newTotalPages,
      currentPage: currentPage,
      randomSequence: randomSequence,
      randomIndex: randomIndex,
    );

    return copyWith(
      currentPage: adjusted.currentPage,
      totalPages: newTotalPages,
      randomSequence: adjusted.randomSequence,
      randomIndex: adjusted.randomIndex,
    );
  }
}

final class SlideshowPaused extends SlideshowState {
  const SlideshowPaused({
    required this.currentPage,
    required this.totalPages,
    this.randomSequence,
    this.randomIndex = 0,
  });

  @override
  final int currentPage;
  final int totalPages;
  final List<int>? randomSequence;
  final int randomIndex;

  SlideshowRunning resume(SlideshowDirection direction) {
    return SlideshowRunning(
      currentPage: currentPage,
      totalPages: totalPages,
      direction: direction,
      randomSequence: randomSequence,
      randomIndex: randomIndex,
    );
  }

  SlideshowPaused copyWith({
    int? currentPage,
    int? totalPages,
    List<int>? randomSequence,
    int? randomIndex,
  }) {
    return SlideshowPaused(
      currentPage: currentPage ?? this.currentPage,
      totalPages: totalPages ?? this.totalPages,
      randomSequence: randomSequence ?? this.randomSequence,
      randomIndex: randomIndex ?? this.randomIndex,
    );
  }

  SlideshowPaused _withUpdatedTotalPages(int newTotalPages) {
    final adjusted = SlideshowState._adjustForTotalPagesChange(
      oldTotalPages: totalPages,
      newTotalPages: newTotalPages,
      currentPage: currentPage,
      randomSequence: randomSequence,
      randomIndex: randomIndex,
    );

    return copyWith(
      currentPage: adjusted.currentPage,
      totalPages: newTotalPages,
      randomSequence: adjusted.randomSequence,
      randomIndex: adjusted.randomIndex,
    );
  }
}
