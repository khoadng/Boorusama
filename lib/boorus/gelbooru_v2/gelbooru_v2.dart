// Package imports:
import 'package:booru_clients/core.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import '../../core/boorus/booru/booru.dart';
import '../../core/boorus/booru/providers.dart';
import '../../core/boorus/engine/engine.dart';
import '../../core/http/http.dart';
import 'gelbooru_v2_builder.dart';
import 'gelbooru_v2_repository.dart';

BooruComponents createGelbooruV2() => BooruComponents(
  parser: const GelbooruV2Parser(),
  createBuilder: GelbooruV2Builder.new,
  createRepository: (ref) => GelbooruV2Repository(ref: ref),
);

final gelbooruV2Provider = Provider<GelbooruV2>((ref) {
  final booruDb = ref.watch(booruDbProvider);
  final booru = booruDb.getBooru<GelbooruV2>();

  if (booru == null) {
    throw Exception('Booru not found for type: ${BooruType.gelbooruV2}');
  }

  return booru;
});

class GelbooruV2 extends FeatureAwareBooru {
  const GelbooruV2({
    required super.name,
    required super.protocol,
    required super.siteCapabilities,
    required super.globalUserParams,
    required super.featureRegistry,
    required this.sites,
  });

  @override
  final Iterable<String> sites;

  @override
  BooruType get type => BooruType.gelbooruV2;
}

class GelbooruV2Parser implements BooruParser {
  const GelbooruV2Parser();

  @override
  BooruType get booruType => BooruType.gelbooruV2;

  @override
  Booru parse(String name, dynamic data) {
    return GelbooruV2(
      name: name,
      protocol: _parseProtocol(data['protocol']),
      globalUserParams: GelbooruV2Config.globalUserParams,
      sites: GelbooruV2Config.sites,
      siteCapabilities: GelbooruV2Config.siteCapabilities,
      featureRegistry: BooruFeatureRegistry(
        GelbooruV2Config.createAllFeatures(),
      ),
    );
  }

  NetworkProtocol _parseProtocol(dynamic protocol) =>
      parseProtocol(protocol ?? 'https_2');
}
