import 'package:material_ui/material_ui.dart';

abstract final class KurumiColorTokens {
  static const lightWhite = Color.fromARGB(255, 220, 220, 220);
  static const dimWhite = Color.fromARGB(255, 130, 130, 130);

  static const primaryAmoledDark = Color.fromARGB(255, 86, 99, 233);
  static const onPrimaryAmoledDark = lightWhite;
  static const errorAmoledDark = Color(0xFFB00020);
  static const onErrorAmoledDark = lightWhite;
  static const hintAmoledDark = dimWhite;

  static const primaryDark = Color.fromARGB(255, 86, 99, 233);
  static const onPrimaryDark = lightWhite;
  static const errorDark = Color(0xFFB00020);
  static const onErrorDark = lightWhite;
  static const iconDark = lightWhite;

  static const primaryLight = Color.fromARGB(255, 114, 137, 218);
  static const onPrimaryLight = Colors.white;
  static const onBackgroundLight = Colors.black;
  static const onSurfaceLight = Colors.black;
  static const errorLight = Color.fromARGB(255, 211, 47, 47);
  static const onErrorLight = Colors.white;
  static const hintLight = Color.fromARGB(255, 79, 86, 96);
}
