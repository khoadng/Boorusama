import 'package:flutter/material.dart';
import 'package:flutter_wallpaper_android/flutter_wallpaper.dart' as wallpaper;

Future<void> setHomeScreenWallpaperFromImagePath({
  required BuildContext context,
  required String imagePath,
}) =>
    wallpaper.setWallpaperFromImagePath(
      path: imagePath,
      type: wallpaper.PreferredWallpaperType.home,
      platform: Theme.of(context).platform,
    );

Future<void> setLockScreenWallpaperFromImagePath({
  required BuildContext context,
  required String imagePath,
}) =>
    wallpaper.setWallpaperFromImagePath(
      path: imagePath,
      type: wallpaper.PreferredWallpaperType.lock,
      platform: Theme.of(context).platform,
    );
