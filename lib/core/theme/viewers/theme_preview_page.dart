// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_symbols_icons/symbols.dart';

// Project imports:
import '../../configs/src/create/appearance_theme.dart';
import '../../foundation/display.dart';
import '../../premiums/premiums.dart';
import '../../premiums/routes.dart';
import '../../widgets/widgets.dart';
import 'theme_previewer_notifier.dart';
import 'theme_previewer_page_view.dart';
import 'theme_previewer_sheet.dart';

const _kMinSheetSize = 0.3;
const _kMaxSheetSize = 0.75;

class ThemePreviewPage extends StatelessWidget {
  const ThemePreviewPage({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final viewPadding = MediaQuery.viewPaddingOf(context);

    return Material(
      child: Stack(
        children: [
          // Prevent this route from being popped so pop event is propagated to the parent route
          const PopScope(
            canPop: false,
            child: SizedBox.shrink(),
          ),
          Row(
            children: [
              Expanded(
                child: Column(
                  children: [
                    Expanded(
                      child: Padding(
                        padding: EdgeInsets.only(
                          top: viewPadding.top + 20,
                          bottom: !context.isLargeScreen
                              ? MediaQuery.sizeOf(context).height *
                                      _kMinSheetSize -
                                  viewPadding.top -
                                  viewPadding.bottom
                              : 0,
                        ),
                        child: const Column(
                          children: [
                            Expanded(
                              child: ThemePreviewPageView(),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              if (context.isLargeScreen)
                Container(
                  width: 460,
                  padding: EdgeInsets.only(
                    top: viewPadding.top + 40,
                  ),
                  child: const SafeArea(
                    bottom: false,
                    child: ThemePreviewerSheet(),
                  ),
                ),
            ],
          ),
          if (!context.isLargeScreen)
            DraggableScrollableSheet(
              snap: true,
              snapSizes: const [
                _kMinSheetSize,
                _kMaxSheetSize,
              ],
              snapAnimationDuration: const Duration(milliseconds: 200),
              initialChildSize: _kMinSheetSize,
              maxChildSize: _kMaxSheetSize,
              minChildSize: _kMinSheetSize,
              builder: (context, scrollController) => ThemePreviewerSheet(
                scrollController: scrollController,
              ),
            ),
          Positioned(
            top: 4,
            left: 12,
            child: SafeArea(
              child: Consumer(
                builder: (_, ref, __) {
                  final notifier = ref.watch(themePreviewerProvider.notifier);

                  return CircularIconButton(
                    icon: const Padding(
                      padding: EdgeInsets.only(left: 8),
                      child: Icon(
                        Symbols.arrow_back_ios,
                        color: Colors.white,
                      ),
                    ),
                    onPressed: notifier.onExit,
                  );
                },
              ),
            ),
          ),
          Positioned(
            top: 0,
            right: 4,
            child: Consumer(
              builder: (_, ref, __) {
                final hasPremium = ref.watch(hasPremiumProvider);
                final notifier = ref.watch(themePreviewerProvider.notifier);

                return SafeArea(
                  child: hasPremium
                      ? TextButton(
                          onPressed: () {
                            notifier.updateScheme();
                            notifier.onExit();
                          },
                          child: switch (notifier.updateMethod) {
                            ThemeUpdateMethod.applyDirectly =>
                              const Text('Apply'),
                            ThemeUpdateMethod.saveAndUpdateLater =>
                              const Text('Save'),
                          },
                        )
                      : TextButton(
                          onPressed: () {
                            goToPremiumPage(context);
                          },
                          child: const Text('Upgrade'),
                        ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
