// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_symbols_icons/symbols.dart';

// Project imports:
import 'package:boorusama/boorus/providers.dart';
import 'package:boorusama/core/configs/configs.dart';
import 'package:boorusama/core/configs/create/create.dart';
import 'package:boorusama/foundation/theme.dart';

class CreateAnimePicturesConfigPage extends ConsumerWidget {
  const CreateAnimePicturesConfigPage({
    super.key,
    this.backgroundColor,
    this.initialTab,
  });

  final Color? backgroundColor;
  final String? initialTab;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final editId = ref.watch(editBooruConfigIdProvider);

    return CreateBooruConfigScaffold(
      backgroundColor: backgroundColor,
      initialTab: initialTab,
      authTab: AnimePicturesAuthView(),
      footer: editId.isNew
          ? Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 8,
              ),
              decoration: BoxDecoration(
                color: context.theme.colorScheme.secondaryContainer,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(12),
                  topRight: Radius.circular(12),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Symbols.info,
                    size: 16,
                    color: context.theme.colorScheme.error,
                  ),
                  const SizedBox(width: 8),
                  Flexible(
                    child: Text(
                      "Bulk download and blacklist won't work for this booru.",
                      style: context.textTheme.bodySmall,
                    ),
                  ),
                ],
              ),
            )
          : null,
    );
  }
}

class AnimePicturesAuthView extends ConsumerStatefulWidget {
  const AnimePicturesAuthView({super.key});

  @override
  ConsumerState<AnimePicturesAuthView> createState() =>
      _AnimePicturesAuthViewState();
}

class _AnimePicturesAuthViewState extends ConsumerState<AnimePicturesAuthView> {
  @override
  Widget build(BuildContext context) {
    final config = ref.watch(initialBooruConfigProvider);
    final loginUrl = ref.watch(booruProvider(config.auth))?.getLoginUrl();

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          DefaultCookieAuthConfigSection(
            loginUrl: loginUrl,
            onGetCookies: (cookies) {
              if (cookies.isNotEmpty) {
                final filtered = cookies
                    .where((e) => e.name != 'animepictures_gdpr')
                    .where((e) => e.name != 'cf_clearance')
                    .where((e) => !e.name.startsWith('_ga'))
                    .toList();

                final cookiesString = filtered
                    .toSet()
                    .map((e) => '${e.name}=${e.value}')
                    .join('; ');

                ref.editNotifier.updatePassHash(cookiesString);

                Navigator.of(context).pop();
              }
            },
          ),
        ],
      ),
    );
  }
}
