import 'package:material_ui/material_ui.dart';

abstract final class KurumiColorTokens {
  static const lightWhite = Color.fromARGB(255, 220, 220, 220);
  static const dimWhite = Color.fromARGB(255, 130, 130, 130);

  static const primaryAmoledDark = Color(0xFFA8C7FA);
  static const onPrimaryAmoledDark = Color(0xFF062E6F);
  static const errorAmoledDark = Color(0xFFFFB4AB);
  static const onErrorAmoledDark = Color(0xFF690005);
  static const hintAmoledDark = dimWhite;

  static const primaryDark = Color(0xFFA8C7FA);
  static const onPrimaryDark = Color(0xFF062E6F);
  static const errorDark = Color(0xFFFFB4AB);
  static const onErrorDark = Color(0xFF690005);
  static const iconDark = lightWhite;

  static const primaryLight = Color(0xFF1B6EF3);
  static const onPrimaryLight = Colors.white;
  static const onBackgroundLight = Color(0xFF1F1F1F);
  static const onSurfaceLight = Color(0xFF1F1F1F);
  static const errorLight = Color(0xFFBA1A1A);
  static const onErrorLight = Colors.white;
  static const hintLight = Color(0xFF74777F);
}
