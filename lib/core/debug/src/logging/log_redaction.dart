const _credentialFieldPattern =
    'api[_-]?key|key|pass(?:word)?[_-]?hash|password|passwd|access[_-]?token|refresh[_-]?token|auth[_-]?token|token|secret|client[_-]?secret|cf_clearance';

final _credentialField = RegExp(
  '^(?:$_credentialFieldPattern)\$',
  caseSensitive: false,
);

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
      r'''(?<![\w-])(["']?(?:''' +
          _credentialFieldPattern +
          r''')["']?\s*[:=]\s*)(?:\[REDACTED\]|"[^"]*"|'[^']*'|[^\s,;&}\]]+)''',
      caseSensitive: false,
    ),
    (match) => '${match[1]}[REDACTED]',
  );
}

/// Preserve diagnostic query parameters; redact only known credential fields.
String redactLogUri(Uri uri) {
  if (!uri.hasScheme || uri.host.isEmpty) return '[REDACTED URL]';
  return uri
      .removeFragment()
      .replace(
        userInfo: '',
        queryParameters: uri.hasQuery
            ? {
                for (final entry in uri.queryParametersAll.entries)
                  entry.key: _credentialField.hasMatch(entry.key)
                      ? entry.value.map((_) => '[REDACTED]').toList()
                      : entry.value,
              }
            : null,
      )
      .toString();
}
