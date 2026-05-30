import 'package:test/test.dart';

import 'test_helper.dart';

void main() {
  group('wiki links', () {
    test('handles spacing, anchors, prefix, suffix, and pipe trick', () {
      expectDTextCases({
        'a [[b]] c':
            '<p>a <a class="dtext-link dtext-wiki-link" href="/wiki_pages/b">b</a> c</p>',
        '[[ tag ]]':
            '<p><a class="dtext-link dtext-wiki-link" href="/wiki_pages/tag">tag</a></p>',
        'the[[ tag ]]ger':
            '<p><a class="dtext-link dtext-wiki-link" href="/wiki_pages/tag">thetagger</a></p>',
        'the[[ tag|Tag ]]ger':
            '<p><a class="dtext-link dtext-wiki-link" href="/wiki_pages/tag">theTagger</a></p>',
        '[[touhou#See Also]]':
            '<p><a class="dtext-link dtext-wiki-link" href="/wiki_pages/touhou#dtext-see-also">touhou</a></p>',
        '[[foo (bar)|]]':
            '<p><a class="dtext-link dtext-wiki-link" href="/wiki_pages/foo_%28bar%29">foo</a></p>',
        '[[#compass]]':
            '<p><a class="dtext-link dtext-wiki-link" href="/wiki_pages/%23compass">#compass</a></p>',
        '[[Evo Moment #37]]':
            '<p><a class="dtext-link dtext-wiki-link" href="/wiki_pages/evo_moment_%2337">Evo Moment #37</a></p>',
      });
    });
  });

  group('post search links', () {
    test('handles prefix, suffix, aliases, and emoticon-like tags', () {
      expectDTextCases({
        '{{touhou}}':
            '<p><a class="dtext-link dtext-post-search-link" href="/posts?tags=touhou">touhou</a></p>',
        '{{touhou|Touhou}}':
            '<p><a class="dtext-link dtext-post-search-link" href="/posts?tags=touhou">Touhou</a></p>',
        'the{{ cat }}s':
            '<p><a class="dtext-link dtext-post-search-link" href="/posts?tags=cat">thecats</a></p>',
        '{{|D}}':
            '<p><a class="dtext-link dtext-post-search-link" href="/posts?tags=%7CD">|D</a></p>',
        '{{foo_(bar)|}}':
            '<p><a class="dtext-link dtext-post-search-link" href="/posts?tags=foo_%28bar%29">foo</a></p>',
      });
    });
  });
}
