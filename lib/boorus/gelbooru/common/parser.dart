String decodeHtmlEntities(String input) {
  return input
      .replaceAll('&#039;', "'")
      .replaceAll('&quot;', '"')
      .replaceAll('&amp;', '&')
      .replaceAll('&lt;', '<')
      .replaceAll('&gt;', '>');
}
