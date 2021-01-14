part of 'theme_state_notifier.dart';

@freezed
abstract class ThemeState with _$ThemeState {
  // const factory ThemeState.initial() = _Initial;
  const factory ThemeState.darkMode() = _DarkMode;
  const factory ThemeState.lightMode() = _LightMode;
}

// abstract class ThemeState extends Equatable {
//   const ThemeState(this.theme, this.iconColor, this.statusBarColor,
//       this.statusBarIconBrightness, this.appBarBrightness, this.appBarColor);

//   final ThemeMode theme;
//   final Color iconColor;
//   final Color statusBarColor;
//   final Brightness statusBarIconBrightness;
//   final Brightness appBarBrightness;
//   final Color appBarColor;

//   @override
//   List<Object> get props => [];
// }

// class ThemeDark extends ThemeState {
//   ThemeDark()
//       : super(
//           ThemeMode.dark,
//           Colors.white70,
//           Colors.black,
//           Brightness.light,
//           Brightness.dark,
//           Color(0xff323232),
//         );
// }

// class ThemeLight extends ThemeState {
//   ThemeLight()
//       : super(
//           ThemeMode.light,
//           Colors.black54,
//           Colors.white,
//           Brightness.dark,
//           Brightness.light,
//           Colors.white,
//         );
// }
