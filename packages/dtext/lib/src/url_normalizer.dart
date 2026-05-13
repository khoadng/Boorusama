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
      final authorityEnd = trimmed.indexOf(RegExp(r'[/?#]'), authorityStart);
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
        RegExp(r'''[."'`,:;?}]$''').hasMatch(trimmed)) {
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
    return RegExp(r'^[^\s@<>]+@[^\s@<>]+\.[^\s@<>]+$').hasMatch(address);
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
  if (RegExp(r'^\d+$').hasMatch(normalized)) {
    return '~$normalized';
  }

  return normalized;
}

String normalizeAnchor(String anchor) {
  final buffer = StringBuffer('dtext-');
  for (final codeUnit in anchor.codeUnits) {
    final char = String.fromCharCode(codeUnit);
    if (RegExp('[A-Za-z0-9]').hasMatch(char)) {
      buffer.write(char.toLowerCase());
    } else {
      buffer.write('-');
    }
  }

  return buffer.toString();
}

String applyPipeTrick(String tag) =>
    tag.replaceFirst(RegExp(r'[_ ]*\([^)]*\)$'), '').replaceAll('_', ' ');
