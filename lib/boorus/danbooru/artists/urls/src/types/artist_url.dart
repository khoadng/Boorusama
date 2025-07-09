// Package imports:
import 'package:equatable/equatable.dart';

class DanbooruArtistUrl extends Equatable {
  const DanbooruArtistUrl({
    required this.url,
    required this.isActive,
  });

  final String url;
  final bool isActive;

  @override
  String toString() => '${isActive ? '' : 'inactive: '}$url}';

  @override
  List<Object?> get props => [url, isActive];
}

extension DanbooruArtistUrlX on DanbooruArtistUrl {
  DanbooruArtistUrl copyWith({
    String? url,
    bool? isActive,
  }) => DanbooruArtistUrl(
    url: url ?? this.url,
    isActive: isActive ?? this.isActive,
  );
}
