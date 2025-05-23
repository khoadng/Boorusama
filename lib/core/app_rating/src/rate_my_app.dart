// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:foundation/foundation.dart';
import 'package:rate_my_app/rate_my_app.dart';

// Project imports:
import '../../foundation/platform.dart';

class RateMyAppScope extends StatelessWidget {
  const RateMyAppScope({
    required this.child,
    super.key,
  });

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return canRate() ? createAppRatingWidget(child: child) : child;
  }
}

RateMyApp _createRateMyApp() => RateMyApp(
      minDays: 14,
      minLaunches: 200,
      remindDays: 30,
    );

bool canRate() => isAndroid() || isIOS();

Widget createAppRatingWidget({
  required Widget child,
}) {
  try {
    return RateMyAppBuilder(
      rateMyApp: _createRateMyApp(),
      onInitialized: onRateAppInitialized,
      builder: (context) => child,
    );
  } catch (_) {
    return child;
  }
}

void onRateAppInitialized(BuildContext context, RateMyApp rateMyApp) {
  if (!rateMyApp.shouldOpenDialog) return;

  rateMyApp.showRateDialog(
    context,
    title: 'rating.rate_request'.tr(),
    message: 'rating.rationale'.tr(),
    rateButton: 'rating.rate'.tr(),
    noButton: 'rating.cancel'.tr(),
    laterButton: 'rating.later'.tr(),
  );
}
