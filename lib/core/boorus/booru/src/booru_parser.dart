// Package imports:
import 'package:booru_clients/generated.dart';

// Project imports:
import 'booru.dart';

abstract class BooruParser {
  Booru parse();
}

class DefaultBooruParser implements BooruParser {
  DefaultBooruParser({
    required this.config,
  });

  final BooruYamlConfig config;

  @override
  Booru parse() {
    return BooruScaffold(
      config: config,
    );
  }
}

class CustomBooruParser implements BooruParser {
  CustomBooruParser({
    required this.parseFn,
  });

  final Booru Function() parseFn;

  @override
  Booru parse() {
    return parseFn();
  }
}
