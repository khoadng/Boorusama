// Project imports:
import 'package:boorusama/boorus/core/feats/boorus/boorus.dart';
import 'dtext_grammar.dart';

String dtext(
  String value, {
  required Booru booru,
}) {
  final tagSearchUrl = '${booru.url}/posts?tags=';
  final result =
      DTextGrammarDefinition(tagSearchUrl: tagSearchUrl).build().parse(value);
  return result.isSuccess ? grammarToHtmlString(result.value) : value;
}

String grammarToHtmlString(List<dynamic> value) {
  final buffer = StringBuffer();
  for (final element in value) {
    final data = mapDataToString(element);
    buffer.write(data);
  }
  return buffer.toString();
}

String mapDataToString(dynamic data) => switch (data) {
      BBCode c => parseBBcodeToHtml(c),
      LineBreakElement => '<br>',
      UrlElement url => parseUrl(url),
      String => data,
      _ => data.toString(),
    };

String parseUrl(UrlElement url) {
  final displayText = url.displayText ?? url.url;
  return '<a href="${url.url}">$displayText</a>';
}

String parseBBcodeToHtml(BBCode text) => switch (text.tag) {
      'b' => '<b>${text.text}</b>',
      'i' => '<i>${text.text}</i>',
      'u' => '<u>${text.text}</u>',
      's' => '<s>${text.text}</s>',
      'expand' =>
        '<details><summary>${text.attributes ?? 'Show'}</summary>${text.text}</details>',
      'quote' => '<blockquote>${text.text}</blockquote>',
      _ => text.text
    };
