part of 'theme_bloc.dart';

abstract class ThemeState extends Equatable {
  const ThemeState(this.theme, this.brightness, this.iconColor);

  final ThemeMode theme;
  final Brightness brightness;
  final Color iconColor;

  @override
  List<Object> get props => [];
}

class ThemeDark extends ThemeState {
  ThemeDark()
      : super(
          ThemeMode.dark,
          Brightness.light,
          Colors.white,
        );
}

class ThemeLight extends ThemeState {
  ThemeLight()
      : super(
          ThemeMode.light,
          Brightness.dark,
          Colors.black,
        );
}
