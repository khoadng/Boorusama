class ImageSource {

  ImageSource(
    String source,
    int? pixivId,
  ) {
    try {
      if (pixivId == null) {
        _address = Uri.parse(source);
      } else {
        final pixivUrl = 'https://www.pixiv.net/en/artworks/$pixivId';
        _address = Uri.parse(pixivUrl);
      }
    } catch (e) {
      _address = null;
    }
  }
  Uri? _address;

  Uri? get uri => _address;
}
