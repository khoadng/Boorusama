// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import 'package:boorusama/core/configs/configs.dart';
import 'package:boorusama/core/posts/posts.dart';
import 'package:boorusama/core/settings/settings.dart';
import 'package:boorusama/foundation/gestures.dart';
import 'types.dart';

final initialBooruConfigProvider = Provider.autoDispose<BooruConfig>(
  (ref) => throw UnimplementedError(),
);

final booruConfigDataProvider = StateProvider.autoDispose<BooruConfigData>(
  (ref) => ref.watch(initialBooruConfigProvider).toBooruConfigData(),
  dependencies: [initialBooruConfigProvider],
);

final authConfigDataProvider = StateProvider.autoDispose<AuthConfigData>(
  (ref) => ref.watch(booruConfigDataProvider.select(AuthConfigData.fromConfig)),
  dependencies: [booruConfigDataProvider],
);

final loginProvider = StateProvider.autoDispose<String?>(
  (ref) => ref.watch(authConfigDataProvider.select((value) => value.login)),
  dependencies: [authConfigDataProvider],
);

final apiKeyProvider = StateProvider.autoDispose<String?>(
  (ref) => ref.watch(authConfigDataProvider.select((value) => value.apiKey)),
  dependencies: [authConfigDataProvider],
);

final postGesturesConfigDataProvider =
    StateProvider.autoDispose<PostGestureConfig?>(
  (ref) => ref.watch(
      booruConfigDataProvider.select((value) => value.postGesturesConfigTyped)),
  dependencies: [booruConfigDataProvider],
);

final defaultPreviewImageButtonActionProvider =
    StateProvider.autoDispose<String?>(
  (ref) => ref.watch(booruConfigDataProvider
      .select((value) => value.defaultPreviewImageButtonAction)),
  dependencies: [booruConfigDataProvider],
);

final granularRatingFilterProvider = StateProvider.autoDispose<Set<Rating>?>(
  (ref) => ref.watch(booruConfigDataProvider
      .select((value) => value.granularRatingFilterTyped)),
  dependencies: [booruConfigDataProvider],
);

final defaultImageDetailsQualityProvider = StateProvider.autoDispose<String?>(
  (ref) => ref.watch(
      booruConfigDataProvider.select((value) => value.imageDetaisQuality)),
  dependencies: [booruConfigDataProvider],
);

final ratingFilterProvider =
    StateProvider.autoDispose<BooruConfigRatingFilter?>(
  (ref) => ref.watch(
      booruConfigDataProvider.select((value) => value.ratingFilterTyped)),
  dependencies: [booruConfigDataProvider],
);

final customBulkDownloadFileNameFormatProvider =
    StateProvider.autoDispose<String?>(
  (ref) => ref.watch(booruConfigDataProvider
      .select((value) => value.customBulkDownloadFileNameFormat)),
  dependencies: [booruConfigDataProvider],
);
final customDownloadFileNameFormatProvider = StateProvider.autoDispose<String?>(
  (ref) => ref.watch(booruConfigDataProvider
      .select((value) => value.customDownloadFileNameFormat)),
  dependencies: [booruConfigDataProvider],
);

final customDownloadLocationProvider = StateProvider.autoDispose<String?>(
  (ref) => ref.watch(
      booruConfigDataProvider.select((value) => value.customDownloadLocation)),
  dependencies: [booruConfigDataProvider],
);

final listingConfigsProvider = StateProvider.autoDispose<ListingConfigs?>(
  (ref) =>
      ref.watch(booruConfigDataProvider.select((value) => value.listingTyped)),
  dependencies: [booruConfigDataProvider],
);

final configNameProvider = StateProvider.autoDispose<String>(
  (ref) => ref.watch(booruConfigDataProvider.select((value) => value.name)),
  dependencies: [booruConfigDataProvider],
);

extension UpdateDataX on WidgetRef {
  void updateAuthConfigData(
    AuthConfigData data,
  ) =>
      read(authConfigDataProvider.notifier).state = data;

  void updateGesturesConfigData(
    PostGestureConfig? data,
  ) =>
      read(postGesturesConfigDataProvider.notifier).state = data;

  void updateRatingFilter(BooruConfigRatingFilter? data) =>
      read(ratingFilterProvider.notifier).state = data;

  void updateGranularRatingFilter(Set<Rating>? data) =>
      read(granularRatingFilterProvider.notifier).state = data;

  void updateDefaultPreviewImageButtonAction(String? data) =>
      read(defaultPreviewImageButtonActionProvider.notifier).state = data;

  void updateImageDetailsQuality(String? data) =>
      read(defaultImageDetailsQualityProvider.notifier).state = data;

  void updateCustomBulkDownloadFileNameFormat(String? data) =>
      read(customBulkDownloadFileNameFormatProvider.notifier).state = data;

  void updateCustomDownloadFileNameFormat(String? data) =>
      read(customDownloadFileNameFormatProvider.notifier).state = data;

  void updateCustomDownloadLocation(String? data) =>
      read(customDownloadLocationProvider.notifier).state = data;

  void updateListing(ListingConfigs? data) =>
      read(listingConfigsProvider.notifier).state = data;

  void updateName(String data) =>
      read(configNameProvider.notifier).state = data;

  void updateLoginAndApiKey(String login, String apiKey) {
    final auth = read(authConfigDataProvider);
    updateAuthConfigData(auth.copyWith(
      login: login,
      apiKey: apiKey,
    ));
  }

  void updateApiKey(String value) {
    final auth = read(authConfigDataProvider);
    updateAuthConfigData(auth.copyWith(apiKey: value));
  }

  void updatePassHash(String? value) {
    final auth = read(authConfigDataProvider);
    updateAuthConfigData(auth.copyWith(passHash: () => value));
  }

  void updateLogin(String value) {
    final auth = read(authConfigDataProvider);
    updateAuthConfigData(auth.copyWith(login: value));
  }
}
