// Package imports:
import 'package:booru_clients/e621.dart';
import 'package:foundation/foundation.dart';

// Project imports:
import 'artists.dart';

abstract interface class E621ArtistRepository {
  Future<Option<E621Artist>> getArtist(String name);
}

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

E621Artist e621ArtistDtoToArtist(ArtistDto dto) => E621Artist(
      name: dto.name ?? '',
      otherNames: dto.otherNames ?? [],
    );
