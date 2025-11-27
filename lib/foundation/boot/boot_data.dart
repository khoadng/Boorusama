// Package imports:
import 'package:package_info_plus/package_info_plus.dart';

// Project imports:
import '../app_rating/app_rating.dart';
import '../app_update/types.dart';
import '../iap/iap.dart';
import '../loggers.dart';

class BootData {
  const BootData({
    required this.logger,
    required this.appLogger,
    this.iapFunc,
    this.isFossBuild = false,
    this.googleApiAvailable = false,
    this.cronetAvailable = false,
    this.appRatingService,
    this.appUpdateChecker,
  });

  BootData copyWith({
    Logger? logger,
    AppLogger? appLogger,
    Future<IAP> Function()? iapFunc,
    bool? isFossBuild,
    bool? cronetAvailable,
    AppRatingService? appRatingService,
    AppUpdateBuilder? appUpdateChecker,
  }) {
    return BootData(
      logger: logger ?? this.logger,
      appLogger: appLogger ?? this.appLogger,
      iapFunc: iapFunc ?? this.iapFunc,
      isFossBuild: isFossBuild ?? this.isFossBuild,
      cronetAvailable: cronetAvailable ?? this.cronetAvailable,
      appRatingService: appRatingService ?? this.appRatingService,
      appUpdateChecker: appUpdateChecker ?? this.appUpdateChecker,
    );
  }

  final Logger logger;
  final AppLogger appLogger;
  final Future<IAP> Function()? iapFunc;
  final bool isFossBuild;
  final bool googleApiAvailable;
  final bool cronetAvailable;
  final AppRatingService? appRatingService;
  final AppUpdateBuilder? appUpdateChecker;
}

typedef AppUpdateBuilder =
    AppUpdateChecker Function(
      PackageInfo packageInfo,
    );
