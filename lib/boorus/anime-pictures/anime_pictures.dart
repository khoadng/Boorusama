// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import '../../core/boorus/booru/booru.dart';
import '../../core/boorus/booru/providers.dart';
import '../../core/boorus/engine/engine.dart';
import '../../core/http/http.dart';
import 'anime_picture_builder.dart';
import 'anime_picture_repository.dart';

final animePicturesProvider = Provider<AnimePictures>(
  (ref) {
    final booruDb = ref.watch(booruDbProvider);
    final booru = booruDb.getBooru<AnimePictures>();

    if (booru == null) {
      throw Exception('Booru not found for type: ${BooruType.animePictures}');
    }

    return booru;
  },
);

BooruComponents createAnimePictures() => BooruComponents(
      parser: AnimePicturesParser(),
      createBuilder: AnimePicturesBuilder.new,
      createRepository: (ref) => AnimePicturesRepository(ref: ref),
    );

class AnimePictures extends Booru with PassHashAuthMixin {
  const AnimePictures({
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
  BooruType get type => BooruType.animePictures;

  @override
  String? getLoginUrl() => loginUrl;
}

class AnimePicturesParser extends BooruParser {
  @override
  BooruType get booruType => BooruType.animePictures;

  @override
  Booru parse(String name, dynamic data) {
    return AnimePictures(
      name: name,
      protocol: parseProtocol(data['protocol']),
      sites: List.from(data['sites']),
      loginUrl: data['login-url'],
    );
  }
}
