// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_symbols_icons/symbols.dart';

// Project imports:
import '../../../core/configs/create.dart';
import '../../../core/foundation/clipboard.dart';

class GelbooruApiKeyField extends ConsumerWidget {
  const GelbooruApiKeyField({
    required this.controller,
    super.key,
  });

  final TextEditingController controller;
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return CreateBooruApiKeyField(
      controller: controller,
      hintText:
          'e.g. 2e89f79b593ed40fd8641235f002221374e50d6343d3afe1687fc70decae58dcf',
      onChanged: ref.editNotifier.updateApiKey,
    );
  }
}

class GelbooruLoginField extends ConsumerWidget {
  const GelbooruLoginField({
    required this.controller,
    super.key,
  });

  final TextEditingController controller;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return CreateBooruLoginField(
      controller: controller,
      labelText: 'User ID',
      hintText: 'e.g. 1234567',
      onChanged: ref.editNotifier.updateLogin,
    );
  }
}

class GelbooruConfigPasteFromClipboardButton extends ConsumerWidget {
  const GelbooruConfigPasteFromClipboardButton({
    required this.login,
    required this.apiKey,
    super.key,
  });

  final TextEditingController login;
  final TextEditingController apiKey;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return FilledButton.icon(
      style: FilledButton.styleFrom(
        backgroundColor: Theme.of(context).colorScheme.secondaryContainer,
      ),
      onPressed: () => AppClipboard.paste('text/plain').then(
        (value) {
          if (value == null) return;
          final (uid, key) = extractValues(value);
          ref.editNotifier.updateLoginAndApiKey(uid, key);

          login.text = uid;
          apiKey.text = key;
        },
      ),
      icon: Icon(
        Symbols.content_paste,
        color: Theme.of(context).colorScheme.onSecondaryContainer,
      ),
      label: Text(
        'Paste from clipboard',
        style: TextStyle(
          color: Theme.of(context).colorScheme.onSecondaryContainer,
        ),
      ),
    );
  }
}

(String uid, String key) extractValues(String? input) {
  if (input == null) return ('', '');
  final values = <String, String>{};
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
