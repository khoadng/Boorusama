// Project imports:
import 'package:boorusama/api/e621/e621_api.dart';
import 'package:boorusama/boorus/e621/feats/artists/artists.dart';
import 'package:boorusama/functional.dart';

abstract interface class E621ArtistRepository {
  Future<Option<E621Artist>> getArtist(String name);
}

class E621ArtistRepositoryApi implements E621ArtistRepository {
  E621ArtistRepositoryApi(this.api);

  final E621Api api;

  @override
  Future<Option<E621Artist>> getArtist(String name) => api
      .getArtist(name)
      .then((value) => E621ArtistDto.fromJson(value.data))
      .then(e621ArtistDtoToArtist)
      .then((value) => some(value))
      .catchError((e) => none<E621Artist>());
}

E621Artist e621ArtistDtoToArtist(E621ArtistDto dto) => E621Artist(
      name: dto.name ?? '',
      otherNames: dto.otherNames ?? [],
    );
