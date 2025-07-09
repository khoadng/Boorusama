String linkify({
  required String? title,
  required String? address,
  bool underline = false,
}) {
  String underline_() => underline ? '' : 'style="text-decoration:none"';

  return '<a href="$address" ${underline_()}>$title</a>';
}
