// Package imports:
import 'package:package_info_plus/package_info_plus.dart';

// Project imports:
import '../app_rating/app_rating.dart';
import '../app_update/types.dart';
import '../iap/iap.dart';
import '../loggers.dart';

class BootData {
  const BootData({
    required this.bootLogger,
    required this.logger,
    required this.appLogger,
    this.iapFunc,
    this.isFossBuild = false,
    this.googleApiAvailable = false,
    this.appRatingService,
    this.appUpdateChecker,
  });

  BootData copyWith({
    BootLogger? bootLogger,
    Logger? logger,
    AppLogger? appLogger,
    Future<IAP> Function()? iapFunc,
    bool? isFossBuild,
    bool? googleApiAvailable,
    AppRatingService? appRatingService,
    AppUpdateBuilder? appUpdateChecker,
  }) {
    return BootData(
      bootLogger: bootLogger ?? this.bootLogger,
      logger: logger ?? this.logger,
      appLogger: appLogger ?? this.appLogger,
      iapFunc: iapFunc ?? this.iapFunc,
      isFossBuild: isFossBuild ?? this.isFossBuild,
      googleApiAvailable: googleApiAvailable ?? this.googleApiAvailable,
      appRatingService: appRatingService ?? this.appRatingService,
      appUpdateChecker: appUpdateChecker ?? this.appUpdateChecker,
    );
  }

  final BootLogger bootLogger;
  final Logger logger;
  final AppLogger appLogger;
  final Future<IAP> Function()? iapFunc;
  final bool isFossBuild;
  final bool googleApiAvailable;
  final AppRatingService? appRatingService;
  final AppUpdateBuilder? appUpdateChecker;
}

typedef AppUpdateBuilder =
    AppUpdateChecker Function(
      PackageInfo packageInfo,
    );
