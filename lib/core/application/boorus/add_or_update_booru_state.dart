// Package imports:
import 'package:equatable/equatable.dart';

// Project imports:
import 'package:boorusama/core/application/manage_booru_user_bloc.dart';
import 'package:boorusama/core/crypto.dart';
import 'package:boorusama/core/domain/boorus.dart';

class AddOrUpdateBooruState extends Equatable {
  final String login;
  final String apiKey;
  final String url;
  final String configName;
  final Booru selectedBooru;
  final BooruConfigRatingFilter ratingFilter;
  final bool revealKey;
  final BooruConfigDeletedItemBehavior deletedItemBehavior;

  const AddOrUpdateBooruState({
    required this.login,
    required this.apiKey,
    required this.url,
    required this.configName,
    required this.selectedBooru,
    required this.ratingFilter,
    required this.revealKey,
    required this.deletedItemBehavior,
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

  AddNewBooruConfig createNewBooruConfig() {
    final key = selectedBooru.loginType == LoginType.loginAndPasswordHashed
        ? hashBooruPasswordSHA1(
            booru: selectedBooru.booruType,
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
