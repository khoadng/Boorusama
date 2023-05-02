// Package imports:
import 'package:equatable/equatable.dart';

// Project imports:
import 'package:boorusama/core/domain/boorus.dart';
import 'package:boorusama/core/infra/utils.dart';

class BooruConfig extends Equatable {
  const BooruConfig({
    required this.id,
    required this.booruId,
    required this.apiKey,
    required this.login,
    required this.name,
    required this.ratingFilter,
    required this.deletedItemBehavior,
    required this.url,
  });

  static const BooruConfig empty = BooruConfig(
    id: -1,
    booruId: -1,
    apiKey: null,
    login: null,
    name: '',
    deletedItemBehavior: BooruConfigDeletedItemBehavior.show,
    ratingFilter: BooruConfigRatingFilter.none,
    url: '',
  );

  final int id;
  final int booruId;
  final String url;
  final String? apiKey;
  final String? login;
  final String name;
  final BooruConfigDeletedItemBehavior deletedItemBehavior;
  final BooruConfigRatingFilter ratingFilter;

  @override
  List<Object?> get props => [
        id,
        booruId,
        apiKey,
        login,
        name,
        deletedItemBehavior,
        ratingFilter,
        url,
      ];
}

enum BooruConfigDeletedItemBehavior {
  show,
  hide,
}

enum BooruConfigRatingFilter {
  none,
  hideExplicit,
  hideNSFW,
}

extension BooruConfigRatingFilterX on BooruConfigRatingFilter {
  String getRatingTerm() {
    switch (this) {
      case BooruConfigRatingFilter.none:
        return 'None';
      case BooruConfigRatingFilter.hideExplicit:
        return 'Safeish';
      case BooruConfigRatingFilter.hideNSFW:
        return 'Safe';
    }
  }

  String getFilterRatingTerm() {
    switch (this) {
      case BooruConfigRatingFilter.none:
        return 'None';
      case BooruConfigRatingFilter.hideExplicit:
        return 'Moderate';
      case BooruConfigRatingFilter.hideNSFW:
        return 'Aggressive';
    }
  }
}

extension BooruConfigNullX on BooruConfig? {
  bool hasLoginDetails() {
    if (this == null) return false;
    if (this!.login == null || this!.apiKey == null) return false;
    if (this!.login!.isEmpty && this!.apiKey!.isEmpty) return false;

    return true;
  }
}

extension BooruConfigX on BooruConfig {
  Booru createBooruFrom(BooruFactory factory) =>
      factory.from(type: intToBooruType(booruId));

  bool isUnverified(Booru booru) => booru.url != url;

  String getIconUrl({
    int? size,
  }) =>
      getFavicon(url, size: size);
}
