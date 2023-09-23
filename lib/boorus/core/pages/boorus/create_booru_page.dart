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

class CreateBooruPage extends ConsumerStatefulWidget {
  const CreateBooruPage({
    super.key,
    required this.url,
    required this.booruType,
    this.backgroundColor,
  });

  final String url;
  final BooruType booruType;
  final Color? backgroundColor;

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
    return switch (widget.booruType) {
      BooruType.danbooru ||
      BooruType.aibooru ||
      BooruType.testbooru ||
      BooruType.e621 =>
        CreateDanbooruConfigPage(
          initialRatingFilter: ratingFilter,
          initialHideDeleted: hideDeleted,
          backgroundColor: widget.backgroundColor,
          onLoginChanged: (value) => setState(() => login = value),
          onApiKeyChanged: (value) => setState(() => apiKey = value),
          onConfigNameChanged: (value) => setState(() => configName = value),
          onRatingFilterChanged: (value) =>
              setState(() => ratingFilter = value!),
          onHideDeletedChanged: (value) => setState(() => hideDeleted = value),
          onSubmit: allowSubmit() ? submit : null,
          booruType: widget.booruType,
          url: widget.url,
        ),
      BooruType.safebooru || BooruType.e926 => CreateDanbooruConfigPage(
          initialRatingFilter: ratingFilter,
          initialHideDeleted: hideDeleted,
          backgroundColor: widget.backgroundColor,
          onLoginChanged: (value) => setState(() => login = value),
          onApiKeyChanged: (value) => setState(() => apiKey = value),
          onConfigNameChanged: (value) => setState(() => configName = value),
          onHideDeletedChanged: (value) => setState(() => hideDeleted = value),
          onSubmit: allowSubmit() ? submit : null,
          booruType: widget.booruType,
          url: widget.url,
        ),
      BooruType.gelbooru || BooruType.rule34xxx => CreateGelbooruConfigPage(
          initialRatingFilter: ratingFilter,
          backgroundColor: widget.backgroundColor,
          onLoginChanged: (value) => setState(() => login = value),
          onApiKeyChanged: (value) => setState(() => apiKey = value),
          onConfigNameChanged: (value) => setState(() => configName = value),
          onRatingFilterChanged: (value) =>
              setState(() => ratingFilter = value!),
          onSubmit: allowSubmit() ? submit : null,
          booruType: widget.booruType,
          url: widget.url,
        ),
      BooruType.zerochan ||
      BooruType.konachan ||
      BooruType.yandere ||
      BooruType.lolibooru ||
      BooruType.sakugabooru ||
      BooruType.unknown =>
        const SizedBox(),
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
            booru: widget.booruType,
            booruHint: widget.booruType,
            configName: configName,
            hideDeleted: hideDeleted,
            ratingFilter: ratingFilter,
            url: widget.url,
          ),
        );
    context.navigator.pop();
  }
}
