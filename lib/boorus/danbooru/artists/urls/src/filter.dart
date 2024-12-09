// Project imports:
import 'artist_url.dart';

const _pixivStacc = '/stacc/';
const _twitterIntent = '/intent/user';
const _pawooAccount = '/web/accounts/';
const _misskeyAccount = 'misskey.io/users/';
const _bskyProfile = '/profile/did:plc:';

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
