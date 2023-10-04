part of 'dtext_grammar.dart';

Parser link() =>
    ref0(urlRawLink) | ref0(customTextLink) | ref0(markdownStyleLink);

Parser internalLink(String baseUrl) =>
    ref1(tagSearchLink, baseUrl) | ref1(wikiLink, baseUrl);

Parser urlRawLink() => url().flatten().map((value) => UrlElement(value));
Parser markdownStyleLink() => (char('[') &
        pattern('^]').star().flatten() &
        char(']') &
        char('(') &
        ref0(url).flatten() &
        char(')'))
    .map((value) => UrlElement(value[1], displayText: value[3]));

Parser customTextLink() => (char('"') &
        pattern('^"').star().flatten() &
        char('"') &
        char(':') &
        char('[') &
        ref0(url).flatten() &
        char(']'))
    .map((value) => UrlElement(value[5], displayText: value[1]));

Parser tagSearchLink(String searchUrl) => (string('{{') &
        pattern('^}').star().flatten() &
        string('}}'))
    .map((value) => UrlElement('$searchUrl${value[1]}', displayText: value[1]));

Parser wikiLink(String wikiUrl) => (string('[[') &
        pattern('^]').star().flatten() &
        string(']]'))
    .map((value) => UrlElement('$wikiUrl${value[1]}', displayText: value[1]));

class UrlElement {
  final String url;
  final String? displayText;

  UrlElement(this.url, {this.displayText});

  @override
  String toString() => 'UrlElement{url: $url, displayText: $displayText}';
}
