// Flutter imports:
import 'package:flutter/foundation.dart';

// Package imports:
import 'package:flutter_test/flutter_test.dart';

// Project imports:
import 'package:boorusama/boorus/danbooru/application/blacklisted_tags/blacklisted_tags.dart';
import '../common.dart';

void main() {
  test('get blacklisted tags should return correct tags', () async {
    final tags = ['foo', 'bar'];
    final repo =
        BlacklistedTagsRepository(mockUserRepo(tags), fakeAccountRepo());

    final expected = await repo.getBlacklistedTags();

    expect(listEquals(expected, tags), isTrue);
  });

  test(
    'get blacklisted tags should return empty if account is empty',
    () async {
      final repo =
          BlacklistedTagsRepository(mockUserRepo(['a']), emptyAccountRepo());

      final expected = await repo.getBlacklistedTags();

      expect(listEquals(expected, []), isTrue);
    },
  );

  test('set tags should update blacklisted tag correctly', () async {
    final tags = ['foo', 'bar'];
    final newTags = [...tags, 'foobar'];

    final repo =
        BlacklistedTagsRepository(mockUserRepo(tags), fakeAccountRepo());

    final success = await repo.setBlacklistedTags(0, newTags);

    expect(success, isTrue);
    expect(listEquals(await repo.getBlacklistedTags(), newTags), isTrue);
  });
}
