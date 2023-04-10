String getFavicon(
  String url, {
  int? size,
}) =>
    'https://www.google.com/s2/favicons?domain=$url&sz=${size ?? 64}';
