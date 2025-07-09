// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import '../../core/boorus/booru/booru.dart';
import '../../core/boorus/booru/providers.dart';
import '../../core/boorus/engine/engine.dart';
import '../../core/http/http.dart';
import 'gelbooru_builder.dart';
import 'gelbooru_repository.dart';

String getGelbooruProfileUrl(String url) => url.endsWith('/')
    ? '${url}index.php?page=account&s=options'
    : '$url/index.php?page=account&s=options';

final gelbooruProvider = Provider<Gelbooru>(
  (ref) {
    final booruDb = ref.watch(booruDbProvider);
    final booru = booruDb.getBooru<Gelbooru>();

    if (booru == null) {
      throw Exception('Booru not found for type: ${BooruType.gelbooru}');
    }

    return booru;
  },
);

BooruComponents createGelbooru() => BooruComponents(
  parser: GelbooruParser(),
  createBuilder: GelbooruBuilder.new,
  createRepository: (ref) => GelbooruRepository(ref: ref),
);

final class Gelbooru extends Booru with PassHashAuthMixin {
  const Gelbooru({
    required super.name,
    required super.protocol,
    required this.sites,
    required this.loginUrl,
  });

  @override
  final List<String> sites;
  @override
  final String? loginUrl;

  @override
  BooruType get type => BooruType.gelbooru;

  @override
  String? getLoginUrl() => loginUrl;
}

class GelbooruParser extends BooruParser {
  @override
  BooruType get booruType => BooruType.gelbooru;

  @override
  Booru parse(String name, dynamic data) {
    return Gelbooru(
      name: name,
      protocol: parseProtocol(data['protocol']),
      sites: List.from(data['sites']),
      loginUrl: data['login-url'],
    );
  }
}
