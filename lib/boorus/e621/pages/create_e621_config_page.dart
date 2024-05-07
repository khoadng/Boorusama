// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import 'package:boorusama/core/feats/boorus/boorus.dart';
import 'package:boorusama/core/pages/boorus/widgets/create_booru_api_key_field.dart';
import 'package:boorusama/core/pages/boorus/widgets/create_booru_login_field.dart';
import 'package:boorusama/core/scaffolds/scaffolds.dart';
import 'package:boorusama/flutter.dart';
import 'package:boorusama/foundation/i18n.dart';

class CreateE621ConfigPage extends ConsumerStatefulWidget {
  const CreateE621ConfigPage({
    super.key,
    this.backgroundColor,
    required this.config,
    this.isNewConfig = false,
  });

  final Color? backgroundColor;
  final BooruConfig config;
  final bool isNewConfig;

  @override
  ConsumerState<CreateE621ConfigPage> createState() =>
      _CreateDanbooruConfigPageState();
}

class _CreateDanbooruConfigPageState
    extends ConsumerState<CreateE621ConfigPage> {
  late final auth = ValueNotifier(AuthConfigData.fromConfig(widget.config));

  @override
  Widget build(BuildContext context) {
    return CreateBooruConfigScaffold(
      isNewConfig: widget.isNewConfig,
      backgroundColor: widget.backgroundColor,
      config: widget.config,
      authTab: _buildAuthTab(),
      hasDownloadTab: true,
      hasRatingFilter: true,
      tabsBuilder: (context) => {},
      allowSubmit: defaultAllowSubmitWithAuth(auth.value),
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
          ValueListenableBuilder(
            valueListenable: auth,
            builder: (_, auth, __) => CreateBooruLoginField(
              text: auth.login,
              labelText: 'booru.login_name_label'.tr(),
              hintText: 'e.g: my_login',
              onChanged: (value) =>
                  this.auth.value = auth.copyWith(login: value),
            ),
          ),
          const SizedBox(height: 16),
          ValueListenableBuilder(
            valueListenable: auth,
            builder: (_, auth, __) => CreateBooruApiKeyField(
              text: auth.apiKey,
              hintText: 'e.g: o6H5u8QrxC7dN3KvF9D2bM4p',
              onChanged: (value) =>
                  this.auth.value = auth.copyWith(apiKey: value),
            ),
          ),
        ],
      ),
    );
  }

  void submit(CreateConfigData data) {
    final config = AddNewBooruConfig(
      login: auth.value.login,
      apiKey: auth.value.apiKey,
      booru: widget.config.booruType,
      booruHint: widget.config.booruType,
      configName: data.configName,
      hideDeleted: false,
      ratingFilter: data.ratingFilter ?? BooruConfigRatingFilter.none,
      url: widget.config.url,
      customDownloadFileNameFormat: data.customDownloadFileNameFormat,
      customBulkDownloadFileNameFormat: data.customBulkDownloadFileNameFormat,
      imageDetaisQuality: data.imageDetaisQuality,
      granularRatingFilters: data.granularRatingFilters,
      postGestures: data.postGestures,
      defaultPreviewImageButtonAction: data.defaultPreviewImageButtonAction,
    );

    ref
        .read(booruConfigProvider.notifier)
        .addOrUpdate(config: widget.config, newConfig: config);

    context.navigator.pop();
  }
}
