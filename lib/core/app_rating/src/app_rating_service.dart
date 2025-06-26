// Flutter imports:
import 'package:flutter/material.dart';

abstract class AppRatingService {
  bool get canRate;
  Widget createRatingWidget({required Widget child});
}
