// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:i18n/i18n.dart';
import 'package:material_symbols_icons/symbols.dart';

// Project imports:
import '../../../core/configs/auth/widgets.dart';
import '../../../core/configs/create/providers.dart';
import '../../../foundation/clipboard.dart';

const _exampleApiKey =
    '2e89f79b593ed40fd8641235f002221374e50d6343d3afe1687fc70decae58dcf';

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
      hintText: 'e.g. $_exampleApiKey',
      onChanged: ref.editNotifier.updateApiKey,
      autovalidateMode: AutovalidateMode.always,
      validator: _validateApiKeyInput,
    );
  }

  String? _validateApiKeyInput(String? value) {
    if (value?.isEmpty ?? true) return null;

    // Find the 64-character hex API key
    final apiKeyMatch = RegExp('[a-fA-F0-9]{16,}').firstMatch(value!);
    if (apiKeyMatch == null) return null;

    final apiKey = apiKeyMatch.group(0)!;

    // If input is exactly the API key, it's valid
    if (value.trim() == apiKey) return null;

    // Find what garbage is still in the string
    final garbageParts = <String>[];

    final keyStart = value.indexOf(apiKey);
    final keyEnd = keyStart + apiKey.length;

    // Garbage before the key
    if (keyStart > 0) {
      final before = value.substring(0, keyStart);
      garbageParts.add("'$before'");
    }

    // Garbage after the key
    if (keyEnd < value.length) {
      final after = value.substring(keyEnd);
      garbageParts.add("'$after'");
    }

    final removeText = garbageParts.join(' and ');
    final shortKey =
        '${apiKey.substring(0, 4)}...${apiKey.substring(apiKey.length - 4)}';

    return 'Invalid format. Remove $removeText - paste only the key value (Found: $shortKey)';
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
      autovalidateMode: AutovalidateMode.always,
      validator: (value) {
        if (value == null || value.isEmpty) return null;

        if (!RegExp(r'^\d+$').hasMatch(value)) {
          return 'User ID must contain only numbers';
        }

        return null;
      },
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
        context.t.booru.paste_from_clipboard,
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
