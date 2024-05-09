// Flutter imports:
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_symbols_icons/symbols.dart';

// Project imports:
import 'package:boorusama/core/feats/boorus/boorus.dart';
import 'package:boorusama/core/pages/boorus/widgets/create_booru_api_key_field.dart';
import 'package:boorusama/core/pages/boorus/widgets/create_booru_login_field.dart';
import 'package:boorusama/core/scaffolds/scaffolds.dart';
import 'package:boorusama/flutter.dart';
import 'package:boorusama/foundation/theme/theme.dart';

class CreateGelbooruConfigPage extends ConsumerStatefulWidget {
  const CreateGelbooruConfigPage({
    super.key,
    required this.config,
    this.backgroundColor,
    this.isNewConfig = false,
  });

  final BooruConfig config;
  final Color? backgroundColor;
  final bool isNewConfig;

  @override
  ConsumerState<CreateGelbooruConfigPage> createState() =>
      _CreateGelbooruConfigPageState();
}

class _CreateGelbooruConfigPageState
    extends ConsumerState<CreateGelbooruConfigPage> {
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
              labelText: 'User ID',
              hintText: '1234567',
              onChanged: (value) =>
                  this.auth.value = auth.copyWith(login: value),
            ),
          ),
          const SizedBox(height: 16),
          ValueListenableBuilder(
            valueListenable: auth,
            builder: (_, auth, __) => CreateBooruApiKeyField(
              text: auth.apiKey,
              hintText:
                  '2e89f79b593ed40fd8641235f002221374e50d6343d3afe1687fc70decae58dcf',
              onChanged: (value) =>
                  this.auth.value = auth.copyWith(apiKey: value),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '*Log in to your account on the browser, visit My Account > Options > API Access Credentials and fill the values manually.',
            style: context.textTheme.titleSmall?.copyWith(
              color: context.theme.hintColor,
              fontSize: 14,
              fontWeight: FontWeight.w400,
            ),
          ),
          const SizedBox(height: 16),
          const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('or',
                  style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16)),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              FilledButton.icon(
                style: FilledButton.styleFrom(
                  backgroundColor: context.colorScheme.secondaryContainer,
                ),
                onPressed: () => Clipboard.getData('text/plain').then(
                  (value) {
                    if (value == null) return;
                    final (uid, key) = extractValues(value.text);
                    auth.value = auth.value.copyWith(login: uid, apiKey: key);
                  },
                ),
                icon: Icon(
                  Symbols.content_paste,
                  color: context.colorScheme.onSecondaryContainer,
                ),
                label: Text(
                  'Paste from clipboard',
                  style: TextStyle(
                    color: context.colorScheme.onSecondaryContainer,
                  ),
                ),
              ),
            ],
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

(String uid, String key) extractValues(String? input) {
  if (input == null) return ('', '');
  Map<String, String> values = {};
  final exp = RegExp(r'&(\w+)=(\w+)');

  final matches = exp.allMatches(input);

  for (final match in matches) {
    final key = match.group(1);
    final value = match.group(2);
    if (key != null && value != null) {
      values[key] = value;
    }
  }

  return (values['user_id'] ?? '', values['api_key'] ?? '');
}
