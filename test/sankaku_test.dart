// Package imports:
import 'package:booru_clients/sankaku.dart';
import 'package:flutter_test/flutter_test.dart';

// Project imports:
import 'package:boorusama/boorus/sankaku/posts/parser.dart';
import 'package:boorusama/boorus/sankaku/search/tag_query_composer.dart';
import 'package:boorusama/core/configs/config/types.dart';
import 'package:boorusama/core/errors/types.dart';
import 'package:boorusama/core/http/client/types.dart';
import 'package:boorusama/core/posts/post/types.dart';

void main() {
  group('post tags', () {
    test('keeps one entry per tag with the highest post count', () {
      final tags = sankakuTagDtosToTags([
        TagDto(id: const IntId(1), tagName: 'a', type: 0, postCount: 3),
        TagDto(id: const IntId(1), tagName: 'a', type: 0, postCount: 7),
        TagDto(tagName: 'b', type: 0, postCount: 1),
        TagDto(tagName: 'b', type: 1, postCount: 2),
        TagDto(type: 0),
        TagDto(tagName: '', type: 0),
      ]);

      expect(
        tags.map((t) => (t.name, t.category.name, t.postCount)),
        [('a', 'general', 7), ('b', 'general', 1), ('b', 'artist', 2)],
      );
    });

    test('sorts each tag type into its own group on the post', () {
      final post = postDtoToPost(
        PostDto(
          id: const IntId(1),
          tags: [
            for (final (name, type) in [
              ('artist', 1),
              ('studio', 2),
              ('copyright', 3),
              ('character', 4),
              ('general', 0),
              ('genre', 5),
              ('medium', 8),
              ('meta', 9),
              ('unknown', 42),
            ])
              TagDto(tagName: name, type: type),
          ],
        ),
        PostIdGenerator(),
        null,
      );

      expect(post.artistTags, {'artist'});
      expect(post.copyrightTags, {'copyright'});
      expect(post.characterTags, {'character'});
      expect(post.generalTags, {'general'});
      expect(post.metaTags, {'meta'});
      expect(post.tags, hasLength(9));
    });
  });

  group('single date searches', () {
    final composer = SankakuTagQueryComposer(config: BooruConfig.empty.search);
    final cases = [
      (input: 'date:2024-01-05', expected: 'date:2024-01-05..2024-01-06'),
      (input: 'date:20241231', expected: 'date:2024-12-31..2025-01-01'),
      (input: 'date:2024-02-29', expected: 'date:2024-02-29..2024-03-01'),
      (input: 'date:2023-02-29', expected: 'date:2023-02-29'),
      (input: 'date:2024-1-5', expected: 'date:2024-1-5'),
      (input: 'date:>2024-01-05', expected: 'date:>2024-01-05'),
      (
        input: 'date:2024-01-05..2024-01-10',
        expected: 'date:2024-01-05..2024-01-10',
      ),
    ];

    for (final c in cases) {
      test('turns ${c.input} into ${c.expected}', () {
        expect(composer.compose([c.input]), contains(c.expected));
      });
    }
  });

  test('a rejected login shows as an authentication failure', () async {
    final result = await tryFetchRemoteData<void>(
      fetcher: () => throw const SankakuAuthenticationException('bad login'),
    ).run();

    expect(
      result.getLeft().toNullable(),
      isA<ServerError>().having((e) => e.httpStatusCode, 'status', 401),
    );
  });
}
