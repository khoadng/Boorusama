// Flutter imports:
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_symbols_icons/symbols.dart';

// Project imports:
import '../../../../boorus/engine/providers.dart';
import '../../../config/types.dart';
import '../../../create/providers.dart';
import '../widgets/appearance_config_card.dart';
import '../widgets/appearance_details_page.dart';
import '../widgets/home_screen_section.dart';
import 'theme_configs_page.dart';

class DefaultBooruConfigLayoutView extends ConsumerWidget {
  const DefaultBooruConfigLayoutView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return const BooruConfigLayoutView();
  }
}

class BooruConfigLayoutView extends ConsumerWidget {
  const BooruConfigLayoutView({
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final config = ref.watch(initialBooruConfigProvider);
    final uiBuilder =
        ref.watch(booruBuilderProvider(config.auth))?.postDetailsUIBuilder;

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(vertical: 24),
            child: Row(
              children: [
                Expanded(
                  child: AppearanceConfigCard(
                    icon: const Icon(Symbols.color_lens),
                    title: 'Theme',
                    onPressed: () {
                      Navigator.of(context).push(
                        CupertinoPageRoute(
                          builder: (context) => ProviderScope(
                            overrides: [
                              editBooruConfigIdProvider.overrideWithValue(
                                ref.watch(editBooruConfigIdProvider),
                              ),
                            ],
                            child: const ThemeConfigsPage(),
                          ),
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(width: 12),
                if (uiBuilder != null)
                  Expanded(
                    child: AppearanceConfigCard(
                      icon: const Icon(Symbols.info_rounded),
                      title: 'Details',
                      onPressed: () {
                        Navigator.of(context).push(
                          CupertinoPageRoute(
                            builder: (context) => ProviderScope(
                              overrides: [
                                editBooruConfigIdProvider.overrideWithValue(
                                  ref.watch(editBooruConfigIdProvider),
                                ),
                                initialBooruConfigProvider.overrideWithValue(
                                  ref.watch(initialBooruConfigProvider),
                                ),
                              ],
                              child: AppearanceDetailsPage(
                                uiBuilder: uiBuilder,
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
              ],
            ),
          ),
          const Divider(),
          const HomeScreenSection(),
        ],
      ),
    );
  }
}
