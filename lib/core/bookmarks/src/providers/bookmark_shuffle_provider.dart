// Package imports:
import 'package:collection/collection.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class BookmarkShuffleState extends Equatable {
  const BookmarkShuffleState({
    this.seed,
  });

  final int? seed;

  BookmarkShuffleState copyWith({
    int? seed,
  }) {
    return BookmarkShuffleState(
      seed: seed ?? this.seed,
    );
  }

  BookmarkShuffleState withNewShuffle() {
    return BookmarkShuffleState(
      seed: DateTime.now().millisecondsSinceEpoch,
    );
  }

  BookmarkShuffleState reset() {
    return const BookmarkShuffleState();
  }

  List<T> applyShuffleToList<T>(
    List<T> items, {
    required Object Function(T item) key,
  }) => switch (seed) {
    null => items,
    final seed => items.sortedBy<num>((item) => Object.hash(seed, key(item))),
  };

  bool get shouldShowAsActive => seed != null;

  @override
  List<Object?> get props => [seed];
}

class BookmarkShuffleNotifier
    extends AutoDisposeNotifier<BookmarkShuffleState> {
  @override
  BookmarkShuffleState build() {
    return const BookmarkShuffleState();
  }

  void shuffle() {
    state = state.withNewShuffle();
  }

  void reset() {
    state = state.reset();
  }

  void resetOnUserAction() {
    if (state.seed != null) {
      reset();
    }
  }
}

final bookmarkShuffleProvider =
    AutoDisposeNotifierProvider<BookmarkShuffleNotifier, BookmarkShuffleState>(
      () => BookmarkShuffleNotifier(),
    );
