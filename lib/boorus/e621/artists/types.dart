// Package imports:
import 'package:equatable/equatable.dart';
import 'package:foundation/foundation.dart';

class E621Artist extends Equatable {
  const E621Artist({
    required this.name,
    required this.otherNames,
  });

  const E621Artist.empty()
      : name = '',
        otherNames = const [];

  final String name;
  final List<String> otherNames;

  @override
  List<Object> get props => [name, otherNames];
}

abstract interface class E621ArtistRepository {
  Future<Option<E621Artist>> getArtist(String name);
}
