// Flutter imports:
import 'package:flutter/services.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:i18n/i18n.dart';
import 'package:kurumi/kurumi.dart';
import 'package:kurumi/material.dart';
import 'package:oktoast/oktoast.dart';

// Project imports:
import '../foundation/info/app_info.dart';
import '../foundation/networking.dart';
import '../foundation/platform.dart';
import 'analytics/widgets.dart';
import 'backups/auto/trigger.dart';
import 'router.dart';
import 'settings/providers.dart';
import 'themes/theme/widgets.dart';
import 'widgets/widgets.dart';
import 'window/widgets.dart';

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return const OKToast(
      child: AnalyticsScope(
        child: AutoBackupAppLifecycle(
          child: NetworkListener(
            child: _App(),
          ),
        ),
      ),
    );
  }
}

class _App extends ConsumerWidget {
  const _App();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);
    final appInfo = ref.watch(appInfoProvider);
    final reduceAnimations = ref.watch(
      settingsProvider.select((value) => value.reduceAnimations),
    );
    final hapticFeedbackLevel = ref.watch(hapticFeedbackLevelProvider);
    final enableIMEPersonalizedLearning = ref.watch(
      settingsProvider.select(
        (value) => !value.enableIncognitoModeForKeyboard,
      ),
    );

    return ThemeBuilder(
      builder: (theme, themeMode) {
        return MaterialApp.router(
          builder: (context, child) => KurumiTheme(
            data: KurumiThemeData.fromMaterial(theme),
            behavior: KurumiBehaviorData(
              reduceMotion: reduceAnimations,
              enableIMEPersonalizedLearning: enableIMEPersonalizedLearning,
              selectionFeedback: hapticFeedbackLevel.isBalanceAndAbove
                  ? HapticFeedback.selectionClick
                  : null,
              sliderLimitFeedback: hapticFeedbackLevel.isReducedOrAbove
                  ? HapticFeedback.mediumImpact
                  : null,
              sliderInteractionFeedback: hapticFeedbackLevel.isBalanceAndAbove
                  ? HapticFeedback.lightImpact
                  : null,
              refreshFeedback: hapticFeedbackLevel.isFull
                  ? HapticFeedback.mediumImpact
                  : null,
              menuFeedback: hapticFeedbackLevel.isFull
                  ? HapticFeedback.selectionClick
                  : null,
              adaptiveMenuFeedback: hapticFeedbackLevel.isFull
                  ? HapticFeedback.selectionClick
                  : null,
              contextMenuShowFeedback: hapticFeedbackLevel.isReducedOrAbove
                  ? HapticFeedback.selectionClick
                  : null,
              contextMenuSelectionFeedback: hapticFeedbackLevel.isFull
                  ? HapticFeedback.selectionClick
                  : null,
              contextMenuStartFeedbackEnabled:
                  hapticFeedbackLevel.hasHapticFeedback,
              segmentedSelectionFeedback: hapticFeedbackLevel.isFull
                  ? HapticFeedback.selectionClick
                  : null,
            ),
            child: Theme(
              data: Kurumi.themeOf(context).copyWith(
                iconTheme: Kurumi.themeOf(context).iconTheme.copyWith(
                  weight: isWindows() ? 200 : 400,
                ),
              ),
              child: AnnotatedRegion(
                // Needed to make the bottom navigation bar transparent
                value: SystemUiOverlayStyle(
                  statusBarColor: Colors.transparent,
                  systemNavigationBarColor: Colors.transparent,
                  statusBarBrightness: theme.brightness,
                  statusBarIconBrightness: context.onBrightness,
                ),
                child: AppTitleBar(
                  child: AppLockScope(
                    child: Column(
                      children: [
                        const NetworkUnavailableIndicatorWithState(),
                        Expanded(
                          child: NetworkUnavailableRemovePadding(
                            child: child!,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
          scrollBehavior: reduceAnimations
              ? const KurumiNoOverscrollBehavior()
              : null,
          theme: theme,
          themeMode: themeMode,
          localizationsDelegates: context.localizationDelegates,
          supportedLocales: context.supportedLocales,
          locale: context.locale,
          debugShowCheckedModeBanner: false,
          title: appInfo.appName,
          routerConfig: router,
        );
      },
    );
  }
}
