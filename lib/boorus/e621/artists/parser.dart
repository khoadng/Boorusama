// Package imports:
import 'package:booru_clients/e621.dart';

// Project imports:
import 'types.dart';

E621Artist e621ArtistDtoToArtist(ArtistDto dto) => E621Artist(
      name: dto.name ?? '',
      otherNames: dto.otherNames ?? [],
    );
