class ImageSource {
  final String _source;
  Uri _address;

  ImageSource(String source) : _source = source {
    try {
      _address = Uri.parse(_source);
    } catch (e) {
      _address = null;
    }
  }

  Uri get uri => _address;
}
