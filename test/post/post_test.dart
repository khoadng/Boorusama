// Package imports:
import 'package:test/test.dart';

// Project imports:
import 'package:boorusama/boorus/danbooru/domain/posts/posts.dart';

const videoFormat = [
  'mp4',
  'webm',
  'zip',
];

const animatedFormat = [
  ...videoFormat,
  'gif',
];

const imageFormat = [
  'png',
  'jpg',
];

const randomFormat = [
  'foo',
  'bar',
];

void main() {
  group('[video test]', () {
    test(videoFormat.join(', '), () {
      final posts =
          videoFormat.map((e) => Post.empty().copyWith(format: e)).toList();

      expect(posts.every((post) => post.isVideo), isTrue);
    });

    test(imageFormat.join(', '), () {
      final posts =
          imageFormat.map((e) => Post.empty().copyWith(format: e)).toList();

      expect(posts.every((post) => post.isVideo), isFalse);
    });

    test(randomFormat.join(', '), () {
      final posts =
          imageFormat.map((e) => Post.empty().copyWith(format: e)).toList();

      expect(posts.every((post) => post.isVideo), isFalse);
    });
  });

  group('[animated test]', () {
    test(animatedFormat.join(', '), () {
      final posts =
          animatedFormat.map((e) => Post.empty().copyWith(format: e)).toList();

      expect(posts.every((post) => post.isAnimated), isTrue);
    });

    test(imageFormat.join(', '), () {
      final posts =
          imageFormat.map((e) => Post.empty().copyWith(format: e)).toList();

      expect(posts.every((post) => post.isAnimated), isFalse);
    });

    test(randomFormat.join(', '), () {
      final posts =
          imageFormat.map((e) => Post.empty().copyWith(format: e)).toList();

      expect(posts.every((post) => post.isAnimated), isFalse);
    });
  });

  group('[translated test]', () {
    test('translated', () {
      final post = Post.empty().copyWith(tags: ['translated']);

      expect(post.isTranslated, isTrue);
    });

    test('not translated', () {
      final post = Post.empty().copyWith(tags: []);

      expect(post.isTranslated, isFalse);
    });
  });

  group('[comment test]', () {
    test('has comment', () {
      final post = Post.empty().copyWith(lastCommentAt: DateTime.now());

      expect(post.hasComment, isTrue);
    });

    test("doesn't have comments", () {
      final post = Post.empty();

      expect(post.hasComment, isFalse);
    });
  });

  group('[download url]', () {
    test('video format should use normal image url', () {
      final posts = [...videoFormat].map((e) => Post.empty().copyWith(
            format: e,
            normalImageUrl: 'foo',
            fullImageUrl: 'bar',
          ));

      expect(
        posts.every((post) => post.downloadUrl == post.normalImageUrl),
        isTrue,
      );
    });

    test('non video format should use full image url', () {
      final posts = [...imageFormat, 'gif'].map((e) => Post.empty().copyWith(
            format: e,
            normalImageUrl: 'foo',
            fullImageUrl: 'bar',
          ));

      expect(
        posts.every((post) => post.downloadUrl == post.fullImageUrl),
        isTrue,
      );
    });
  });
}
