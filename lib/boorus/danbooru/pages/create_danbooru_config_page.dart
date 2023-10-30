// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import 'package:boorusama/core/feats/boorus/boorus.dart';
import 'package:boorusama/core/pages/boorus/widgets/create_booru_api_key_field.dart';
import 'package:boorusama/core/pages/boorus/widgets/create_booru_config_name_field.dart';
import 'package:boorusama/core/pages/boorus/widgets/create_booru_custom_download_file_name_field.dart';
import 'package:boorusama/core/pages/boorus/widgets/create_booru_hide_deleted_switch.dart';
import 'package:boorusama/core/pages/boorus/widgets/create_booru_login_field.dart';
import 'package:boorusama/core/pages/boorus/widgets/create_booru_rating_options_tile.dart';
import 'package:boorusama/core/pages/boorus/widgets/create_booru_submit_button.dart';
import 'package:boorusama/core/pages/boorus/widgets/selected_booru_chip.dart';
import 'package:boorusama/flutter.dart';
import 'package:boorusama/foundation/i18n.dart';
import 'package:boorusama/foundation/theme/theme.dart';

class CreateDanbooruConfigPage extends ConsumerStatefulWidget {
  const CreateDanbooruConfigPage({
    super.key,
    this.backgroundColor,
    required this.config,
    required this.defaultFilenameFormat,
  });

  final Color? backgroundColor;
  final BooruConfig config;
  final String defaultFilenameFormat;

  @override
  ConsumerState<CreateDanbooruConfigPage> createState() =>
      _CreateDanbooruConfigPageState();
}

class _CreateDanbooruConfigPageState
    extends ConsumerState<CreateDanbooruConfigPage> {
  late var login = widget.config.login ?? '';
  late var apiKey = widget.config.apiKey ?? '';
  late var configName = widget.config.name;
  late var ratingFilter = widget.config.ratingFilter;
  late var hideDeleted =
      widget.config.deletedItemBehavior == BooruConfigDeletedItemBehavior.hide;
  late String? customDownloadFileNameFormat =
      widget.config.customDownloadFileNameFormat;
  late var customBulkDownloadFileNameFormat =
      widget.config.customBulkDownloadFileNameFormat;

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

            // 2 tabs
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

  Widget _buildMiscTab() {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const SizedBox(height: 16),
          CreateBooruRatingOptionsTile(
            value: ratingFilter,
            onChanged: (value) =>
                value != null ? setState(() => ratingFilter = value) : null,
          ),
          const SizedBox(height: 16),
          CreateBooruHideDeletedSwitch(
              value: hideDeleted,
              onChanged: (value) => setState(() => hideDeleted = value),
              subtitle: Text(
                'Hide low-quality images, some decent ones might also be hidden.',
                style: context.textTheme.titleSmall!.copyWith(
                  color: context.theme.hintColor,
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                ),
              )),
        ],
      ),
    );
  }

  Widget _buildDownloadTab() {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CreateBooruCustomDownloadFileNameField(
            config: widget.config,
            format: customDownloadFileNameFormat,
            defaultFormat: widget.defaultFilenameFormat,
            onSingleDownloadChanged: (value) =>
                setState(() => customDownloadFileNameFormat = value),
            onBulkDownloadChanged: (value) =>
                setState(() => customBulkDownloadFileNameFormat = value),
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
          CreateBooruApiKeyField(
            text: apiKey,
            hintText: 'e.g: o6H5u8QrxC7dN3KvF9D2bM4p',
            onChanged: (value) => setState(() => apiKey = value),
          ),
          const SizedBox(height: 8),
          Text(
            '*Log in to your account on the browser, visit My Account > API Key. Copy your key or create a new one if needed, ensuring all permissions are enabled for proper app functionality.',
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
      apiKey: apiKey,
      booru: widget.config.booruType,
      booruHint: widget.config.booruType,
      configName: configName,
      hideDeleted: hideDeleted,
      ratingFilter: ratingFilter,
      url: widget.config.url,
      customDownloadFileNameFormat: customDownloadFileNameFormat,
      customBulkDownloadFileNameFormat: customBulkDownloadFileNameFormat,
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
