// Package imports:
import 'package:bloc_test/bloc_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:test/test.dart';

// Project imports:
import 'package:boorusama/boorus/danbooru/application/artist/artist.dart';
import 'package:boorusama/boorus/danbooru/domain/artists/artists.dart';
import 'package:boorusama/core/application/common.dart';

class MockArtistRepository extends Mock implements ArtistRepository {}

void main() {
  final artistRepo = MockArtistRepository();

  group('[artist bloc test]', () {
    blocTest<ArtistBloc, ArtistState>(
      'fetch an artist',
      setUp: () {
        when(() => artistRepo.getArtist(any())).thenAnswer(
          (invocation) async => Artist.empty().copyWith(name: 'foo'),
        );
      },
      tearDown: () {
        reset(artistRepo);
      },
      build: () => ArtistBloc(artistRepository: artistRepo),
      act: (bloc) => bloc.add(const ArtistFetched(name: 'foo')),
      expect: () => [
        ArtistState.initial().copyWith(status: LoadStatus.loading),
        ArtistState.initial().copyWith(
          status: LoadStatus.success,
          artist: Artist.empty().copyWith(name: 'foo'),
        ),
      ],
    );
  });
}
