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

  @override
  Widget build(BuildContext context) {
    return CreateBooruConfigScaffold(
      backgroundColor: widget.backgroundColor,
      config: widget.config,
      authTabBuilder: (context) => _buildAuthTab(),
      hasDownloadTab: true,
      hasRatingFilter: true,
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
          CreateBooruLoginField(
            text: login,
            labelText: 'User ID',
            hintText: '1234567',
            onChanged: (value) => setState(() => login = value),
          ),
          const SizedBox(height: 16),
          CreateBooruApiKeyField(
            text: apiKey,
            hintText:
                '2e89f79b593ed40fd8641235f002221374e50d6343d3afe1687fc70decae58dcf',
            onChanged: (value) => setState(() => apiKey = value),
          ),
          const SizedBox(height: 8),
          Text(
            '*Log in to your account on the browser, visit My Account > Options > API Access Credentials and fill the values manually.',
            style: context.textTheme.titleSmall!.copyWith(
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
                onPressed: () => Clipboard.getData('text/plain').then(
                  (value) {
                    if (value == null) return;
                    final (uid, key) = extractValues(value.text);
                    setState(() {
                      login = uid;
                      apiKey = key;
                    });
                  },
                ),
                icon: const Icon(Symbols.content_paste),
                label: const Text('Paste from clipboard'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void submit(CreateConfigData data) {
    final config = AddNewBooruConfig(
      login: login,
      apiKey: apiKey,
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
    );

    ref
        .read(booruConfigProvider.notifier)
        .addOrUpdate(config: widget.config, newConfig: config);

    context.navigator.pop();
  }

  bool allowSubmit(CreateConfigData data) {
    if (data.configName.isEmpty) return false;

    return (login.isNotEmpty && apiKey.isNotEmpty) ||
        (login.isEmpty && apiKey.isEmpty);
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
