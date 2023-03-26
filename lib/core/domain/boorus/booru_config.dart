// Package imports:
import 'package:equatable/equatable.dart';

class BooruConfig extends Equatable {
  const BooruConfig({
    required this.id,
    required this.booruId,
    required this.apiKey,
    required this.login,
    required this.booruUserId,
    required this.name,
    required this.ratingFilter,
    required this.deletedItemBehavior,
  });

  static const BooruConfig empty = BooruConfig(
    id: -1,
    booruId: -1,
    apiKey: null,
    login: null,
    booruUserId: -1,
    name: '',
    deletedItemBehavior: BooruConfigDeletedItemBehavior.show,
    ratingFilter: BooruConfigRatingFilter.none,
  );

  final int id;
  final int booruId;
  final String? apiKey;
  final String? login;
  final int? booruUserId;
  final String name;
  final BooruConfigDeletedItemBehavior deletedItemBehavior;
  final BooruConfigRatingFilter ratingFilter;

  @override
  List<Object?> get props => [
        id,
        booruId,
        apiKey,
        login,
        booruUserId,
        name,
        deletedItemBehavior,
        ratingFilter,
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

extension BooruConfigX on BooruConfig? {
  bool hasLoginDetails() {
    if (this == null) return false;
    if (this!.login == null || this!.apiKey == null) return false;
    if (this!.login!.isEmpty && this!.apiKey!.isEmpty) return false;
    if (this!.booruUserId == null) return false;

    return true;
  }
}
