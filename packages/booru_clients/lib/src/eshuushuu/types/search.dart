import 'package:equatable/equatable.dart';

class EshuushuuSearchRequest extends Equatable {
  const EshuushuuSearchRequest({
    this.tags,
    this.source,
    this.character,
    this.artist,
    this.postcontent,
    this.txtposter,
  });

  final String? tags;
  final String? source;
  final String? character;
  final String? artist;
  final String? postcontent;
  final String? txtposter;

  List<String> get allTags => [
    ?tags,
    ?source,
    ?character,
    ?artist,
  ].where((e) => e.trim().isNotEmpty).toList();

  bool get isEmpty => [
    tags,
    source,
    character,
    artist,
    postcontent,
    txtposter,
  ].every((e) => e == null || e.trim().isEmpty);

  Map<String, String> toMap() {
    return {
      'tags': tags ?? '',
      'source': source ?? '',
      'char': character ?? '',
      'artist': artist ?? '',
      'postcontent': postcontent ?? '',
      'txtposter': txtposter ?? '',
    };
  }

  @override
  List<Object?> get props => [
    tags,
    source,
    character,
    artist,
    postcontent,
    txtposter,
  ];
}
