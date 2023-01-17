import 'package:boorusama/core/domain/settings/settings.dart';
import 'package:boorusama/core/firebase.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

bool isAnalyticsEnabled(Settings settings) =>
    settings.dataCollectingStatus == DataCollectingStatus.allow &&
    kReleaseMode &&
    isFirebaseAnalyticsSupportedPlatforms();

NavigatorObserver getAnalyticsObserver() => FirebaseAnalyticsObserver(
      analytics: FirebaseAnalytics.instance,
    );
