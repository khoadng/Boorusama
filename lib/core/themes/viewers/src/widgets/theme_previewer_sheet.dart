// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import '../../../../../foundation/display.dart';
import '../../../theme/types.dart';
import '../providers/theme_previewer_notifier.dart';
import 'color_selector_accent.dart';
import 'color_selector_basic.dart';
import 'color_selector_builtin.dart';
import 'theme_widgets.dart';

class ThemePreviewerSheet extends ConsumerWidget {
  const ThemePreviewerSheet({
    this.scrollController,
    super.key,
  });

  final ScrollController? scrollController;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colorScheme = ref.watch(themePreviewerSchemeProvider);

    return Container(
      padding: const EdgeInsets.only(
        top: 8,
      ),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerLow,
        borderRadius: const BorderRadius.vertical(
          top: Radius.circular(24),
        ),
      ),
      child: Column(
        children: [
          SizedBox(
            height: 56,
            child: NotificationListener<ScrollNotification>(
              // Prevent notification from being propagated to the parent to avoid conflicts with the content scroll
              onNotification: (_) => true,
              child: CustomScrollView(
                physics: const ClampingScrollPhysics(),
                controller: scrollController,
                slivers: [
                  if (!context.isLargeScreen)
                    SliverToBoxAdapter(
                      child: Center(
                        child: Container(
                          decoration: BoxDecoration(
                            color: colorScheme.hintColor,
                            borderRadius: const BorderRadius.all(
                              Radius.circular(10),
                            ),
                          ),
                          height: 4,
                          width: 40,
                        ),
                      ),
                    ),
                  const SliverToBoxAdapter(
                    child: Padding(
                      padding: EdgeInsets.symmetric(
                        vertical: 8,
                      ),
                      child: ThemeCategoryToggleSwitch(),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            child: Column(
              children: [
                Container(
                  margin: const EdgeInsets.symmetric(
                    horizontal: 12,
                  ),
                ),
                Expanded(
                  child: ScrollConfiguration(
                    // Force MaterialScrollBehavior to make sure overscroll effect is enabled
                    behavior: const MaterialScrollBehavior(),
                    child: CustomScrollView(
                      physics: const AlwaysScrollableScrollPhysics(
                        parent: ClampingScrollPhysics(),
                      ),
                      slivers: [
                        SliverList.list(
                          children: [
                            Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Consumer(
                                  builder: (_, ref, _) {
                                    final state = ref.watch(
                                      themePreviewerProvider,
                                    );

                                    return switch (state.category) {
                                      ThemeCategory.basic =>
                                        const BasicColorSelector(),
                                      ThemeCategory.builtIn =>
                                        const BuiltInColorSelector(),
                                      ThemeCategory.accent =>
                                        const AccentColorSelector(),
                                    };
                                  },
                                ),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
