import '../ast.dart';
import '../url_normalizer.dart';

import '../characters.dart';
import 'context.dart';

class _IdLinkDefinition {
  const _IdLinkDefinition(this.prefix, this.className, this.url);

  final String prefix;
  final String className;
  final String url;
}

class _IdLinkMatch {
  const _IdLinkMatch({
    required this.definition,
    required this.key,
    required this.id,
    required this.page,
    required this.length,
  });

  final _IdLinkDefinition definition;
  final String key;
  final String id;
  final String? page;
  final int length;
}

const _idLinks = <String, _IdLinkDefinition>{
  'media asset': _IdLinkDefinition('asset', 'media-asset', '/media_assets/'),
  'mod action': _IdLinkDefinition('mod action', 'mod-action', '/mod_actions/'),
  'post': _IdLinkDefinition('post', 'post', '/posts/'),
  'asset': _IdLinkDefinition('asset', 'media-asset', '/media_assets/'),
  'appeal': _IdLinkDefinition('appeal', 'post-appeal', '/post_appeals/'),
  'flag': _IdLinkDefinition('flag', 'post-flag', '/post_flags/'),
  'note': _IdLinkDefinition('note', 'note', '/notes/'),
  'forum': _IdLinkDefinition('forum', 'forum-post', '/forum_posts/'),
  'topic': _IdLinkDefinition('topic', 'forum-topic', '/forum_topics/'),
  'comment': _IdLinkDefinition('comment', 'comment', '/comments/'),
  'dmail': _IdLinkDefinition('dmail', 'dmail', '/dmails/'),
  'pool': _IdLinkDefinition('pool', 'pool', '/pools/'),
  'user': _IdLinkDefinition('user', 'user', '/users/'),
  'artist': _IdLinkDefinition('artist', 'artist', '/artists/'),
  'ban': _IdLinkDefinition('ban', 'ban', '/bans/'),
  'alias': _IdLinkDefinition('alias', 'tag-alias', '/tag_aliases/'),
  'implication': _IdLinkDefinition(
    'implication',
    'tag-implication',
    '/tag_implications/',
  ),
  'favgroup': _IdLinkDefinition(
    'favgroup',
    'favorite-group',
    '/favorite_groups/',
  ),
  'modreport': _IdLinkDefinition(
    'modreport',
    'moderation-report',
    '/moderation_reports/',
  ),
  'feedback': _IdLinkDefinition(
    'feedback',
    'user-feedback',
    '/user_feedbacks/',
  ),
  'wiki': _IdLinkDefinition('wiki', 'wiki-page', '/wiki_pages/'),
  'issue': _IdLinkDefinition(
    'issue',
    'github',
    'https://github.com/danbooru/danbooru/issues/',
  ),
  'pull': _IdLinkDefinition(
    'pull',
    'github-pull',
    'https://github.com/danbooru/danbooru/pull/',
  ),
  'commit': _IdLinkDefinition(
    'commit',
    'github-commit',
    'https://github.com/danbooru/danbooru/commit/',
  ),
  'pixiv': _IdLinkDefinition(
    'pixiv',
    'pixiv',
    'https://www.pixiv.net/artworks/',
  ),
  'twitter': _IdLinkDefinition(
    'twitter',
    'twitter',
    'https://twitter.com/i/web/status/',
  ),
  'gelbooru': _IdLinkDefinition(
    'gelbooru',
    'gelbooru',
    'https://gelbooru.com/index.php?page=post&s=view&id=',
  ),
};

