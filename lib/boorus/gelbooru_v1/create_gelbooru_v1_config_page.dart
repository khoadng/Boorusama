// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import 'package:boorusama/core/feats/boorus/boorus.dart';
import 'package:boorusama/core/pages/boorus/widgets/create_booru_config_name_field.dart';
import 'package:boorusama/core/pages/boorus/widgets/create_booru_scaffold.dart';
import 'package:boorusama/core/pages/boorus/widgets/create_booru_submit_button.dart';
import 'package:boorusama/core/pages/boorus/widgets/custom_download_file_name_section.dart';
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
  late String configName = widget.config.name;
  late String? customDownloadFileNameFormat =
      widget.config.customDownloadFileNameFormat;
  late var customBulkDownloadFileNameFormat =
      widget.config.customBulkDownloadFileNameFormat;

  @override
  Widget build(BuildContext context) {
    return CreateBooruScaffold(
      backgroundColor: widget.backgroundColor,
      booruType: widget.config.booruType,
      url: widget.config.url,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 8,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              CreateBooruConfigNameField(
                text: configName,
                onChanged: (value) => setState(() => configName = value),
              ),
              const SizedBox(height: 8),
              CustomDownloadFileNameSection(
                config: widget.config,
                format: customDownloadFileNameFormat,
                onIndividualDownloadChanged: (value) =>
                    setState(() => customDownloadFileNameFormat = value),
                onBulkDownloadChanged: (value) =>
                    setState(() => customBulkDownloadFileNameFormat = value),
              ),
              const SizedBox(height: 16),
              CreateBooruSubmitButton(
                onSubmit: allowSubmit() ? submit : null,
              ),
            ],
          ),
        ),
      ],
    );
  }

  bool allowSubmit() {
    return configName.isNotEmpty;
  }

  void submit() {
    final config = AddNewBooruConfig(
      login: '',
      apiKey: '',
      booru: widget.config.booruType,
      booruHint: widget.config.booruType,
      configName: configName,
      hideDeleted: false,
      ratingFilter: BooruConfigRatingFilter.none,
      url: widget.config.url,
      customDownloadFileNameFormat: customDownloadFileNameFormat,
      customBulkDownloadFileNameFormat: customBulkDownloadFileNameFormat,
    );

    ref
        .read(booruConfigProvider.notifier)
        .addOrUpdate(config: widget.config, newConfig: config);

    context.pop();
  }
}
