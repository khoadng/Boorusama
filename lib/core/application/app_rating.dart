// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:easy_localization/easy_localization.dart';
import 'package:rate_my_app/rate_my_app.dart';

// Project imports:
import 'package:boorusama/core/platform.dart';

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
