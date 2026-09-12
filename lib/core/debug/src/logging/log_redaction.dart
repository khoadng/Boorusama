/// Redacts credential-bearing fields in legacy text messages. Structured
/// producers must supply a safe message instead of relying on text detection
/// for arbitrary server bodies or exceptions.
String redactLogMessage(String message) {
  var result = message.replaceAllMapped(
    RegExp(r'https?://[^\s<>"\x27]+', caseSensitive: false),
    (match) => redactLogUri(Uri.tryParse(match[0]!) ?? Uri()),
  );
  result = result.replaceAllMapped(
    RegExp(
      r'(authorization|proxy-authorization|cookie|set-cookie)["\x27]?\s*[:=]\s*[^\r\n]+',
      caseSensitive: false,
    ),
    (match) => '${match[1]}: [REDACTED]',
  );
  return result.replaceAllMapped(
    RegExp(
      r'''(["']?(?:api[_-]?key|pass(?:word)?[_-]?hash|password|passwd|access[_-]?token|refresh[_-]?token|auth[_-]?token|token|secret|client[_-]?secret|cf_clearance)["']?\s*[:=]\s*)(?:\[REDACTED\]|"[^"]*"|'[^']*'|[^\s,;&}\]]+)''',
      caseSensitive: false,
    ),
    (match) => '${match[1]}[REDACTED]',
  );
}

/// Preserve routing information, but never query values, fragments or userinfo.
/// Unknown sites may use arbitrary parameter names for credentials.
String redactLogUri(Uri uri) {
  if (!uri.hasScheme || uri.host.isEmpty) return '[REDACTED URL]';
  return uri
      .removeFragment()
      .replace(
        userInfo: '',
        queryParameters: uri.hasQuery
            ? {for (final key in uri.queryParametersAll.keys) key: '[REDACTED]'}
            : null,
      )
      .toString();
}
