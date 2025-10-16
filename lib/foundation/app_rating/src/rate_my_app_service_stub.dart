// Flutter imports:
import 'package:flutter/material.dart';

// Project imports:
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
  bool get canRate => false;

  @override
  Widget createRatingWidget({required Widget child}) {
    return child;
  }
}
