// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_symbols_icons/symbols.dart';

// Project imports:
import '../../../core/configs/auth/widgets.dart';
import '../../../core/configs/create/providers.dart';
import '../../../core/configs/create/widgets.dart';
import '../anime_pictures.dart';

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
      authTab: const AnimePicturesAuthView(),
      footer: editId.isNew
          ? Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 8,
              ),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.secondaryContainer,
                borderRadius: const BorderRadius.only(
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
                    color: Theme.of(context).colorScheme.error,
                  ),
                  const SizedBox(width: 8),
                  Flexible(
                    child: Text(
                      "Bulk download and blacklist won't work for this booru.",
                      style: Theme.of(context).textTheme.bodySmall,
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
    final animePictures = ref.watch(animePicturesProvider);

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          DefaultCookieAuthConfigSection(
            loginUrl: animePictures.loginUrl,
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
