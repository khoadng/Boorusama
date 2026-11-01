// Package imports:
import 'package:flutter_test/flutter_test.dart';

// Project imports:
import 'package:boorusama/core/bookmarks/src/providers/bookmark_shuffle_provider.dart';

void main() {
  const shuffle = BookmarkShuffleState(seed: 42);

  test('adding a bookmark keeps the shuffled order of the others', () {
    final before = shuffle.applyShuffleToList(
      List.generate(50, (i) => i),
      key: (id) => id,
    );
    final after = shuffle.applyShuffleToList(
      List.generate(51, (i) => i),
      key: (id) => id,
    );

    expect(after.where((id) => id != 50), before);
  });
}
