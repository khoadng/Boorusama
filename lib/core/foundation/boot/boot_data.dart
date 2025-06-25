// Project imports:
import '../../app_rating/app_rating.dart';
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
  });

  BootData copyWith({
    BootLogger? bootLogger,
    Logger? logger,
    AppLogger? appLogger,
    Future<IAP> Function()? iapFunc,
    bool? isFossBuild,
    bool? googleApiAvailable,
    AppRatingService? appRatingService,
  }) {
    return BootData(
      bootLogger: bootLogger ?? this.bootLogger,
      logger: logger ?? this.logger,
      appLogger: appLogger ?? this.appLogger,
      iapFunc: iapFunc ?? this.iapFunc,
      isFossBuild: isFossBuild ?? this.isFossBuild,
      googleApiAvailable: googleApiAvailable ?? this.googleApiAvailable,
      appRatingService: appRatingService ?? this.appRatingService,
    );
  }

  final BootLogger bootLogger;
  final Logger logger;
  final AppLogger appLogger;
  final Future<IAP> Function()? iapFunc;
  final bool isFossBuild;
  final bool googleApiAvailable;
  final AppRatingService? appRatingService;
}
