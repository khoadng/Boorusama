bool hasTextBetweenDiv(String htmlString) {
  final regex = RegExp(
    r'<div[^>]*>([\s\S]*?)<\/div>',
    multiLine: true,
    caseSensitive: false,
  );
  final matches = regex.allMatches(htmlString);

  for (final match in matches) {
    final text = match.group(1)?.trim();
    if (text != null && text.isNotEmpty) return true;
  }

  return false;
}
