// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:extended_image/extended_image.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:material_symbols_icons/symbols.dart';

// Project imports:
import 'package:boorusama/boorus/providers.dart';
import 'package:boorusama/core/utils.dart';
import 'package:boorusama/flutter.dart';

class HelpUseTranslatePage extends ConsumerWidget {
  const HelpUseTranslatePage({
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final appInfo = ref.watch(appInfoProvider);

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            onPressed: () => context.navigator.pop(),
            icon: const Icon(
              Symbols.close,
              size: 24,
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Translation status',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    ExtendedImage.network(
                      appInfo.translationBadgeUrl,
                      height: 66,
                      width: 287,
                    ),
                    const SizedBox(height: 24),
                    SvgPicture.network(
                      appInfo.translationStatusUrl,
                      height: 300,
                      placeholderBuilder: (context) => const Center(
                        child: CircularProgressIndicator(),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(32),
              child: FilledButton(
                onPressed: () {
                  launchExternalUrlString(
                    appInfo.translationProjectUrl,
                  );
                },
                child: const Text(
                  'Contribute',
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
