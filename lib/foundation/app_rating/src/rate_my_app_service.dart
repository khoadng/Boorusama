// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:i18n/i18n.dart';
import 'package:rate_my_app/rate_my_app.dart';

// Project imports:
import '../../platform.dart';
import 'app_rating_service.dart';

class RateMyAppService implements AppRatingService {
  const RateMyAppService({
    this.minDays = 14,
    this.minLaunches = 200,
    this.remindDays = 30,
  });

  final int minDays;
  final int minLaunches;
  final int remindDays;

  @override
  bool get canRate => isAndroid() || isIOS();

  @override
  Widget createRatingWidget({required Widget child}) {
    if (!canRate) return child;

    try {
      return RateMyAppBuilder(
        rateMyApp: RateMyApp(
          minDays: minDays,
          minLaunches: minLaunches,
          remindDays: remindDays,
        ),
        onInitialized: _onInitialized,
        builder: (context) => child,
      );
    } catch (_) {
      return child;
    }
  }

  void _onInitialized(BuildContext context, RateMyApp rateMyApp) {
    if (!rateMyApp.shouldOpenDialog) return;

    rateMyApp.showRateDialog(
      context,
      title: context.t.rating.rate_request,
      message: context.t.rating.rationale,
      rateButton: context.t.rating.rate,
      noButton: context.t.rating.cancel,
      laterButton: context.t.rating.later,
    );
  }
}
