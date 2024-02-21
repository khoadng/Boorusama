// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import 'package:boorusama/core/feats/boorus/boorus.dart';
import 'package:boorusama/core/pages/boorus/widgets/create_booru_login_field.dart';
import 'package:boorusama/core/pages/boorus/widgets/create_booru_passworld_field.dart';
import 'package:boorusama/core/pages/boorus/widgets/create_booru_post_details_resolution_option_tile.dart';
import 'package:boorusama/core/pages/boorus/widgets/custom_download_file_name_section.dart';
import 'package:boorusama/core/scaffolds/scaffolds.dart';
import 'package:boorusama/flutter.dart';
import 'package:boorusama/foundation/i18n.dart';
import 'package:boorusama/foundation/theme/theme.dart';

class CreateSankakuConfigPage extends ConsumerStatefulWidget {
  const CreateSankakuConfigPage({
    super.key,
    this.backgroundColor,
    required this.config,
  });

  final Color? backgroundColor;
  final BooruConfig config;

  @override
  ConsumerState<CreateSankakuConfigPage> createState() =>
      _CreateDanbooruConfigPageState();
}

class _CreateDanbooruConfigPageState
    extends ConsumerState<CreateSankakuConfigPage> {
  late var login = widget.config.login ?? '';
  late var password = widget.config.apiKey ?? '';
  late String? customDownloadFileNameFormat =
      widget.config.customDownloadFileNameFormat;
  late var customBulkDownloadFileNameFormat =
      widget.config.customBulkDownloadFileNameFormat;
  late var imageDetaisQuality = widget.config.imageDetaisQuality;

  @override
  Widget build(BuildContext context) {
    return CreateBooruConfigScaffold(
      backgroundColor: widget.backgroundColor,
      config: widget.config,
      tabsBuilder: (context) => {
        'Authentication': _buildAuthTab(),
        'Download': _buildDownloadTab(),
        'Misc': _buildMiscTab(),
      },
      allowSubmit: allowSubmit,
      submit: submit,
    );
  }

  Widget _buildDownloadTab() {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CustomDownloadFileNameSection(
            config: widget.config,
            format: customDownloadFileNameFormat,
            onIndividualDownloadChanged: (value) =>
                setState(() => customDownloadFileNameFormat = value),
            onBulkDownloadChanged: (value) =>
                setState(() => customBulkDownloadFileNameFormat = value),
          ),
        ],
      ),
    );
  }

  Widget _buildMiscTab() {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const SizedBox(height: 16),
          CreateBooruGeneralPostDetailsResolutionOptionTile(
            value: imageDetaisQuality,
            onChanged: (value) => setState(() => imageDetaisQuality = value),
          ),
        ],
      ),
    );
  }

  Widget _buildAuthTab() {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const SizedBox(height: 24),
          CreateBooruLoginField(
            text: login,
            labelText: 'booru.login_name_label'.tr(),
            hintText: 'e.g: my_login',
            onChanged: (value) => setState(() => login = value),
          ),
          const SizedBox(height: 16),
          CreateBooruPasswordField(
            text: password,
            onChanged: (value) => setState(() => password = value),
          ),
          const SizedBox(height: 8),
          Text(
            '*Without login credentials, some features may not work.',
            style: context.textTheme.titleSmall!.copyWith(
              color: context.theme.hintColor,
              fontSize: 14,
              fontWeight: FontWeight.w400,
            ),
          ),
        ],
      ),
    );
  }

  void submit(CreateConfigData data) {
    final config = AddNewBooruConfig(
      login: login,
      apiKey: password,
      booru: widget.config.booruType,
      booruHint: widget.config.booruType,
      configName: data.configName,
      hideDeleted: false,
      ratingFilter: BooruConfigRatingFilter.none,
      url: widget.config.url,
      customDownloadFileNameFormat: customDownloadFileNameFormat,
      customBulkDownloadFileNameFormat: customBulkDownloadFileNameFormat,
      imageDetaisQuality: imageDetaisQuality,
      granularRatingFilters: null,
    );

    ref
        .read(booruConfigProvider.notifier)
        .addOrUpdate(config: widget.config, newConfig: config);

    context.navigator.pop();
  }

  bool allowSubmit(CreateConfigData data) {
    if (data.configName.isEmpty) return false;

    return (login.isNotEmpty && password.isNotEmpty) ||
        (login.isEmpty && password.isEmpty);
  }
}
