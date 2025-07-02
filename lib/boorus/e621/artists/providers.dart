// Package imports:
import 'package:booru_clients/e621.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:foundation/foundation.dart';

// Project imports:
import '../../../core/configs/config/providers.dart';
import '../../../core/configs/config/types.dart';
import '../client_provider.dart';
import 'parser.dart';
import 'types.dart';

final e621ArtistProvider =
    FutureProvider.autoDispose.family<E621Artist, String>((ref, name) async {
  final config = ref.watchConfigAuth;
  final repo = ref.read(e621ArtistRepoProvider(config));
  final artist = await repo.getArtist(name);
  return artist.getOrElse(() => const E621Artist.empty());
});

final e621ArtistRepoProvider =
    Provider.family<E621ArtistRepository, BooruConfigAuth>((ref, config) {
  return E621ArtistRepositoryApi(
    ref.watch(e621ClientProvider(config)),
  );
});

class E621ArtistRepositoryApi implements E621ArtistRepository {
  E621ArtistRepositoryApi(
    this.client,
  );

  final E621Client client;

  @override
  Future<Option<E621Artist>> getArtist(String name) => client
      .getArtist(nameOrID: name)
      .then(e621ArtistDtoToArtist)
      .then((value) => some(value))
      .catchError((e) => none<E621Artist>());
}
