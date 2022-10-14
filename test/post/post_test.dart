// Package imports:
import 'package:test/test.dart';

// Project imports:
import 'package:boorusama/boorus/danbooru/domain/posts/posts.dart';

void main() {
  test('video test [mp4, webm, zip]', () {
    final posts = ['mp4', 'webm', 'zip']
        .map((e) => Post.empty().copyWith(format: e))
        .toList();

    expect(posts.every((post) => post.isVideo), isTrue);
  });
}
