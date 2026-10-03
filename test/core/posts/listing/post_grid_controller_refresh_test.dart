// Dart imports:
import 'dart:async';

// Package imports:
import 'package:flutter_test/flutter_test.dart';
import 'package:foundation/foundation.dart';

// Project imports:
import 'package:boorusama/core/errors/types.dart';
import 'package:boorusama/core/posts/listing/providers.dart';
import 'package:boorusama/core/posts/listing/widgets.dart';
import 'package:boorusama/core/posts/post/types.dart';

import '../../../support/fakes/test_post.dart';

void main() {
  test('a refresh requested mid-fetch replaces the stale result', () async {
    final listing = _GatedListing();
    final controller = listing.controller;

    final firstRefresh = controller.refresh();
    listing.query = 'dog';
    await controller.refresh();
    expect(listing.fetches, ['cat']);

    listing.complete(0, [TestPost(id: 1)]);
    await _settle();
    expect(listing.fetches, ['cat', 'dog']);
    expect(controller.allItems, isEmpty);
    expect(controller.refreshing, isTrue);

    listing.complete(1, [TestPost(id: 2)]);
    await firstRefresh;
    expect(controller.allItems.map((post) => post.id), [2]);
    expect(controller.refreshing, isFalse);
  });

  test('several mid-fetch refresh requests cause one extra fetch', () async {
    final listing = _GatedListing();
    final controller = listing.controller;

    final firstRefresh = controller.refresh();
    for (final query in ['dog', 'fox', 'owl']) {
      listing.query = query;
      unawaited(controller.refresh());
    }

    listing.complete(0, [TestPost(id: 1)]);
    await _settle();
    listing.complete(1, [TestPost(id: 4)]);
    await firstRefresh;

    expect(listing.fetches, ['cat', 'owl']);
    expect(controller.allItems.map((post) => post.id), [4]);
  });
}

Future<void> _settle() => Future<void>.delayed(Duration.zero);

/// A listing whose fetches stay pending until the test completes them.
final class _GatedListing {
  _GatedListing() {
    controller = PostGridController<Post>(
      fetcher: (page) {
        final completer = Completer<Either<BooruError, PostResult<Post>>>();
        fetches.add(query);
        _pending.add(completer);
        return TaskEither(() => completer.future);
      },
      blacklistedTagsFetcher: () async => const {},
      mountedChecker: () => true,
      duplicateTracker: PostDuplicateTracker(),
      onError: (_) {},
    );
    addTearDown(controller.dispose);
  }

  late final PostGridController<Post> controller;
  final fetches = <String>[];
  final _pending = <Completer<Either<BooruError, PostResult<Post>>>>[];
  var query = 'cat';

  void complete(int fetch, List<Post> posts) =>
      _pending[fetch].complete(Either.of(testPostResult(posts)));
}
