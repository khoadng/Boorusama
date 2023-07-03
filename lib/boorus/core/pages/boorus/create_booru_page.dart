// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import 'package:boorusama/boorus/core/feats/boorus/boorus.dart';
import 'package:boorusama/boorus/core/pages/boorus/create_danbooru_config_page.dart';
import 'package:boorusama/boorus/core/provider.dart';
import 'package:boorusama/flutter.dart';
import 'create_gelbooru_config_page.dart';
import 'create_moebooru_config_page.dart';

class CreateBooruPage extends ConsumerStatefulWidget {
  const CreateBooruPage({
    super.key,
    required this.booru,
  });

  final Booru booru;

  @override
  ConsumerState<CreateBooruPage> createState() => _AddBooruPageState();
}

class _AddBooruPageState extends ConsumerState<CreateBooruPage> {
  var login = '';
  var apiKey = '';
  var configName = '';
  var ratingFilter = BooruConfigRatingFilter.none;
  var hideDeleted = false;

  BooruFactory get booruFactory => ref.read(booruFactoryProvider);

  @override
  Widget build(BuildContext context) {
    return switch (widget.booru.booruType) {
      BooruType.danbooru ||
      BooruType.aibooru ||
      BooruType.testbooru ||
      BooruType.e621 =>
        CreateDanbooruConfigPage(
          onLoginChanged: (value) => setState(() => login = value),
          onApiKeyChanged: (value) => setState(() => apiKey = value),
          onConfigNameChanged: (value) => setState(() => configName = value),
          onRatingFilterChanged: (value) =>
              setState(() => ratingFilter = value!),
          onHideDeletedChanged: (value) => setState(() => hideDeleted = value),
          onSubmit: allowSubmit() ? submit : null,
          booru: widget.booru,
        ),
      BooruType.safebooru || BooruType.e926 => CreateDanbooruConfigPage(
          onLoginChanged: (value) => setState(() => login = value),
          onApiKeyChanged: (value) => setState(() => apiKey = value),
          onConfigNameChanged: (value) => setState(() => configName = value),
          onHideDeletedChanged: (value) => setState(() => hideDeleted = value),
          onSubmit: allowSubmit() ? submit : null,
          booru: widget.booru,
        ),
      BooruType.konachan ||
      BooruType.yandere ||
      BooruType.lolibooru ||
      BooruType.sakugabooru =>
        CreateMoebooruConfigPage(
          onLoginChanged: (value) => setState(() => login = value),
          onHashedPasswordChanged: (value) => setState(() => apiKey = value),
          onConfigNameChanged: (value) => setState(() => configName = value),
          onRatingFilterChanged: (value) =>
              setState(() => ratingFilter = value!),
          onSubmit: allowSubmit() ? submit : null,
          booru: widget.booru,
          booruFactory: booruFactory,
        ),
      BooruType.gelbooru || BooruType.rule34xxx => CreateGelbooruConfigPage(
          onLoginChanged: (value) => setState(() => login = value),
          onApiKeyChanged: (value) => setState(() => apiKey = value),
          onConfigNameChanged: (value) => setState(() => configName = value),
          onRatingFilterChanged: (value) =>
              setState(() => ratingFilter = value!),
          onSubmit: allowSubmit() ? submit : null,
          booru: widget.booru,
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
    ref.read(booruConfigProvider.notifier).addFromAddBooruConfig(
          newConfig: AddNewBooruConfig(
            login: login,
            apiKey: apiKey,
            booru: widget.booru.booruType,
            configName: configName,
            hideDeleted: hideDeleted,
            ratingFilter: ratingFilter,
            url: widget.booru.url,
          ),
        );
    context.navigator.pop();
  }
}
