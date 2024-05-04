// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import 'package:boorusama/core/feats/boorus/boorus.dart';
import 'package:boorusama/core/pages/boorus/widgets/create_booru_api_key_field.dart';
import 'package:boorusama/core/pages/boorus/widgets/create_booru_post_details_resolution_option_tile.dart';
import 'package:boorusama/core/scaffolds/scaffolds.dart';
import 'package:boorusama/foundation/theme/theme.dart';
import 'package:boorusama/router.dart';
import 'philomena_post.dart';

class CreatePhilomenaConfigPage extends ConsumerStatefulWidget {
  const CreatePhilomenaConfigPage({
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
      _CreatePhilomenaConfigPageState();
}

class _CreatePhilomenaConfigPageState
    extends ConsumerState<CreatePhilomenaConfigPage> {
  late String key = widget.config.apiKey ?? '';
  late var imageDetaisQuality = widget.config.imageDetaisQuality;

  @override
  Widget build(BuildContext context) {
    return CreateBooruConfigScaffold(
      isNewConfig: widget.isNewConfig,
      backgroundColor: widget.backgroundColor,
      config: widget.config,
      authTab: _buildAuthTab(),
      postDetailsResolutionBuilder: (context) =>
          CreateBooruImageDetailsResolutionOptionTile(
        value: imageDetaisQuality,
        items:
            PhilomenaPostQualityType.values.map((e) => e.stringify()).toList(),
        onChanged: (value) => setState(() => imageDetaisQuality = value),
      ),
      tabsBuilder: (context) => {},
      allowSubmit: allowSubmit,
      submit: submit,
    );
  }

  Widget _buildAuthTab() {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const SizedBox(height: 24),
          CreateBooruApiKeyField(
            text: key,
            hintText: 'e.g: AC8gZrxKsDpWy3unU0jB',
            onChanged: (value) => setState(() => key = value),
          ),
          const SizedBox(height: 8),
          Text(
            '*You can find your authentication token in your account settings in the browser',
            style: context.textTheme.titleSmall?.copyWith(
              color: context.theme.hintColor,
              fontSize: 14,
              fontWeight: FontWeight.w400,
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  bool allowSubmit(CreateConfigData data) {
    return data.configName.isNotEmpty;
  }

  void submit(CreateConfigData data) {
    final config = AddNewBooruConfig(
      login: '',
      apiKey: key,
      booru: widget.config.booruType,
      booruHint: widget.config.booruType,
      configName: data.configName,
      hideDeleted: false,
      ratingFilter: BooruConfigRatingFilter.none,
      url: widget.config.url,
      customDownloadFileNameFormat: null,
      customBulkDownloadFileNameFormat: null,
      imageDetaisQuality: imageDetaisQuality,
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
