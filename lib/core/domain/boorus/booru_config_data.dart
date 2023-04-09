// Project imports:
import 'package:boorusama/core/domain/boorus.dart';

class BooruConfigData {
  const BooruConfigData({
    required this.booruId,
    required this.apiKey,
    required this.login,
    required this.name,
    required this.deletedItemBehavior,
    required this.ratingFilter,
    required this.url,
  });

  factory BooruConfigData.anonymous({
    required BooruType booru,
    required String name,
    required BooruConfigRatingFilter filter,
    required String url,
  }) =>
      BooruConfigData(
        booruId: booru.index,
        apiKey: '',
        login: '',
        url: url,
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
        url: json['url'] as String,
        name: json['name'] as String,
        deletedItemBehavior: json['deletedItemBehavior'] as int,
        ratingFilter: json['ratingFilter'] as int,
      );
    } catch (e) {
      return null;
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'booruId': booruId,
      'apiKey': apiKey,
      'login': login,
      'url': url,
      'name': name,
      'deletedItemBehavior': deletedItemBehavior,
      'ratingFilter': ratingFilter,
    };
  }

  final int booruId;
  final String apiKey;
  final String login;
  final String name;
  final int deletedItemBehavior;
  final int ratingFilter;
  final String url;
}

BooruConfig? convertToBooruConfig({
  required int? id,
  required BooruConfigData? booruConfigData,
}) {
  if (booruConfigData == null || id == null) return null;

  return BooruConfig(
    id: id,
    booruId: booruConfigData.booruId,
    apiKey: booruConfigData.apiKey.isEmpty ? null : booruConfigData.apiKey,
    login: booruConfigData.login.isEmpty ? null : booruConfigData.login,
    url: booruConfigData.url,
    name: booruConfigData.name,
    ratingFilter: BooruConfigRatingFilter.values[booruConfigData.ratingFilter],
    deletedItemBehavior: BooruConfigDeletedItemBehavior
        .values[booruConfigData.deletedItemBehavior],
  );
}
