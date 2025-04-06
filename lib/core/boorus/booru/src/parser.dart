// Project imports:
import 'booru.dart';

abstract class BooruParser {
  String get booruType;
  Booru parse(String name, dynamic data);
}

class BooruParserRegistry {
  final _parsers = <String, BooruParser>{};

  void register(BooruParser parser) {
    _parsers[parser.booruType.toLowerCase()] = parser;
  }

  Booru parseFromConfig(String name, dynamic data) {
    final parser = _parsers[name.toLowerCase()];
    if (parser == null) throw Exception('Unknown booru: $name');
    return parser.parse(name, data);
  }
}
