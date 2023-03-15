import 'package:boorusama/boorus/booru.dart';

import 'user_booru.dart';

class UserBooruCredential {
  const UserBooruCredential._({
    required this.booruId,
    required this.apiKey,
    required this.login,
    required this.booruUserId,
  });

  factory UserBooruCredential.anonymous({
    required BooruType booru,
  }) =>
      UserBooruCredential._(
        booruId: booru.index,
        apiKey: '',
        login: '',
        booruUserId: null,
      );

  static UserBooruCredential? withAccount({
    required BooruType booru,
    required String login,
    required String apiKey,
    required int booruUserId,
  }) {
    if (login == '') return null;
    if (apiKey == '') return null;
    if (booruUserId <= 0) return null;

    return UserBooruCredential._(
      booruId: booru.index,
      apiKey: apiKey,
      login: login,
      booruUserId: booruUserId,
    );
  }

  final int booruId;
  final String apiKey;
  final String login;
  final int? booruUserId;
}

UserBooru? convertToUserBooru({
  required int? id,
  required UserBooruCredential? credential,
}) {
  if (credential == null || id == null) return null;

  final booruUserId = credential.booruUserId;
  if (booruUserId == null) return null;

  return UserBooru(
    id: id,
    booruId: credential.booruId,
    apiKey: credential.apiKey,
    login: credential.login,
    booruUserId: booruUserId,
  );
}