mixin DTextLinkParser on DTextParserContext {
  @override
  bool parseWikiLink() {
    final match = _matchDelimitedText('[[', ']]');
    if (match == null) return false;

    final prefix = match.prefix;
    final body = match.body.trim();
    final suffix = match.suffix;
    if (body.isEmpty) return false;

    scanner.advance(match.length);
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
    final match = _matchDelimitedText('{{', '}}');
    if (match == null) return false;

    final prefix = match.prefix;
    final body = match.body.trim();
    final suffix = match.suffix;
    if (body.isEmpty) return false;

    scanner.advance(match.length);
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
    final textile = _matchTextileNamedLink();
    if (textile != null) {
      if (isUrlLike(textile.url)) {
        scanner.advance(textile.length);
        writeNamedUrl(normalizeHref(textile.url), textile.title);
        return true;
      }
    }

    if (scanner.startsWith('[/')) return false;
    final markdown = _matchMarkdownNamedLink();
    if (markdown == null) return false;

    final first = markdown.first;
    final second = markdown.second;
    final firstIsUrl = isUrlLike(first);
    final secondIsUrl = isUrlLike(second);
    if (!firstIsUrl && !secondIsUrl) return false;

    scanner.advance(markdown.length);
    if (firstIsUrl) {
      writeNamedUrl(normalizeHref(first), second);
    } else {
      writeNamedUrl(normalizeHref(second), first);
    }
    return true;
  }

  @override
  bool parseHtmlLink() {
    final match = _matchHtmlLink();
    if (match == null) return false;

    final url = normalizeHref(match.url.trim());
    final title = match.title;
    if (!isUrlLike(url) || title.isEmpty) return false;

    scanner.advance(match.length);
    writeNamedUrl(url, title);
    return true;
  }

  @override
  bool parseBbcodeLink() {
    final explicit = _matchExplicitBbcodeUrl();
    if (explicit != null) {
      final url = normalizeHref(explicit.url.trim());
      if (!isUrlLike(url)) return false;

      final start = scanner.offset;
      scanner.advance(explicit.length);
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

    if (!scanner.startsWith('[url]', caseSensitive: false)) return false;

    final start = scanner.offset;
    scanner.advance(5);
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
    final match = _matchIdLink();
    if (match == null) return false;

    scanner.advance(match.length);
    final definition = match.definition;
    if (match.key == 'topic' && match.page != null) {
      writePagedLink(
        'topic #',
        match.id,
        '/forum_topics/',
        '?page=',
        match.page!,
        'forum-topic',
      );
    } else if (match.key == 'pixiv' && match.page != null) {
      writePagedLink(
        'pixiv #',
        match.id,
        'https://www.pixiv.net/artworks/',
        '#',
        match.page!,
        'pixiv',
      );
    } else {
      writeIdLink(
        definition.prefix,
        definition.className,
        definition.url,
        match.id,
      );
    }

    return true;
  }

  _IdLinkMatch? _matchIdLink() {
    for (final entry in _idLinks.entries) {
      final key = entry.key;
      if (!scanner.startsWith(key, caseSensitive: false)) continue;

      var index = scanner.offset + key.length;
      if (!scanner.startsWithAt(index, ' #')) continue;
      index += 2;

      final idStart = index;
      while (index < scanner.source.length &&
          isAsciiDigit(scanner.source.codeUnitAt(index))) {
        index++;
      }
      if (index == idStart) continue;

      final idEnd = index;
      String? page;
      if (scanner.startsWithAt(index, '/p')) {
        final pageStart = index + 2;
        index = pageStart;
        while (index < scanner.source.length &&
            isAsciiDigit(scanner.source.codeUnitAt(index))) {
          index++;
        }
        if (index == pageStart) {
          index = idEnd;
        } else {
          page = scanner.source.substring(pageStart, index);
        }
      }

      return _IdLinkMatch(
        definition: entry.value,
        key: key,
        id: scanner.source.substring(idStart, idEnd),
        page: page,
        length: index - scanner.offset,
      );
    }

    return null;
  }

  @override
  bool parseRawUrl() {
    if (!isUrlBoundary(scanner.offset - 1)) return false;

    final match = _matchRawUrl();
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
    final match = _matchDelimitedUrl();
    if (match == null) return false;

    if (!isValidUrl(match.url)) return false;

    scanner.advance(match.length);
    writeUnnamedUrl(match.url);
    return true;
  }

  ({String prefix, String body, String suffix, int length})?
  _matchDelimitedText(String open, String close) {
    final start = scanner.offset;
    var index = start;

    while (index < scanner.source.length &&
        isAsciiAlphaNumeric(scanner.source.codeUnitAt(index))) {
      index++;
    }
    final prefixEnd = index;

    if (!scanner.startsWithAt(index, open)) return null;
    index += open.length;

    final bodyStart = index;
    while (index < scanner.source.length) {
      final codeUnit = scanner.source.codeUnitAt(index);
      if (codeUnit == lineFeedCode) return null;
      if (scanner.startsWithAt(index, close)) break;
      index++;
    }
    if (index >= scanner.source.length) return null;

    final body = scanner.source.substring(bodyStart, index);
    index += close.length;

    final suffixStart = index;
    while (index < scanner.source.length &&
        isAsciiAlphaNumeric(scanner.source.codeUnitAt(index))) {
      index++;
    }

    return (
      prefix: scanner.source.substring(start, prefixEnd),
      body: body,
      suffix: scanner.source.substring(suffixStart, index),
      length: index - start,
    );
  }

  ({String title, String url, int length})? _matchTextileNamedLink() {
    final start = scanner.offset;
    if (!scanner.startsWith('"')) return null;

    var index = start + 1;
    final titleStart = index;
    while (index < scanner.source.length) {
      final codeUnit = scanner.source.codeUnitAt(index);
      if (codeUnit == lineFeedCode) return null;
      if (codeUnit == doubleQuoteCode) break;
      index++;
    }
    if (index >= scanner.source.length || index == titleStart) return null;

    final title = scanner.source.substring(titleStart, index);
    index++;
    if (index >= scanner.source.length || scanner.source[index] != ':') {
      return null;
    }
    index++;

    final bracketed =
        index < scanner.source.length && scanner.source[index] == '[';
    if (bracketed) index++;
    final urlStart = index;
    while (index < scanner.source.length) {
      final codeUnit = scanner.source.codeUnitAt(index);
      if (isWhitespace(codeUnit) || codeUnit == rightBracketCode) break;
      index++;
    }
    if (index == urlStart) return null;

    final url = scanner.source.substring(urlStart, index);
    if (bracketed &&
        index < scanner.source.length &&
        scanner.source[index] == ']') {
      index++;
    }

    return (title: title, url: url, length: index - start);
  }

  ({String first, String second, int length})? _matchMarkdownNamedLink() {
    final start = scanner.offset;
    if (!scanner.startsWith('[') || scanner.startsWith('[/')) return null;

    var index = start + 1;
    final firstStart = index;
    while (index < scanner.source.length) {
      final codeUnit = scanner.source.codeUnitAt(index);
      if (codeUnit == lineFeedCode) return null;
      if (codeUnit == rightBracketCode) break;
      index++;
    }
    if (index >= scanner.source.length || index == firstStart) return null;

    final first = scanner.source.substring(firstStart, index);
    index++;
    if (index >= scanner.source.length || scanner.source[index] != '(') {
      return null;
    }
    index++;

    final secondStart = index;
    while (index < scanner.source.length) {
      final codeUnit = scanner.source.codeUnitAt(index);
      if (codeUnit == lineFeedCode) return null;
      if (codeUnit == rightParenthesisCode) break;
      index++;
    }
    if (index >= scanner.source.length || index == secondStart) return null;

    return (
      first: first,
      second: scanner.source.substring(secondStart, index),
      length: index + 1 - start,
    );
  }

  ({String url, String title, int length})? _matchHtmlLink() {
    final start = scanner.offset;
    if (!scanner.startsWith('<a', caseSensitive: false)) return null;
    if (start + 2 >= scanner.source.length ||
        !isWhitespace(scanner.source.codeUnitAt(start + 2))) {
      return null;
    }

    final openEnd = scanner.indexOf('>', start: start + 3);
    if (openEnd < 0) return null;

    final openTag = scanner.source.substring(start, openEnd + 1);
    final href = _extractHref(openTag);
    if (href == null) return null;

    final closeStart = scanner.indexOf(
      '</a>',
      start: openEnd + 1,
      caseSensitive: false,
    );
    if (closeStart < 0) return null;

    return (
      url: href,
      title: scanner.source.substring(openEnd + 1, closeStart),
      length: closeStart + 4 - start,
    );
  }

  String? _extractHref(String openTag) {
    var index = 2;
    while (index < openTag.length) {
      while (index < openTag.length &&
          isWhitespace(openTag.codeUnitAt(index))) {
        index++;
      }

      if (index >= openTag.length || openTag[index] == '>') return null;
      final nameStart = index;
      while (index < openTag.length &&
          (isAsciiAlphaNumeric(openTag.codeUnitAt(index)) ||
              openTag[index] == '-' ||
              openTag[index] == '_')) {
        index++;
      }
      if (index == nameStart) {
        index++;
        continue;
      }

      final name = openTag.substring(nameStart, index);
      while (index < openTag.length &&
          isWhitespace(openTag.codeUnitAt(index))) {
        index++;
      }
      if (index >= openTag.length || openTag[index] != '=') continue;
      index++;
      while (index < openTag.length &&
          isWhitespace(openTag.codeUnitAt(index))) {
        index++;
      }
      if (index >= openTag.length) return null;

      final quote = openTag[index];
      if (quote != '"' && quote != "'") return null;
      index++;
      final valueStart = index;
      while (index < openTag.length && openTag[index] != quote) {
        index++;
      }
      if (index >= openTag.length) return null;

      final value = openTag.substring(valueStart, index);
      index++;
      if (name.length == 4 && startsWithAsciiIgnoreCase(name, 0, 'href')) {
        return value;
      }
    }

    return null;
  }

  ({String url, int length})? _matchExplicitBbcodeUrl() {
    final start = scanner.offset;
    if (!scanner.startsWith('[url', caseSensitive: false)) return null;

    var index = start + 4;
    while (index < scanner.source.length &&
        isSpaceTab(scanner.source.codeUnitAt(index))) {
      index++;
    }
    if (index >= scanner.source.length || scanner.source[index] != '=') {
      return null;
    }
    index++;
    while (index < scanner.source.length &&
        isSpaceTab(scanner.source.codeUnitAt(index))) {
      index++;
    }
    if (index >= scanner.source.length) return null;

    String url;
    final quote = scanner.source[index];
    if (quote == '"' || quote == "'") {
      index++;
      final urlStart = index;
      while (index < scanner.source.length) {
        final codeUnit = scanner.source.codeUnitAt(index);
        if (codeUnit == lineFeedCode || codeUnit == rightBracketCode) {
          return null;
        }
        if (scanner.source[index] == quote) break;
        index++;
      }
      if (index >= scanner.source.length || index == urlStart) return null;
      url = scanner.source.substring(urlStart, index);
      index++;
    } else {
      final urlStart = index;
      while (index < scanner.source.length) {
        final codeUnit = scanner.source.codeUnitAt(index);
        if (isWhitespace(codeUnit) || codeUnit == rightBracketCode) break;
        index++;
      }
      if (index == urlStart) return null;
      url = scanner.source.substring(urlStart, index);
    }

    while (index < scanner.source.length &&
        isSpaceTab(scanner.source.codeUnitAt(index))) {
      index++;
    }
    if (index >= scanner.source.length || scanner.source[index] != ']') {
      return null;
    }

    return (url: url, length: index + 1 - start);
  }

  String? _matchRawUrl() {
    final start = scanner.offset;
    if (!_startsWithUrlScheme(scanner.source, start)) return null;

    var index = start;
    while (index < scanner.source.length &&
        _isRawUrlCodeUnit(scanner.source.codeUnitAt(index))) {
      index++;
    }
    if (index == start) return null;

    return scanner.source.substring(start, index);
  }

  ({String url, int length})? _matchDelimitedUrl() {
    final start = scanner.offset;
    if (!scanner.startsWith('<')) return null;

    var index = start + 1;
    if (!_startsWithUrlScheme(scanner.source, index)) return null;

    final urlStart = index;
    while (index < scanner.source.length) {
      final codeUnit = scanner.source.codeUnitAt(index);
      if (isWhitespace(codeUnit) || codeUnit == lessThanCode) return null;
      if (codeUnit == greaterThanCode) {
        if (index == urlStart) return null;
        return (
          url: scanner.source.substring(urlStart, index),
          length: index + 1 - start,
        );
      }
      index++;
    }

    return null;
  }

  bool _startsWithUrlScheme(String source, int offset) =>
      startsWithAsciiIgnoreCase(source, offset, 'http://') ||
      startsWithAsciiIgnoreCase(source, offset, 'https://') ||
      startsWithAsciiIgnoreCase(source, offset, 'mailto:');

  bool _isRawUrlCodeUnit(int codeUnit) =>
      !isWhitespace(codeUnit) &&
      codeUnit != lessThanCode &&
      codeUnit != greaterThanCode &&
      codeUnit != leftBracketCode &&
      codeUnit != rightBracketCode;

  bool _containsWhitespace(String value) {
    for (var i = 0; i < value.length; i++) {
      if (isWhitespace(value.codeUnitAt(i))) return true;
    }

    return false;
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
    if (allAsciiDigits(id)) {
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
    if (value.isEmpty || _containsWhitespace(value)) return false;
    if (value.startsWith('#')) return true;
    if (value == '/' || value == '//') return true;
    if (value.startsWith('/') && !value.startsWith('//')) return true;
    if (value.startsWith('//')) return isValidUrl(normalizeHref(value));

    return _startsWithUrlScheme(value, 0) && isValidUrl(value);
  }

  @override
  bool isUrlBoundary(int offset) {
    if (offset < 0) return true;

    final code = scanner.source.codeUnitAt(offset);
    return !isAsciiAlphaNumeric(code);
  }

  @override
  int? wikiAnchorIndex(String value) {
    for (var i = 1; i < value.length - 1; i++) {
      if (value[i] != '#') continue;

      final next = value.codeUnitAt(i + 1);
      if (isAsciiUpper(next)) return i;
    }

    return null;
  }
}
