const urlPattern =
    r'https?:\/\/(www\.)?[-a-zA-Z0-9@:%._\+~#=]{1,256}\.[a-zA-Z0-9()]{1,6}\b([-a-zA-Z0-9()@:%_\+.~#?&//=]*)';

const linkPattern = r'"(.*?)":\[(.*?)\]';

String parseTextToHtml(String text) {
  final t0 = _removePixivBoldTag(text);
  final t1 = _parseLink(t0);
  final t2 = _parsePixivLink(t1);

  return t2;
}

String _removePixivBoldTag(String text) => _parse(
      text,
      RegExp(r'\[b](.*?)\[\/b\]'),
      (match) => '${match.group(1)}',
    );

String _parsePixivLink(String text) => _parse(
      text,
      RegExp('<(http.*?)>'),
      (match) => linkify(title: match.group(1), address: match.group(1)),
    );

String _parseLink(String text) => _parse(
      text,
      RegExp(linkPattern),
      (match) => linkify(title: match.group(1), address: match.group(2)),
    );

// ignore: unused_element
String _parseUrl(String text) => _parse(
      text,
      RegExp(urlPattern),
      (match) => linkify(title: match.group(0), address: match.group(0)),
    );

String _parse(
  String text,
  RegExp pattern,
  String Function(Match match) replace,
) =>
    text.replaceAllMapped(pattern, replace);

String linkify({
  required String? title,
  required String? address,
  bool underline = false,
}) {
  String underline_() => underline ? '' : 'style="text-decoration:none"';
  return '<a href="$address" ${underline_()}>$title</a>';
}
