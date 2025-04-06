// Package imports:
import 'package:collection/collection.dart';

// Project imports:
import 'booru.dart';

class BooruDb {
  const BooruDb({
    required this.boorus,
  });

  final List<Booru> boorus;

  T? getBooru<T extends Booru>() {
    final booru = boorus.firstWhereOrNull((booru) => booru is T);

    return booru as T?;
  }

  List<Booru> getAllBoorus() {
    return boorus.toList();
  }

  Booru? getBooruFromUrl(String url) {
    for (final booru in boorus) {
      if (booru.hasSite(url)) {
        return booru;
      }
    }
    return null;
  }

  Booru? getBooruFromId(int id) {
    return boorus.firstWhereOrNull((booru) => booru.id == id);
  }
}
