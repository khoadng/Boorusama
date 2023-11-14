// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import 'package:boorusama/core/feats/boorus/boorus.dart';
import 'package:boorusama/core/pages/boorus/widgets/create_booru_config_name_field.dart';
import 'package:boorusama/core/pages/boorus/widgets/create_booru_login_field.dart';
import 'package:boorusama/core/pages/boorus/widgets/create_booru_passworld_field.dart';
import 'package:boorusama/core/pages/boorus/widgets/create_booru_post_details_resolution_option_tile.dart';
import 'package:boorusama/core/pages/boorus/widgets/create_booru_submit_button.dart';
import 'package:boorusama/core/pages/boorus/widgets/custom_download_file_name_section.dart';
import 'package:boorusama/core/pages/boorus/widgets/selected_booru_chip.dart';
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
  late var configName = widget.config.name;
  late String? customDownloadFileNameFormat =
      widget.config.customDownloadFileNameFormat;
  late var customBulkDownloadFileNameFormat =
      widget.config.customBulkDownloadFileNameFormat;
  late var imageDetaisQuality = widget.config.imageDetaisQuality;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: widget.backgroundColor,
      child: SafeArea(
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: SelectedBooruChip(
                    booruType: widget.config.booruType,
                    url: widget.config.url,
                  ),
                ),
                IconButton(
                  splashRadius: 20,
                  onPressed: context.navigator.pop,
                  icon: const Icon(Icons.close),
                ),
              ],
            ),
            const SizedBox(height: 8),
            CreateBooruConfigNameField(
              text: configName,
              onChanged: (value) => setState(() => configName = value),
            ),
            Expanded(
              child: DefaultTabController(
                length: 3,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    TabBar(
                      indicatorColor: context.colorScheme.primary,
                      tabs: const [
                        Tab(text: 'Authentication'),
                        Tab(text: 'Download'),
                        Tab(text: 'Misc'),
                      ],
                    ),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        child: TabBarView(
                          children: [
                            _buildAuthTab(),
                            _buildDownloadTab(),
                            _buildMiscTab(),
                          ],
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      child: CreateBooruSubmitButton(
                          onSubmit: allowSubmit() ? submit : null),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
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

  void submit() {
    final config = AddNewBooruConfig(
      login: login,
      apiKey: password,
      booru: widget.config.booruType,
      booruHint: widget.config.booruType,
      configName: configName,
      hideDeleted: false,
      ratingFilter: BooruConfigRatingFilter.none,
      url: widget.config.url,
      customDownloadFileNameFormat: customDownloadFileNameFormat,
      customBulkDownloadFileNameFormat: customBulkDownloadFileNameFormat,
      imageDetaisQuality: imageDetaisQuality,
    );

    ref
        .read(booruConfigProvider.notifier)
        .addOrUpdate(config: widget.config, newConfig: config);

    context.navigator.pop();
  }

  bool allowSubmit() {
    if (configName.isEmpty) return false;

    return (login.isNotEmpty && password.isNotEmpty) ||
        (login.isEmpty && password.isEmpty);
  }
}
