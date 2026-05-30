import 'characters.dart';

bool isInternalUrl(String url, String? domain) {
  if (url.startsWith('/') || url.startsWith('#')) return true;
  if (domain == null || domain.isEmpty) return false;

  final uri = Uri.tryParse(normalizeHref(url));
  if (uri == null || !uri.hasScheme) return false;

  return uri.host.toLowerCase() == domain.toLowerCase();
}

String normalizeHref(String url) {
  if (url.startsWith('//') && url.length > 2) return 'http:$url';

  return url;
}

(String, String) trimUrl(String url) {
  var trimmed = url;
  final mailto = trimmed.toLowerCase().startsWith('mailto:');
  if (!mailto) {
    final schemeIndex = trimmed.indexOf('://');
    if (schemeIndex >= 0) {
      final authorityStart = schemeIndex + 3;
      final authorityEnd = _firstAuthorityTerminator(trimmed, authorityStart);
      final end = authorityEnd < 0 ? trimmed.length : authorityEnd;
      final authority = trimmed.substring(authorityStart, end);
      final at = authority.indexOf('@');
      if (at > 0 && authority.substring(0, at).contains('.')) {
        trimmed = trimmed.substring(0, authorityStart + at);
      }
    }
  }

  var changed = true;
  while (changed) {
    final before = trimmed;
    while (trimmed.isNotEmpty &&
        _isTrailingUrlPunctuation(trimmed.codeUnitAt(trimmed.length - 1))) {
      trimmed = trimmed.substring(0, trimmed.length - 1);
    }
    while (trimmed.endsWith(')') &&
        ')'.allMatches(trimmed).length > '('.allMatches(trimmed).length) {
      trimmed = trimmed.substring(0, trimmed.length - 1);
    }
    changed = before != trimmed;
  }

  return (trimmed, url.substring(trimmed.length));
}

bool isValidUrl(String url) {
  final normalized = normalizeHref(url);
  final lower = normalized.toLowerCase();
  if (lower.startsWith('mailto:')) {
    final address = normalized.substring(7);
    return _isValidEmailAddress(address);
  }
  if (url.startsWith('#')) return true;
  if (url.startsWith('/') && !url.startsWith('//')) return true;
  if (url == '//' || url == '/') return true;

  final uri = Uri.tryParse(normalized);
  if (uri == null || !uri.hasScheme) return false;
  if (uri.scheme != 'http' && uri.scheme != 'https') return false;
  if (uri.host.isEmpty || uri.userInfo.isNotEmpty) return false;
  if (!uri.host.contains('.')) return false;
  if (uri.host.contains('*') || uri.host.contains('[')) return false;

  return true;
}

String normalizeWikiPage(String tag) {
  final normalized = tag.toLowerCase().replaceAll(' ', '_');
  if (_isAllDigits(normalized)) {
    return '~$normalized';
  }

  return normalized;
}

String normalizeAnchor(String anchor) {
  final buffer = StringBuffer('dtext-');
  for (final codeUnit in anchor.codeUnits) {
    if (isAsciiAlphaNumeric(codeUnit)) {
      buffer.writeCharCode(toAsciiLower(codeUnit));
    } else {
      buffer.write('-');
    }
  }

  return buffer.toString();
}

String applyPipeTrick(String tag) =>
    _removeTrailingParenthetical(tag).replaceAll('_', ' ');

int _firstAuthorityTerminator(String value, int start) {
  for (var i = start; i < value.length; i++) {
    final codeUnit = value.codeUnitAt(i);
    if (codeUnit == slashCode ||
        codeUnit == questionCode ||
        codeUnit == hashCodeUnit) {
      return i;
    }
  }

  return -1;
}

bool _isTrailingUrlPunctuation(int codeUnit) =>
    codeUnit == periodCode ||
    codeUnit == doubleQuoteCode ||
    codeUnit == singleQuoteCode ||
    codeUnit == backtickCode ||
    codeUnit == commaCode ||
    codeUnit == colonCode ||
    codeUnit == semicolonCode ||
    codeUnit == questionCode ||
    codeUnit == rightBraceCode;

bool _isValidEmailAddress(String address) {
  final at = address.indexOf('@');
  if (at <= 0 || at != address.lastIndexOf('@')) return false;
  if (at == address.length - 1) return false;

  var lastDotAfterAt = -1;
  for (var i = 0; i < address.length; i++) {
    final codeUnit = address.codeUnitAt(i);
    if (isWhitespace(codeUnit) ||
        codeUnit == lessThanCode ||
        codeUnit == greaterThanCode) {
      return false;
    }
    if (i > at && codeUnit == periodCode) lastDotAfterAt = i;
  }

  return lastDotAfterAt > at + 1 && lastDotAfterAt < address.length - 1;
}

bool _isAllDigits(String value) {
  if (value.isEmpty) return false;
  for (var i = 0; i < value.length; i++) {
    final codeUnit = value.codeUnitAt(i);
    if (!isAsciiDigit(codeUnit)) return false;
  }

  return true;
}

String _removeTrailingParenthetical(String value) {
  if (!value.endsWith(')')) return value;

  final open = value.lastIndexOf('(');
  if (open < 0) return value;

  var end = open;
  while (end > 0) {
    final codeUnit = value.codeUnitAt(end - 1);
    if (codeUnit != underscoreCode && codeUnit != spaceCode) break;
    end--;
  }

  return value.substring(0, end);
}
