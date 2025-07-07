// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:foundation/foundation.dart';
import 'package:material_symbols_icons/symbols.dart';

// Project imports:
import '../../../foundation/display.dart';
import '../../configs/appearance/types.dart';
import '../../premiums/providers.dart';
import '../../premiums/routes.dart';
import '../../widgets/widgets.dart';
import 'theme_previewer_notifier.dart';
import 'theme_previewer_page_view.dart';
import 'theme_previewer_sheet.dart';

const _kMinSheetSize = 0.35;
const _kMaxSheetSize = 0.75;

class ThemePreviewPage extends StatefulWidget {
  const ThemePreviewPage({
    super.key,
  });

  @override
  State<ThemePreviewPage> createState() => _ThemePreviewPageState();
}

class _ThemePreviewPageState extends State<ThemePreviewPage> {
  final _sheetController = DraggableScrollableController();

  @override
  void dispose() {
    _sheetController.dispose();

    super.dispose();
  }

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
                  width: 350,
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
              controller: _sheetController,
              snap: true,
              snapSizes: const [
                _kMinSheetSize,
                _kMaxSheetSize,
              ],
              snapAnimationDuration: const Duration(milliseconds: 200),
              initialChildSize: _kMinSheetSize,
              maxChildSize: _kMaxSheetSize,
              minChildSize: _kMinSheetSize,
              builder: (context, scrollController) =>
                  _ThemeSheetControllerListener(
                    sheetController: _sheetController,
                    child: ThemePreviewerSheet(
                      scrollController: scrollController,
                    ),
                  ),
            ),
          Positioned(
            top: 4,
            left: 12,
            child: SafeArea(
              child: Consumer(
                builder: (_, ref, _) {
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
              builder: (_, ref, _) {
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
                            ThemeUpdateMethod.applyDirectly => const Text(
                              'Apply',
                            ),
                            ThemeUpdateMethod.saveAndUpdateLater => const Text(
                              'Save',
                            ),
                          },
                        )
                      : TextButton(
                          onPressed: () {
                            goToPremiumPage(ref);
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

const _kOverscrollSheetSnapToMaxThreshold = -6.0;
const _kOverscrollSheetSnapToMinThreshold = -6.0;

class _ThemeSheetControllerListener extends StatelessWidget {
  const _ThemeSheetControllerListener({
    required this.child,
    required this.sheetController,
  });

  final Widget child;
  final DraggableScrollableController sheetController;

  bool get isFullyExpanded =>
      sheetController.size.isApproximatelyEqual(_kMaxSheetSize);

  bool get isFullyCollapsed =>
      sheetController.size.isApproximatelyEqual(_kMinSheetSize);

  @override
  Widget build(BuildContext context) {
    return NotificationListener<ScrollNotification>(
      onNotification: (notification) {
        if (notification is OverscrollNotification) {
          // only close when sheet is still
          if (notification.velocity < 0 || notification.velocity > 0) {
            return false;
          }

          if (notification.depth != 0) return false;

          final overscrollAmount = notification.overscroll;

          if (isFullyExpanded) {
            if (overscrollAmount < _kOverscrollSheetSnapToMinThreshold) {
              sheetController.animateTo(
                _kMinSheetSize,
                duration: const Duration(milliseconds: 200),
                curve: Curves.easeInOut,
              );
            }
          } else if (isFullyCollapsed) {
            if (overscrollAmount > -_kOverscrollSheetSnapToMaxThreshold) {
              sheetController.animateTo(
                _kMaxSheetSize,
                duration: const Duration(milliseconds: 200),
                curve: Curves.easeInOut,
              );
            }
          }
        }

        return false;
      },
      child: child,
    );
  }
}
