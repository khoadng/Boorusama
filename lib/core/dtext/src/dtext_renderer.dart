// Dart imports:
import 'dart:convert';

// Package imports:
import 'package:dtext/dtext.dart' as dtext_parser;

typedef DTextDocumentParser =
    dtext_parser.DTextDocument Function(
      String value,
      dtext_parser.DTextOptions options,
    );

String renderDText(
  String value, {
  required String booruUrl,
  DTextDocumentParser parser = _parseDTextDocument,
}) {
  final options = dtextOptionsForBooruUrl(booruUrl);

  try {
    final document = parser(value, options);
    return dtext_parser.DText.renderHtml(document);
  } catch (_) {
    return renderPlainDTextFallback(value);
  }
}

dtext_parser.DTextDocument _parseDTextDocument(
  String value,
  dtext_parser.DTextOptions options,
) => dtext_parser.DText.parseDocument(value, options: options);

String _withoutTrailingSlash(String value) =>
    value.endsWith('/') ? value.substring(0, value.length - 1) : value;

dtext_parser.DTextOptions dtextOptionsForBooruUrl(String booruUrl) {
  final uri = Uri.tryParse(booruUrl);
  final host = uri?.host;

  return dtext_parser.DTextOptions(
    baseUrl: _withoutTrailingSlash(booruUrl),
    domain: host,
    internalDomains: {
      if (host != null && host.isNotEmpty) host,
    },
  );
}

String renderPlainDTextFallback(String value) {
  final escaped = const HtmlEscape(
    HtmlEscapeMode.element,
  ).convert(value).replaceAll('\n', '<br>');

  return '<p>$escaped</p>';
}
