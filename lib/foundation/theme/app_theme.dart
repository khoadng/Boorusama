// Flutter imports:
import 'package:flutter/material.dart' hide ThemeMode;

// Project imports:
import 'colors.dart';
import 'theme_mode.dart';

const kPrimaryDarkColor = Color.fromARGB(255, 114, 137, 218);
const kSecondaryDarkColor = Color.fromARGB(255, 0, 128, 128);
const kPrimaryLightColor = Color.fromARGB(255, 114, 137, 218);

class AppTheme {
  AppTheme._();

  static ThemeData lightTheme() => ThemeData.light().copyWith(
        dividerTheme: ThemeData.dark().dividerTheme.copyWith(
              color: const Color.fromARGB(255, 235, 235, 235),
            ),
        extensions: [
          const BoorusamaColors(
            videoPlayerBackgroundColor: Colors.white,
            themeMode: ThemeMode.light,
            selectedColor: Colors.grey,
          ),
        ],
        switchTheme: ThemeData.light().switchTheme.copyWith(
              thumbColor: MaterialStateProperty.all(kPrimaryLightColor),
              trackColor: MaterialStateProperty.all(
                  const Color.fromARGB(255, 225, 227, 229)),
            ),
        appBarTheme: ThemeData.light().appBarTheme.copyWith(
              color: ThemeData.light().scaffoldBackgroundColor,
              foregroundColor: Colors.black,
            ),
        cardColor: const Color.fromARGB(255, 235, 235, 235),
        buttonBarTheme: ThemeData.dark()
            .buttonBarTheme
            .copyWith(buttonTextTheme: ButtonTextTheme.normal),
        chipTheme: const ChipThemeData().copyWith(
          backgroundColor: const Color.fromARGB(255, 230, 230, 230),
          disabledColor: const Color.fromARGB(255, 115, 127, 141),
          selectedColor: const Color.fromARGB(255, 0, 0, 0),
          labelStyle: const TextStyle(
              color: Colors.black87, fontWeight: FontWeight.w600),
          secondaryLabelStyle:
              const TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
        ),
        floatingActionButtonTheme:
            const FloatingActionButtonThemeData(foregroundColor: Colors.white),
        iconTheme: ThemeData.light()
            .iconTheme
            .copyWith(color: const Color.fromARGB(255, 79, 86, 96)),
        bottomNavigationBarTheme: const BottomNavigationBarThemeData().copyWith(
            backgroundColor: const Color.fromARGB(255, 225, 227, 229)),
        expansionTileTheme: ThemeData.light().expansionTileTheme.copyWith(
              textColor: Colors.black,
              iconColor: Colors.black,
            ),
        colorScheme: const ColorScheme.light(
          primary: kPrimaryLightColor,
          secondary: kPrimaryLightColor,
        ).copyWith(background: const Color.fromARGB(255, 240, 240, 240)),
      );

  static ThemeData darkTheme() => ThemeData.dark().copyWith(
        dividerTheme: ThemeData.dark().dividerTheme.copyWith(
              color: const Color.fromARGB(255, 72, 72, 72),
            ),
        extensions: [
          const BoorusamaColors(
            videoPlayerBackgroundColor: Colors.black,
            themeMode: ThemeMode.dark,
            selectedColor: Color.fromARGB(255, 40, 40, 40),
          ),
        ],
        switchTheme: ThemeData.dark().switchTheme.copyWith(
              thumbColor: MaterialStateProperty.all<Color>(
                  const Color.fromARGB(255, 86, 99, 233)),
              trackColor: MaterialStateProperty.all<Color>(
                  const Color.fromARGB(255, 36, 36, 36)),
            ),
        appBarTheme: ThemeData.dark().appBarTheme.copyWith(
              color: ThemeData.dark().scaffoldBackgroundColor,
            ),
        buttonBarTheme: ThemeData.dark()
            .buttonBarTheme
            .copyWith(buttonTextTheme: ButtonTextTheme.normal),
        chipTheme: ThemeData.dark().chipTheme.copyWith(
              backgroundColor: const Color.fromARGB(255, 72, 72, 72),
              disabledColor: const Color.fromARGB(255, 72, 72, 72),
              selectedColor: Colors.white,
              labelStyle: const TextStyle(
                  color: Colors.white, fontWeight: FontWeight.bold),
              secondaryLabelStyle: const TextStyle(
                  color: Colors.black, fontWeight: FontWeight.bold),
            ),
        bottomNavigationBarTheme: const BottomNavigationBarThemeData()
            .copyWith(backgroundColor: Colors.black),
        expansionTileTheme: ThemeData.dark().expansionTileTheme.copyWith(
              textColor: Colors.white,
              iconColor: Colors.white,
            ),
        colorScheme: const ColorScheme.dark(
          primary: kPrimaryDarkColor,
          secondary: kPrimaryDarkColor,
        ).copyWith(background: const Color.fromARGB(255, 36, 36, 36)),
        floatingActionButtonTheme:
            ThemeData.dark().floatingActionButtonTheme.copyWith(
                  foregroundColor: Colors.white,
                ),
      );

  static ThemeData darkAmoledTheme(BuildContext context) => ThemeData(
        appBarTheme: const AppBarTheme(
          scrolledUnderElevation: 0,
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
        ),
        extensions: const [
          BoorusamaColors(
            videoPlayerBackgroundColor: Colors.black,
            themeMode: ThemeMode.amoledDark,
            selectedColor: Color.fromARGB(255, 40, 40, 40),
          ),
        ],
        inputDecorationTheme: InputDecorationTheme(
          floatingLabelBehavior: FloatingLabelBehavior.always,
          filled: true,
          enabledBorder: const OutlineInputBorder(
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(
              color: Theme.of(context).colorScheme.primary,
              width: 2,
            ),
          ),
          errorBorder: const OutlineInputBorder(
            borderSide: BorderSide(
              width: 2,
            ),
          ),
          focusedErrorBorder: const OutlineInputBorder(
            borderSide: BorderSide(
              width: 2,
            ),
          ),
          contentPadding: const EdgeInsets.all(12),
        ),
        colorScheme: ColorScheme.fromSeed(
          seedColor: kPrimaryDarkColor,
          brightness: Brightness.dark,
          background: Colors.black,
          onBackground: Colors.white,
          secondaryContainer: const Color.fromARGB(255, 40, 40, 40),
          onSecondaryContainer: Colors.white,
        ),
      );
}
