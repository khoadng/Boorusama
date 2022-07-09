// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:rate_my_app/rate_my_app.dart';

// Project imports:
import 'package:boorusama/core/core.dart';

const _message = '''
If you like the app, please take a little bit of your time to review it.
It wouldn't take more than a few seconds and it really helps this project.
''';

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
    title: 'Rate this app',
    message: _message,
    rateButton: 'RATE',
    noButton: 'NO THANKS',
    laterButton: 'MAYBE LATER',
  );
}
