// Project imports:
import 'package:boorusama/core/domain/boorus.dart';

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

  static UserBooruCredential? fromJson(Map<String, dynamic> json) {
    try {
      return UserBooruCredential._(
        booruId: json['booruId'] as int,
        apiKey: json['apiKey'] as String,
        login: json['login'] as String,
        booruUserId: json['booruUserId'] as int?,
      );
    } catch (e) {
      return null;
    }
  }

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

  Map<String, dynamic> toJson() {
    return {
      'booruId': booruId,
      'apiKey': apiKey,
      'login': login,
      'booruUserId': booruUserId,
    };
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

  return UserBooru(
    id: id,
    booruId: credential.booruId,
    apiKey: credential.apiKey,
    login: credential.login,
    booruUserId: booruUserId,
  );
}
