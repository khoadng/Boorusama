// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import 'package:boorusama/boorus/core/feats/boorus/boorus.dart';
import 'package:boorusama/boorus/core/pages/boorus/create_danbooru_config_page.dart';
import 'package:boorusama/boorus/core/provider.dart';
import 'package:boorusama/flutter.dart';
import 'package:boorusama/foundation/crypto.dart';
import 'create_gelbooru_config_page.dart';
import 'create_moebooru_config_page.dart';

class UpdateBooruPage extends ConsumerStatefulWidget {
  const UpdateBooruPage({
    super.key,
    required this.booruConfig,
  });

  final BooruConfig booruConfig;

  @override
  ConsumerState<UpdateBooruPage> createState() => _AddBooruPageState();
}

class _AddBooruPageState extends ConsumerState<UpdateBooruPage> {
  late var login = widget.booruConfig.login ?? '';
  late var apiKey = widget.booruConfig.apiKey ?? '';
  late var configName = widget.booruConfig.name;
  late var ratingFilter = widget.booruConfig.ratingFilter;
  late var hideDeleted = widget.booruConfig.deletedItemBehavior ==
      BooruConfigDeletedItemBehavior.hide;
  late BooruType booruType;
  late String url;
  late bool isUnkown;

  BooruFactory get booruFactory => ref.read(booruFactoryProvider);

  @override
  void initState() {
    booruType = widget.booruConfig.booruType;
    url = widget.booruConfig.url;
    isUnkown = widget.booruConfig.isUnverified();

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return switch (widget.booruConfig.booruType) {
      BooruType.danbooru ||
      BooruType.aibooru ||
      BooruType.testbooru ||
      BooruType.e621 =>
        CreateDanbooruConfigPage(
          initialApiKey: widget.booruConfig.apiKey,
          initialLogin: widget.booruConfig.login,
          initialConfigName: widget.booruConfig.name,
          initialRatingFilter: ratingFilter,
          initialHideDeleted: hideDeleted,
          onLoginChanged: (value) => setState(() => login = value),
          onApiKeyChanged: (value) => setState(() => apiKey = value),
          onConfigNameChanged: (value) => setState(() => configName = value),
          onRatingFilterChanged: (value) =>
              setState(() => ratingFilter = value!),
          onHideDeletedChanged: (value) => setState(() => hideDeleted = value),
          onSubmit: allowSubmit() ? submit : null,
          booruType: booruType,
          url: url,
          isUnkown: isUnkown,
        ),
      BooruType.safebooru || BooruType.e926 => CreateDanbooruConfigPage(
          initialApiKey: widget.booruConfig.apiKey,
          initialLogin: widget.booruConfig.login,
          initialConfigName: widget.booruConfig.name,
          initialRatingFilter: ratingFilter,
          initialHideDeleted: hideDeleted,
          onLoginChanged: (value) => setState(() => login = value),
          onApiKeyChanged: (value) => setState(() => apiKey = value),
          onConfigNameChanged: (value) => setState(() => configName = value),
          onHideDeletedChanged: (value) => setState(() => hideDeleted = value),
          onSubmit: allowSubmit() ? submit : null,
          booruType: booruType,
          url: url,
          isUnkown: isUnkown,
        ),
      BooruType.konachan ||
      BooruType.yandere ||
      BooruType.lolibooru ||
      BooruType.sakugabooru =>
        CreateMoebooruConfigPage(
          initialHashedPassword: widget.booruConfig.apiKey,
          initialLogin: widget.booruConfig.login,
          initialConfigName: widget.booruConfig.name,
          initialRatingFilter: ratingFilter,
          onLoginChanged: (value) => setState(() => login = value),
          onHashedPasswordChanged: (value) =>
              setState(() => apiKey = hashBooruPasswordSHA1(
                    booru: booruFactory.from(type: booruType),
                    booruFactory: booruFactory,
                    password: apiKey,
                  )),
          onConfigNameChanged: (value) => setState(() => configName = value),
          onRatingFilterChanged: (value) =>
              setState(() => ratingFilter = value!),
          onSubmit: allowSubmit() ? submit : null,
          booruType: booruType,
          url: url,
          booruFactory: booruFactory,
          isUnkown: isUnkown,
        ),
      BooruType.gelbooru || BooruType.rule34xxx => CreateGelbooruConfigPage(
          initialApiKey: widget.booruConfig.apiKey,
          initialLogin: widget.booruConfig.login,
          initialConfigName: widget.booruConfig.name,
          initialRatingFilter: ratingFilter,
          onLoginChanged: (value) => setState(() => login = value),
          onApiKeyChanged: (value) => setState(() => apiKey = value),
          onConfigNameChanged: (value) => setState(() => configName = value),
          onRatingFilterChanged: (value) =>
              setState(() => ratingFilter = value!),
          onSubmit: allowSubmit() ? submit : null,
          booruType: booruType,
          url: url,
          isUnkown: isUnkown,
        ),
      BooruType.unknown => const SizedBox(),
    };
  }

  bool allowSubmit() {
    if (configName.isEmpty) return false;

    return (login.isNotEmpty && apiKey.isNotEmpty) ||
        (login.isEmpty && apiKey.isEmpty);
  }

  void submit() {
    ref.read(booruConfigProvider.notifier).update(
          config: AddNewBooruConfig(
            login: login,
            apiKey: apiKey,
            booru: widget.booruConfig.booruType,
            booruHint: widget.booruConfig.booruType,
            configName: configName,
            hideDeleted: hideDeleted,
            ratingFilter: ratingFilter,
            url: widget.booruConfig.url,
          ),
          oldConfig: widget.booruConfig,
          id: widget.booruConfig.id,
          onSuccess: (booruConfig) =>
              ref.read(currentBooruConfigProvider.notifier).update(booruConfig),
        );
    context.navigator.pop();
  }
}
