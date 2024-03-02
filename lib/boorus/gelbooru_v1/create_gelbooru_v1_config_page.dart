// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import 'package:boorusama/core/feats/boorus/boorus.dart';
import 'package:boorusama/core/scaffolds/scaffolds.dart';
import 'package:boorusama/router.dart';

class CreateGelbooruV1ConfigPage extends ConsumerStatefulWidget {
  const CreateGelbooruV1ConfigPage({
    super.key,
    required this.config,
    this.backgroundColor,
  });

  final BooruConfig config;
  final Color? backgroundColor;

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _CreateGelbooruV1ConfigPageState();
}

class _CreateGelbooruV1ConfigPageState
    extends ConsumerState<CreateGelbooruV1ConfigPage> {
  @override
  Widget build(BuildContext context) {
    return CreateBooruConfigScaffold(
      backgroundColor: widget.backgroundColor,
      config: widget.config,
      hasDownloadTab: true,
      tabsBuilder: (context) => {},
      allowSubmit: allowSubmit,
      submit: submit,
    );
  }

  bool allowSubmit(CreateConfigData data) {
    return data.configName.isNotEmpty;
  }

  void submit(CreateConfigData data) {
    final config = AddNewBooruConfig(
      login: '',
      apiKey: '',
      booru: widget.config.booruType,
      booruHint: widget.config.booruType,
      configName: data.configName,
      hideDeleted: false,
      ratingFilter: BooruConfigRatingFilter.none,
      url: widget.config.url,
      customDownloadFileNameFormat: data.customDownloadFileNameFormat,
      customBulkDownloadFileNameFormat: data.customBulkDownloadFileNameFormat,
      imageDetaisQuality: data.imageDetaisQuality,
      granularRatingFilters: null,
      postGestures: data.postGestures,
      defaultPreviewImageButtonAction: data.defaultPreviewImageButtonAction,
    );

    ref
        .read(booruConfigProvider.notifier)
        .addOrUpdate(config: widget.config, newConfig: config);

    context.pop();
  }
}
