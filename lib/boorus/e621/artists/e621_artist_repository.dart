// Project imports:
import 'package:boorusama/boorus/e621/artists/artists.dart';
import 'package:boorusama/clients/e621/e621_client.dart';
import 'package:boorusama/clients/e621/types/types.dart';
import 'package:boorusama/functional.dart';

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
