// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:foundation/foundation.dart';
import 'package:material_symbols_icons/symbols.dart';

// Project imports:
import '../../../core/boorus/booru/booru.dart';
import '../../../core/boorus/booru/providers.dart';
import '../../../core/configs/config.dart';
import '../../../core/configs/create.dart';
import 'config_hashing.dart';

class MoebooruPasswordField extends ConsumerStatefulWidget {
  const MoebooruPasswordField({
    super.key,
    this.hintText,
    this.controller,
  });

  final String? hintText;
  final TextEditingController? controller;

  @override
  ConsumerState<MoebooruPasswordField> createState() =>
      _MoebooruPasswordFieldState();
}

class _MoebooruPasswordFieldState extends ConsumerState<MoebooruPasswordField> {
  var password = '';

  late final passwordController = widget.controller ?? TextEditingController();

  BooruFactory get booruFactory => ref.read(booruFactoryProvider);

  @override
  void dispose() {
    super.dispose();
    if (widget.controller == null) {
      passwordController.dispose();
    }
  }

  @override
  Widget build(BuildContext context) {
    final config = ref.watch(initialBooruConfigProvider);

    return CreateBooruApiKeyField(
      controller: passwordController,
      labelText: 'booru.password_label'.tr(),
      onChanged: (value) => setState(() {
        if (value.isEmpty) {
          ref.editNotifier.updateApiKey(value);
          return;
        }

        password = value;
        final hashed = hashBooruPasswordSHA1(
          url: config.url,
          booru: config.auth.createBooruFrom(booruFactory),
          password: value,
        );
        ref.editNotifier.updateApiKey(hashed);
      }),
    );
  }
}

class MoebooruHashedPasswordField extends ConsumerWidget {
  const MoebooruHashedPasswordField({
    required this.passwordController,
    super.key,
  });

  final TextEditingController passwordController;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final hashedPassword = ref.watch(
      editBooruConfigProvider(
        ref.watch(editBooruConfigIdProvider),
      ).select((value) => value.apiKey),
    );

    return hashedPassword.isNotEmpty
        ? Padding(
            padding: const EdgeInsets.all(8),
            child: Row(
              children: [
                FaIcon(
                  FontAwesomeIcons.hashtag,
                  size: 16,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    hashedPassword,
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w800,
                        ),
                  ),
                ),
                IconButton(
                  splashRadius: 12,
                  onPressed: () {
                    ref.editNotifier.updateApiKey('');
                    passwordController.clear();
                  },
                  icon: const Icon(Symbols.close),
                ),
              ],
            ),
          )
        : const SizedBox.shrink();
  }
}
