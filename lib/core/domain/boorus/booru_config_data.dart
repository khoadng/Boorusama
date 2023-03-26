// Project imports:
import 'package:boorusama/core/domain/boorus.dart';

class BooruConfigData {
  const BooruConfigData._({
    required this.booruId,
    required this.apiKey,
    required this.login,
    required this.booruUserId,
  });

  factory BooruConfigData.anonymous({
    required BooruType booru,
  }) =>
      BooruConfigData._(
        booruId: booru.index,
        apiKey: '',
        login: '',
        booruUserId: null,
      );

  static BooruConfigData? fromJson(Map<String, dynamic> json) {
    try {
      return BooruConfigData._(
        booruId: json['booruId'] as int,
        apiKey: json['apiKey'] as String,
        login: json['login'] as String,
        booruUserId: json['booruUserId'] as int?,
      );
    } catch (e) {
      return null;
    }
  }

  static BooruConfigData? withAccount({
    required BooruType booru,
    required String login,
    required String apiKey,
    required int booruUserId,
  }) {
    if (login == '') return null;
    if (apiKey == '') return null;
    if (booruUserId <= 0) return null;

    return BooruConfigData._(
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

BooruConfig? convertToUserBooru({
  required int? id,
  required BooruConfigData? booruConfigData,
}) {
  if (booruConfigData == null || id == null) return null;

  final booruUserId = booruConfigData.booruUserId;

  return BooruConfig(
    id: id,
    booruId: booruConfigData.booruId,
    apiKey: booruConfigData.apiKey.isEmpty ? null : booruConfigData.apiKey,
    login: booruConfigData.login.isEmpty ? null : booruConfigData.login,
    booruUserId: booruUserId,
  );
}
