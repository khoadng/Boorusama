import 'package:test/test.dart';

import 'test_helper.dart';

void main() {
  group('id links', () {
    test('links major ids', () {
      expectDTextCases({
        'asset #1234':
            '<p><a class="dtext-link dtext-id-link dtext-media-asset-id-link" href="/media_assets/1234">asset #1234</a></p>',
        'appeal #1234':
            '<p><a class="dtext-link dtext-id-link dtext-post-appeal-id-link" href="/post_appeals/1234">appeal #1234</a></p>',
        'forum #1234':
            '<p><a class="dtext-link dtext-id-link dtext-forum-post-id-link" href="/forum_posts/1234">forum #1234</a></p>',
        'topic #1234/p4':
            '<p><a class="dtext-link dtext-id-link dtext-forum-topic-id-link" href="/forum_topics/1234?page=4">topic #1234/p4</a></p>',
        'issue #1234':
            '<p><a rel="external nofollow noreferrer" class="dtext-link dtext-id-link dtext-github-id-link" href="https://github.com/danbooru/danbooru/issues/1234">issue #1234</a></p>',
        'gelbooru #1234':
            '<p><a rel="external nofollow noreferrer" class="dtext-link dtext-id-link dtext-gelbooru-id-link" href="https://gelbooru.com/index.php?page=post&amp;s=view&amp;id=1234">gelbooru #1234</a></p>',
      });
    });
  });

  group('embeds', () {
    test('handles tag request and media embeds at block level', () {
      expect(
        parse('[ta:1]\n[ti:2]\n[bur:3]'),
        '<tag-request-embed data-type="tag-alias" data-id="1"></tag-request-embed><tag-request-embed data-type="tag-implication" data-id="2"></tag-request-embed><tag-request-embed data-type="bulk-update-request" data-id="3"></tag-request-embed>',
      );
      expect(
        parse('!post #1234\n!asset #5'),
        '<media-embed data-type="post" data-id="1234"></media-embed><media-embed data-type="asset" data-id="5"></media-embed>',
      );
      expect(
        parse('foo\n!asset #5'),
        '<p>foo</p><media-embed data-type="asset" data-id="5"></media-embed>',
      );
    });

    test('requires exact Danbooru embed syntax', () {
      expect(
        parse('!Post #1234'),
        '<p>!<a class="dtext-link dtext-id-link dtext-post-id-link" href="/posts/1234">post #1234</a></p>',
      );
      expect(
        parse(' !post #1234'),
        '<p> !<a class="dtext-link dtext-id-link dtext-post-id-link" href="/posts/1234">post #1234</a></p>',
      );
      expect(parse('!post  #1234'), '<p>!post  #1234</p>');
      expect(
        parse('!post #1234 trailing'),
        '<p>!<a class="dtext-link dtext-id-link dtext-post-id-link" href="/posts/1234">post #1234</a> trailing</p>',
      );
    });
  });
}
