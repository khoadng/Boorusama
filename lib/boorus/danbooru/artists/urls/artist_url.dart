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

const _pixivStacc = '/stacc/';
const _twitterIntent = '/intent/user';
const _pawooAccount = '/web/accounts/';
const _misskeyAccount = 'misskey.io/users/';
const _bskyProfile = '/profile/did:plc:';

extension DanbooruArtistUrlX on DanbooruArtistUrl {
  DanbooruArtistUrl copyWith({
    String? url,
    bool? isActive,
  }) =>
      DanbooruArtistUrl(
        url: url ?? this.url,
        isActive: isActive ?? this.isActive,
      );
}

extension DanbooruArtistUrlIterableX on Iterable<DanbooruArtistUrl> {
  Iterable<DanbooruArtistUrl> filterActive() {
    return where((e) => e.isActive).toList();
  }

  Iterable<DanbooruArtistUrl> filterDuplicates() => where((e) =>
      !e.url.contains(_pixivStacc) &&
      !e.url.contains(_pawooAccount) &&
      !e.url.contains(_misskeyAccount) &&
      !e.url.contains(_bskyProfile) &&
      !e.url.contains(_twitterIntent)).toList();
}
