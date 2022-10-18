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

  group('[vote test]', () {
    test('total vote', () {
      final post = Post.empty().copyWith(
        upScore: 10,
        downScore: -5,
      );

      expect(post.totalVote, equals(15));
    });

    test('have voters', () {
      final posts = [
        [1, 0],
        [0, -1],
        [5, -10],
      ]
          .map((e) => Post.empty().copyWith(
                upScore: e[0],
                downScore: e[1],
              ))
          .toList();

      expect(posts.every((post) => post.hasVoter), isTrue);
    });

    test("doesn't have voters", () {
      final posts = [
        [0, 0],
      ]
          .map((e) => Post.empty().copyWith(
                upScore: e[0],
                downScore: e[1],
              ))
          .toList();

      expect(posts.every((post) => post.hasVoter), isFalse);
    });

    test('upvote percent should be 100% when there is not vote yet', () {
      final post = Post.empty().copyWith(
        upScore: 0,
        downScore: 0,
      );

      expect(post.upvotePercent, equals(1));
    });

    test('upvote percent 0.5', () {
      final post = Post.empty().copyWith(
        upScore: 10,
        downScore: -10,
      );

      expect(post.upvotePercent, equals(0.5));
    });
  });

  group('favorite test', () {
    test('have favorites', () {
      final posts = [1, 2, 3]
          .map((e) => Post.empty().copyWith(
                favCount: e,
              ))
          .toList();

      expect(posts.every((post) => post.hasFavorite), isTrue);
    });

    test("doesn't have favorites", () {
      final posts = [-1, 0]
          .map((e) => Post.empty().copyWith(
                favCount: e,
              ))
          .toList();

      expect(posts.every((post) => post.hasFavorite), isFalse);
    });
  });

  group('parent child', () {
    test('has both parent and child', () {
      final post = Post.empty().copyWith(
        hasChildren: true,
        hasParent: true,
      );

      expect(post.hasBothParentAndChildren, isTrue);
    });

    test('has parent or child', () {
      final posts = [
        [true, false],
        [false, true]
      ]
          .map((e) => Post.empty().copyWith(
                hasChildren: e[0],
                hasParent: e[1],
              ))
          .toList();

      expect(posts.every((post) => post.hasParentOrChildren), isTrue);
    });

    test('have no parent and child', () {
      final post = Post.empty().copyWith(
        hasChildren: false,
        hasParent: false,
      );

      expect(post.hasParentOrChildren, isFalse);
    });
  });

  group('[source]', () {
    test('pixiv', () {
      final post = Post.empty().copyWith(pixivId: 1, source: 'foo');
      expect(post.source, '${pixivLinkUrl}1');
    });

    test('other', () {
      final post = Post.empty().copyWith(source: 'foo');
      expect(post.source, 'foo');
    });
  });
}
