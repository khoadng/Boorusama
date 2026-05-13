import '../ast.dart';
import '../url_normalizer.dart';

import 'context.dart';

mixin DTextLinkParser on DTextParserContext {
  @override
  bool parseWikiLink() {
    final match = scanner.matchGroups(
      RegExp(r'([A-Za-z0-9]*)\[\[([^\]\n]+)\]\]([A-Za-z0-9]*)'),
    );
    if (match == null) return false;

    final prefix = match.group(1)!;
    final body = match.group(2)!.trim();
    final suffix = match.group(3)!;
    if (body.isEmpty || body.contains('\n')) return false;

    scanner.advance(match.group(0)!.length);
    final parts = body.split('|');
    final targetWithAnchor = parts.first.trim();
    final titleSource = parts.length > 1
        ? parts.sublist(1).join('|').trim()
        : null;
    final anchorIndex = wikiAnchorIndex(targetWithAnchor);
    final target = anchorIndex == null
        ? targetWithAnchor.trim()
        : targetWithAnchor.substring(0, anchorIndex).trim();
    final anchor = anchorIndex == null
        ? null
        : targetWithAnchor.substring(anchorIndex + 1).trim();
    final normalizedTarget = normalizeWikiPage(target);
    var title = titleSource == null || titleSource.isEmpty
        ? applyPipeTrick(target)
        : titleSource;

    if (title.isEmpty) title = target;
    title = '$prefix$title$suffix';

    final href = StringBuffer(
      '${renderer.relativeUrl('/wiki_pages/')}${renderer.uriEscape(normalizedTarget)}',
    );
    if (anchor != null && anchor.isNotEmpty) {
      href
        ..write('#')
        ..write(normalizeAnchor(anchor));
    }
    renderer.addLink(
      href: href.toString(),
      children: [DTextText(title)],
      classes: const ['dtext-link', 'dtext-wiki-link'],
      kind: DTextLinkKind.wiki,
    );
    wikiPages.add(target);
    return true;
  }

  @override
  bool parsePostSearchLink() {
    final match = scanner.matchGroups(
      RegExp(r'([A-Za-z0-9]*)\{\{([^\}\n]+)\}\}([A-Za-z0-9]*)'),
    );
    if (match == null) return false;

    final prefix = match.group(1)!;
    final body = match.group(2)!.trim();
    final suffix = match.group(3)!;
    if (body.isEmpty || body.contains('\n')) return false;

    scanner.advance(match.group(0)!.length);
    final separator = body.startsWith('|')
        ? body.indexOf('|', 1)
        : body.indexOf('|');
    final search = separator < 0 ? body : body.substring(0, separator).trim();
    final title = separator < 0 ? search : body.substring(separator + 1).trim();
    final normalizedTitle =
        '$prefix${title.isEmpty ? applyPipeTrick(search) : title}$suffix';

    renderer.addLink(
      href:
          '${renderer.relativeUrl('/posts?tags=')}${renderer.uriEscape(search)}',
      children: [DTextText(normalizedTitle)],
      classes: const ['dtext-link', 'dtext-post-search-link'],
      kind: DTextLinkKind.postSearch,
    );
    return true;
  }

  @override
  bool parseNamedLink() {
    final textile = scanner.matchGroups(
      RegExp(r'"([^"\n]+)":\[?([^\]\s\n]+)\]?'),
    );
    if (textile != null) {
      final full = textile.group(0)!;
      final title = textile.group(1)!;
      final url = textile.group(2)!;
      if (isUrlLike(url)) {
        scanner.advance(full.length);
        writeNamedUrl(normalizeHref(url), title);
        return true;
      }
    }

    if (scanner.startsWith('[/')) return false;
    final markdown = scanner.matchGroups(
      RegExp(r'\[([^\]\n]+)\]\(([^\)\n]+)\)'),
    );
    if (markdown == null) return false;

    final first = markdown.group(1)!;
    final second = markdown.group(2)!;
    final firstIsUrl = isUrlLike(first);
    final secondIsUrl = isUrlLike(second);
    if (!firstIsUrl && !secondIsUrl) return false;

    scanner.advance(markdown.group(0)!.length);
    if (firstIsUrl) {
      writeNamedUrl(normalizeHref(first), second);
    } else {
      writeNamedUrl(normalizeHref(second), first);
    }
    return true;
  }

  @override
  bool parseHtmlLink() {
    final match = scanner.matchGroups(
      RegExp(
        r'''<a\s+[^>]*href\s*=\s*(["'])(.*?)\1[^>]*>([\s\S]*?)</a>''',
        caseSensitive: false,
      ),
    );
    if (match == null) return false;

    final url = normalizeHref(match.group(2)!.trim());
    final title = match.group(3)!;
    if (!isUrlLike(url) || title.isEmpty) return false;

    scanner.advance(match.group(0)!.length);
    writeNamedUrl(url, title);
    return true;
  }

  @override
  bool parseBbcodeLink() {
    final explicit = scanner.matchGroups(
      RegExp(
        r'''\[url\s*=\s*(?:"([^"\]\n]+)"|'([^'\]\n]+)'|([^\]\s\n]+))\s*\]''',
        caseSensitive: false,
      ),
    );
    if (explicit != null) {
      final url = normalizeHref(
        (explicit.group(1) ?? explicit.group(2) ?? explicit.group(3)!).trim(),
      );
      if (!isUrlLike(url)) return false;

      final start = scanner.offset;
      scanner.advance(explicit.group(0)!.length);
      final title = scanner.readUntil('[/url]', caseSensitive: false);
      if (!scanner.startsWith('[/url]', caseSensitive: false)) {
        scanner.offset = start;
        return false;
      }
      scanner.advance(6);
      final trimmedTitle = title.trim();
      if (trimmedTitle.isEmpty) {
        scanner.offset = start;
        return false;
      }

      writeNamedUrl(url, trimmedTitle);
      return true;
    }

    final implicit = scanner.match(RegExp(r'\[url\]', caseSensitive: false));
    if (implicit == null) return false;

    final start = scanner.offset;
    scanner.advance(implicit.length);
    final url = scanner.readUntil('[/url]', caseSensitive: false).trim();
    if (!scanner.startsWith('[/url]', caseSensitive: false)) {
      scanner.offset = start;
      return false;
    }
    scanner.advance(6);
    if (!isUrlLike(url)) {
      scanner.offset = start;
      return false;
    }

    writeUnnamedUrl(normalizeHref(url));
    return true;
  }

  @override
  bool parseIdLink() {
    final idLinks = <String, (String, String, String)>{
      'post': ('post', 'post', '/posts/'),
      'asset': ('asset', 'media-asset', '/media_assets/'),
      'media asset': ('asset', 'media-asset', '/media_assets/'),
      'appeal': ('appeal', 'post-appeal', '/post_appeals/'),
      'flag': ('flag', 'post-flag', '/post_flags/'),
      'note': ('note', 'note', '/notes/'),
      'forum': ('forum', 'forum-post', '/forum_posts/'),
      'topic': ('topic', 'forum-topic', '/forum_topics/'),
      'comment': ('comment', 'comment', '/comments/'),
      'dmail': ('dmail', 'dmail', '/dmails/'),
      'pool': ('pool', 'pool', '/pools/'),
      'user': ('user', 'user', '/users/'),
      'artist': ('artist', 'artist', '/artists/'),
      'ban': ('ban', 'ban', '/bans/'),
      'alias': ('alias', 'tag-alias', '/tag_aliases/'),
      'implication': ('implication', 'tag-implication', '/tag_implications/'),
      'favgroup': ('favgroup', 'favorite-group', '/favorite_groups/'),
      'mod action': ('mod action', 'mod-action', '/mod_actions/'),
      'modreport': ('modreport', 'moderation-report', '/moderation_reports/'),
      'feedback': ('feedback', 'user-feedback', '/user_feedbacks/'),
      'wiki': ('wiki', 'wiki-page', '/wiki_pages/'),
      'issue': (
        'issue',
        'github',
        'https://github.com/danbooru/danbooru/issues/',
      ),
      'pull': (
        'pull',
        'github-pull',
        'https://github.com/danbooru/danbooru/pull/',
      ),
      'commit': (
        'commit',
        'github-commit',
        'https://github.com/danbooru/danbooru/commit/',
      ),
      'pixiv': ('pixiv', 'pixiv', 'https://www.pixiv.net/artworks/'),
      'twitter': ('twitter', 'twitter', 'https://twitter.com/i/web/status/'),
      'gelbooru': (
        'gelbooru',
        'gelbooru',
        'https://gelbooru.com/index.php?page=post&s=view&id=',
      ),
    };

    for (final entry in idLinks.entries) {
      final pattern = RegExp(
        '${RegExp.escape(entry.key)} #(\\d+)(?:/p(\\d+))?',
        caseSensitive: false,
      );
      final match = scanner.matchGroups(pattern);
      if (match == null) continue;

      scanner.advance(match.group(0)!.length);
      final id = match.group(1)!;
      final page = match.group(2);
      if (entry.key == 'topic' && page != null) {
        writePagedLink(
          'topic #',
          id,
          '/forum_topics/',
          '?page=',
          page,
          'forum-topic',
        );
      } else if (entry.key == 'pixiv' && page != null) {
        writePagedLink(
          'pixiv #',
          id,
          'https://www.pixiv.net/artworks/',
          '#',
          page,
          'pixiv',
        );
      } else {
        writeIdLink(entry.value.$1, entry.value.$2, entry.value.$3, id);
      }
      return true;
    }

    return false;
  }

  @override
  bool parseRawUrl() {
    if (!isUrlBoundary(scanner.offset - 1)) return false;

    final match = scanner.match(
      RegExp(r'(?:https?://|mailto:)[^\s<>\[\]]+', caseSensitive: false),
    );
    if (match == null) return false;

    final (url, leftovers) = trimUrl(match);
    if (!isValidUrl(url)) return false;

    scanner.advance(match.length);
    writeUnnamedUrl(url);
    renderer.writeEscaped(leftovers);
    return true;
  }

  @override
  bool parseDelimitedUrl() {
    final match = scanner.matchGroups(
      RegExp(r'<((?:https?://|mailto:)[^<>\s]+)>', caseSensitive: false),
    );
    if (match == null) return false;

    final url = match.group(1)!;
    if (!isValidUrl(url)) return false;

    scanner.advance(match.group(0)!.length);
    writeUnnamedUrl(url);
    return true;
  }

  @override
  void writeNamedUrl(String url, String title) {
    final normalizedUrl = normalizeHref(url);
    if (title.trim() == normalizedUrl) {
      writeUnnamedUrl(normalizedUrl);
      return;
    }

    final parsedTitle = childParser(title).parseBasicInlineToNodes();
    final internal = isInternalUrl(normalizedUrl, options.domain);

    if (normalizedUrl.startsWith('/') || normalizedUrl.startsWith('#')) {
      renderer.addLink(
        href: renderer.relativeUrl(normalizedUrl),
        children: parsedTitle,
        classes: const ['dtext-link'],
      );
    } else if (internal) {
      renderer.addLink(
        href: normalizedUrl,
        children: parsedTitle,
        classes: const ['dtext-link'],
      );
    } else {
      renderer.addLink(
        href: normalizedUrl,
        children: parsedTitle,
        classes: const [
          'dtext-link',
          'dtext-external-link',
          'dtext-named-external-link',
        ],
        rel: 'external nofollow noreferrer',
      );
    }
  }

  @override
  void writeUnnamedUrl(String url) {
    final normalizedUrl = normalizeHref(url);
    if (writeInternalShortLink(normalizedUrl)) return;

    final internal = isInternalUrl(normalizedUrl, options.domain);
    final isMailto = normalizedUrl.toLowerCase().startsWith('mailto:');
    renderer.addLink(
      href: normalizedUrl,
      children: [
        DTextText(isMailto ? normalizedUrl.substring(7) : normalizedUrl),
      ],
      classes: internal
          ? const ['dtext-link']
          : [
              'dtext-link',
              'dtext-external-link',
              if (isMailto) 'dtext-named-external-link',
            ],
      rel: internal ? null : 'external nofollow noreferrer',
    );
  }

  @override
  bool writeInternalShortLink(String url) {
    final uri = Uri.tryParse(url);
    final host = uri?.host.toLowerCase();
    if (uri == null ||
        host == null ||
        !options.internalDomains
            .map((domain) => domain.toLowerCase())
            .contains(
              host,
            )) {
      return false;
    }

    final segments = uri.pathSegments;
    if (segments.length != 2 || uri.fragment.isNotEmpty) return false;
    if (uri.query.isNotEmpty && segments[0] != 'posts') return false;

    final id = segments[1];
    if (RegExp(r'^\d+$').hasMatch(id)) {
      final links = <String, (String, String, String)>{
        'posts': ('post', 'post', '/posts/'),
        'pools': ('pool', 'pool', '/pools/'),
        'comments': ('comment', 'comment', '/comments/'),
        'forum_posts': ('forum', 'forum-post', '/forum_posts/'),
        'forum_topics': ('topic', 'forum-topic', '/forum_topics/'),
        'users': ('user', 'user', '/users/'),
        'artists': ('artist', 'artist', '/artists/'),
        'notes': ('note', 'note', '/notes/'),
        'favorite_groups': (
          'favgroup',
          'favorite-group',
          '/favorite_groups/',
        ),
        'wiki_pages': ('wiki', 'wiki-page', '/wiki_pages/'),
      };
      final link = links[segments[0]];
      if (link == null) return false;

      writeIdLink(link.$1, link.$2, link.$3, id);
      return true;
    }

    if (segments[0] == 'wiki_pages' && uri.query.isEmpty) {
      final title = Uri.decodeComponent(id);
      renderer.addLink(
        href:
            '${renderer.relativeUrl('/wiki_pages/')}${renderer.uriEscape(id)}',
        children: [DTextText(title)],
        classes: const ['dtext-link', 'dtext-wiki-link'],
        kind: DTextLinkKind.wiki,
      );
      wikiPages.add(title);
      return true;
    }

    return false;
  }

  @override
  void writeIdLink(String title, String className, String url, String id) {
    final external = !url.startsWith('/');
    renderer.addLink(
      href:
          '${external ? url : renderer.relativeUrl(url)}${renderer.uriEscape(id)}',
      children: [DTextText('$title #$id')],
      classes: ['dtext-link', 'dtext-id-link', 'dtext-$className-id-link'],
      kind: DTextLinkKind.id,
      rel: external ? 'external nofollow noreferrer' : null,
    );
  }

  @override
  void writePagedLink(
    String titlePrefix,
    String id,
    String url,
    String pageSeparator,
    String page,
    String className,
  ) {
    final external = !url.startsWith('/');
    renderer.addLink(
      href:
          '${external ? url : renderer.relativeUrl(url)}$id$pageSeparator$page',
      children: [DTextText('$titlePrefix$id/p$page')],
      classes: ['dtext-link', 'dtext-id-link', 'dtext-$className-id-link'],
      kind: DTextLinkKind.id,
      rel: external ? 'external nofollow noreferrer' : null,
    );
  }

  @override
  bool isUrlLike(String value) {
    if (value.isEmpty || value.contains(RegExp(r'\s'))) return false;
    if (value.startsWith('#')) return true;
    if (value == '/' || value == '//') return true;
    if (value.startsWith('/') && !value.startsWith('//')) return true;
    if (value.startsWith('//')) return isValidUrl(normalizeHref(value));

    return RegExp(
          r'^(?:https?://|mailto:)',
          caseSensitive: false,
        ).hasMatch(value) &&
        isValidUrl(value);
  }

  @override
  bool isUrlBoundary(int offset) {
    if (offset < 0) return true;

    final code = scanner.source.codeUnitAt(offset);
    final isAsciiLetter =
        code >= 0x41 && code <= 0x5A || code >= 0x61 && code <= 0x7A;
    final isDigit = code >= 0x30 && code <= 0x39;

    return !isAsciiLetter && !isDigit;
  }

  @override
  int? wikiAnchorIndex(String value) {
    for (var i = 1; i < value.length - 1; i++) {
      if (value[i] != '#') continue;

      final next = value.codeUnitAt(i + 1);
      if (next >= 0x41 && next <= 0x5A) return i;
    }

    return null;
  }
}
