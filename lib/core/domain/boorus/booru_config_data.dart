// Project imports:
import 'package:boorusama/core/domain/boorus.dart';

class BooruConfigData {
  const BooruConfigData({
    required this.booruId,
    required this.apiKey,
    required this.login,
    required this.booruUserId,
    required this.name,
    required this.deletedItemBehavior,
    required this.ratingFilter,
  });

  factory BooruConfigData.anonymous({
    required BooruType booru,
    required String name,
    required BooruConfigRatingFilter filter,
  }) =>
      BooruConfigData(
        booruId: booru.index,
        apiKey: '',
        login: '',
        booruUserId: null,
        name: name,
        deletedItemBehavior: BooruConfigDeletedItemBehavior.show.index,
        ratingFilter: filter.index,
      );

  static BooruConfigData? fromJson(Map<String, dynamic> json) {
    try {
      return BooruConfigData(
        booruId: json['booruId'] as int,
        apiKey: json['apiKey'] as String,
        login: json['login'] as String,
        booruUserId: json['booruUserId'] as int?,
        name: json['name'] as String,
        deletedItemBehavior: json['deletedItemBehavior'] as int,
        ratingFilter: json['ratingFilter'] as int,
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
    required String name,
    required BooruConfigRatingFilter filter,
    required BooruConfigDeletedItemBehavior deletedItemBehavior,
  }) {
    if (login == '') return null;
    if (apiKey == '') return null;
    if (booruUserId <= 0) return null;

    return BooruConfigData(
      booruId: booru.index,
      apiKey: apiKey,
      login: login,
      booruUserId: booruUserId,
      name: name,
      ratingFilter: filter.index,
      deletedItemBehavior: deletedItemBehavior.index,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'booruId': booruId,
      'apiKey': apiKey,
      'login': login,
      'booruUserId': booruUserId,
      'name': name,
      'deletedItemBehavior': deletedItemBehavior,
      'ratingFilter': ratingFilter,
    };
  }

  final int booruId;
  final String apiKey;
  final String login;
  final int? booruUserId;
  final String name;
  final int deletedItemBehavior;
  final int ratingFilter;
}

BooruConfig? convertToBooruConfig({
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
    name: booruConfigData.name,
    ratingFilter: BooruConfigRatingFilter.values[booruConfigData.ratingFilter],
    deletedItemBehavior: BooruConfigDeletedItemBehavior
        .values[booruConfigData.deletedItemBehavior],
  );
}
