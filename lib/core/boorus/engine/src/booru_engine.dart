// Project imports:
import '../../booru/booru.dart';
import 'booru_builder.dart';
import 'booru_repository.dart';

class BooruEngine {
  const BooruEngine({
    required this.booru,
    required this.builder,
    required this.repository,
  });

  final Booru booru;
  final BooruBuilder builder;
  final BooruRepository repository;
}

class BooruEngineRegistry {
  final Map<BooruType, BooruEngine> _engines = {};

  void register(BooruType type, BooruEngine engine) {
    _engines[type] = engine;
  }

  BooruEngine? getEngine(BooruType type) => _engines[type];

  BooruRepository? getRepository(BooruType type) => _engines[type]?.repository;

  BooruBuilder? getBuilder(BooruType type) => _engines[type]?.builder;

  List<Booru> getAllBoorus() {
    return _engines.values.map((e) => e.booru).toList();
  }
}
