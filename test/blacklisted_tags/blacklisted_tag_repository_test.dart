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
    final repo = BlacklistedTagsRepositoryImpl(mockUserRepo(tags));

    final expected = await repo.getBlacklistedTags(1);

    expect(listEquals(expected, tags), isTrue);
  });

  test('set tags should update blacklisted tag correctly', () async {
    final tags = ['foo', 'bar'];
    final newTags = [...tags, 'foobar'];

    final repo = BlacklistedTagsRepositoryImpl(mockUserRepo(tags));

    final success = await repo.setBlacklistedTags(0, newTags);

    expect(success, isTrue);
  });
}
