// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_symbols_icons/symbols.dart';

// Project imports:
import 'package:boorusama/core/configs/create/create.dart';
import 'package:boorusama/foundation/clipboard.dart';
import 'package:boorusama/foundation/theme.dart';

class GelbooruApiKeyField extends ConsumerWidget {
  const GelbooruApiKeyField({
    super.key,
    required this.controller,
  });

  final TextEditingController controller;
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return CreateBooruApiKeyField(
      controller: controller,
      hintText:
          'e.g. 2e89f79b593ed40fd8641235f002221374e50d6343d3afe1687fc70decae58dcf',
      onChanged: ref.updateApiKey,
    );
  }
}

class GelbooruLoginField extends ConsumerWidget {
  const GelbooruLoginField({
    super.key,
    required this.controller,
  });

  final TextEditingController controller;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return CreateBooruLoginField(
      controller: controller,
      labelText: 'User ID',
      hintText: 'e.g. 1234567',
      onChanged: ref.updateLogin,
    );
  }
}

class GelbooruConfigPasteFromClipboardButton extends ConsumerWidget {
  const GelbooruConfigPasteFromClipboardButton({
    super.key,
    required this.login,
    required this.apiKey,
  });

  final TextEditingController login;
  final TextEditingController apiKey;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return FilledButton.icon(
      style: FilledButton.styleFrom(
        backgroundColor: context.colorScheme.secondaryContainer,
      ),
      onPressed: () => AppClipboard.paste('text/plain').then(
        (value) {
          if (value == null) return;
          final (uid, key) = extractValues(value);
          ref.updateLoginAndApiKey(uid, key);

          login.text = uid;
          apiKey.text = key;
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
    );
  }
}

(String uid, String key) extractValues(String? input) {
  if (input == null) return ('', '');
  final Map<String, String> values = {};
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
