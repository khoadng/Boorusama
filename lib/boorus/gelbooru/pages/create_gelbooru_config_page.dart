// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import 'package:boorusama/core/feats/boorus/boorus.dart';
import 'package:boorusama/core/pages/boorus/widgets/create_booru_api_key_field.dart';
import 'package:boorusama/core/pages/boorus/widgets/create_booru_config_name_field.dart';
import 'package:boorusama/core/pages/boorus/widgets/create_booru_custom_download_file_name_field.dart';
import 'package:boorusama/core/pages/boorus/widgets/create_booru_login_field.dart';
import 'package:boorusama/core/pages/boorus/widgets/create_booru_rating_options_tile.dart';
import 'package:boorusama/core/pages/boorus/widgets/create_booru_scaffold.dart';
import 'package:boorusama/core/pages/boorus/widgets/create_booru_submit_button.dart';
import 'package:boorusama/flutter.dart';

class CreateGelbooruConfigPage extends ConsumerStatefulWidget {
  const CreateGelbooruConfigPage({
    super.key,
    required this.config,
    this.backgroundColor,
  });

  final BooruConfig config;
  final Color? backgroundColor;

  @override
  ConsumerState<CreateGelbooruConfigPage> createState() =>
      _CreateGelbooruConfigPageState();
}

class _CreateGelbooruConfigPageState
    extends ConsumerState<CreateGelbooruConfigPage> {
  late var login = widget.config.login ?? '';
  late var apiKey = widget.config.apiKey ?? '';
  late var configName = widget.config.name;
  late var ratingFilter = widget.config.ratingFilter;
  late String? customDownloadFileNameFormat =
      widget.config.customDownloadFileNameFormat;

  @override
  Widget build(BuildContext context) {
    return CreateBooruScaffold(
      backgroundColor: widget.backgroundColor,
      booruType: widget.config.booruType,
      url: widget.config.url,
      isUnknown: widget.config.isUnverified(),
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
              const SizedBox(height: 16),
              CreateBooruLoginField(
                text: login,
                onChanged: (value) => setState(() => login = value),
                labelText: 'User ID',
                hintText: '1234567',
              ),
              const SizedBox(height: 16),
              CreateBooruApiKeyField(
                hintText:
                    '2e89f79b593ed40fd8641235f002221374e50d6343d3afe1687fc70decae58dcf',
                text: apiKey,
                onChanged: (value) => setState(() => apiKey = value),
              ),
              const SizedBox(height: 16),
              CreateBooruCustomDownloadFileNameField(
                format: customDownloadFileNameFormat,
                onChanged: (value) =>
                    setState(() => customDownloadFileNameFormat = value),
              ),
              const SizedBox(height: 16),
              CreateBooruRatingOptionsTile(
                value: ratingFilter,
                onChanged: (value) =>
                    value != null ? setState(() => ratingFilter = value) : null,
              ),
              const SizedBox(height: 16),
              CreateBooruSubmitButton(onSubmit: allowSubmit() ? submit : null),
            ],
          ),
        ),
      ],
    );
  }

  void submit() {
    final config = AddNewBooruConfig(
      login: login,
      apiKey: apiKey,
      booru: widget.config.booruType,
      booruHint: widget.config.booruType,
      configName: configName,
      hideDeleted: false,
      ratingFilter: ratingFilter,
      url: widget.config.url,
      customDownloadFileNameFormat: customDownloadFileNameFormat,
    );

    ref
        .read(booruConfigProvider.notifier)
        .addOrUpdate(config: widget.config, newConfig: config);

    context.navigator.pop();
  }

  bool allowSubmit() {
    if (configName.isEmpty) return false;

    return (login.isNotEmpty && apiKey.isNotEmpty) ||
        (login.isEmpty && apiKey.isEmpty);
  }
}
