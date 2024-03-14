// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import 'package:boorusama/core/feats/boorus/boorus.dart';
import 'package:boorusama/core/scaffolds/scaffolds.dart';
import 'package:boorusama/router.dart';

class CreateAnonConfigPage extends ConsumerStatefulWidget {
  const CreateAnonConfigPage({
    super.key,
    required this.config,
    this.backgroundColor,
    this.isNewConfig = false,
  });

  final BooruConfig config;
  final Color? backgroundColor;
  final bool isNewConfig;

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _CreateAnonConfigPageState();
}

class _CreateAnonConfigPageState extends ConsumerState<CreateAnonConfigPage> {
  @override
  Widget build(BuildContext context) {
    return CreateBooruConfigScaffold(
      isNewConfig: widget.isNewConfig,
      backgroundColor: widget.backgroundColor,
      config: widget.config,
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
      customDownloadFileNameFormat: null,
      customBulkDownloadFileNameFormat: null,
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
