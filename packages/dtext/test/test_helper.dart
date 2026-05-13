import 'package:dtext/dtext.dart';
import 'package:test/test.dart';

String parse(String input, {DTextOptions options = const DTextOptions()}) =>
    DText.parse(input, options: options);

void expectDTextCases(Map<String, String> cases) {
  for (final entry in cases.entries) {
    expect(parse(entry.key), entry.value, reason: entry.key);
  }
}

String escapeHtml(String input) => input
    .replaceAll('&', '&amp;')
    .replaceAll('<', '&lt;')
    .replaceAll('>', '&gt;')
    .replaceAll('"', '&quot;');
