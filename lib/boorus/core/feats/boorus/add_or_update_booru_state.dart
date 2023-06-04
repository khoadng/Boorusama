// Package imports:
import 'package:equatable/equatable.dart';

// Project imports:
import 'package:boorusama/boorus/core/feats/boorus/boorus.dart';
import 'package:boorusama/foundation/crypto.dart';

class AddOrUpdateBooruState extends Equatable {
  final String login;
  final String apiKey;
  final String url;
  final String configName;
  final Booru selectedBooru;
  final BooruConfigRatingFilter ratingFilter;
  final bool revealKey;
  final BooruConfigDeletedItemBehavior deletedItemBehavior;
  final bool unverifiedBooru;

  const AddOrUpdateBooruState({
    required this.login,
    required this.apiKey,
    required this.url,
    required this.configName,
    required this.selectedBooru,
    required this.ratingFilter,
    required this.revealKey,
    required this.deletedItemBehavior,
    required this.unverifiedBooru,
  });

  factory AddOrUpdateBooruState.initial(BooruFactory factory) =>
      AddOrUpdateBooruState(
        login: '',
        apiKey: '',
        url: '',
        configName: '',
        selectedBooru: factory.from(type: BooruType.unknown),
        ratingFilter: BooruConfigRatingFilter.hideNSFW,
        revealKey: false,
        deletedItemBehavior: BooruConfigDeletedItemBehavior.hide,
        unverifiedBooru: false,
      );

  factory AddOrUpdateBooruState.fromConfig({
    required BooruConfig config,
    required BooruFactory factory,
  }) =>
      AddOrUpdateBooruState(
        login: config.login ?? '',
        apiKey: config.apiKey ?? '',
        url: config.url,
        configName: config.name,
        selectedBooru: config.createBooruFrom(factory),
        ratingFilter: config.ratingFilter,
        revealKey: false,
        deletedItemBehavior: config.deletedItemBehavior,
        unverifiedBooru: false,
      );

  AddOrUpdateBooruState copyWith({
    String? login,
    String? apiKey,
    String? url,
    String? configName,
    Booru? selectedBooru,
    BooruConfigRatingFilter? ratingFilter,
    bool? revealKey,
    BooruConfigDeletedItemBehavior? deletedItemBehavior,
    bool? unverifiedBooru,
  }) =>
      AddOrUpdateBooruState(
        login: login ?? this.login,
        apiKey: apiKey ?? this.apiKey,
        url: url ?? this.url,
        configName: configName ?? this.configName,
        selectedBooru: selectedBooru ?? this.selectedBooru,
        ratingFilter: ratingFilter ?? this.ratingFilter,
        revealKey: revealKey ?? this.revealKey,
        deletedItemBehavior: deletedItemBehavior ?? this.deletedItemBehavior,
        unverifiedBooru: unverifiedBooru ?? this.unverifiedBooru,
      );

  @override
  List<Object?> get props => [
        login,
        apiKey,
        url,
        configName,
        selectedBooru,
        ratingFilter,
        revealKey,
        deletedItemBehavior,
        unverifiedBooru,
      ];
}

extension AddOrUpdateBooruStateExtensions on AddOrUpdateBooruState {
  bool allowSubmit() {
    if (selectedBooru.booruType == BooruType.unknown) return false;
    if (configName.isEmpty) return false;
    if (url.isEmpty) return false;

    return (login.isNotEmpty && apiKey.isNotEmpty) ||
        (login.isEmpty && apiKey.isEmpty);
  }

  bool supportRatingFilter() => selectedBooru.booruType != BooruType.safebooru;
  bool supportHideDeleted() => selectedBooru.booruType != BooruType.gelbooru;

  bool _shouldGenetateHashedPassword() =>
      selectedBooru.loginType == LoginType.loginAndPasswordHashed &&
      apiKey.isNotEmpty;

  AddNewBooruConfig createNewBooruConfig(BooruFactory booruFactory) {
    final key = _shouldGenetateHashedPassword()
        ? hashBooruPasswordSHA1(
            booru: selectedBooru,
            booruFactory: booruFactory,
            password: apiKey,
          )
        : apiKey;

    return AddNewBooruConfig(
      login: login,
      apiKey: key,
      booru: selectedBooru.booruType,
      configName: configName,
      hideDeleted: deletedItemBehavior == BooruConfigDeletedItemBehavior.hide,
      ratingFilter: ratingFilter,
      url: url,
    );
  }
}
