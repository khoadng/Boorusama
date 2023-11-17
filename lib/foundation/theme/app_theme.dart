// Flutter imports:
import 'package:flutter/material.dart' hide ThemeMode;

// Project imports:
import 'colors.dart';
import 'theme_mode.dart';

const kLightWhiteColor = Color.fromARGB(255, 220, 220, 220);

// AMOLED Dark theme
const kPrimaryAmoledDarkColor = Color.fromARGB(255, 86, 99, 233);
const kOnPrimaryAmoledDarkColor = kLightWhiteColor;
const kBackgroundAmoledDarkColor = Colors.black;
const kOnBackgroundAmoledDarkColor = kLightWhiteColor;
const kSecondaryContainerAmoledDarkColor = Color.fromARGB(255, 50, 50, 50);
const kSurfaceAmoledDarkColor = Color.fromARGB(255, 40, 40, 40);
const kOnSurfaceAmoledDarkColor = kLightWhiteColor;
const kErrorAmoledDarkColor = Colors.redAccent;
const kOnErrorAmoledDarkColor = kLightWhiteColor;
const kIconAmoledDarkColor = kLightWhiteColor;

// Dark theme

// Light theme
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
          primary: kPrimaryAmoledDarkColor,
          secondary: kPrimaryAmoledDarkColor,
        ).copyWith(background: const Color.fromARGB(255, 36, 36, 36)),
        floatingActionButtonTheme:
            ThemeData.dark().floatingActionButtonTheme.copyWith(
                  foregroundColor: Colors.white,
                ),
      );

  static ThemeData darkAmoledTheme() => ThemeData(
        appBarTheme: const AppBarTheme(
          scrolledUnderElevation: 0,
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
        ),
        chipTheme: const ChipThemeData(
          shape: StadiumBorder(),
          side: BorderSide.none,
        ),
        cardTheme: const CardTheme(
          color: kSurfaceAmoledDarkColor,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(8)),
          ),
        ),
        dividerTheme: const DividerThemeData(
          color: kSurfaceAmoledDarkColor,
          endIndent: 0,
          indent: 0,
        ),
        dialogTheme: const DialogTheme(
          backgroundColor: kSurfaceAmoledDarkColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(8)),
          ),
        ),
        expansionTileTheme: const ExpansionTileThemeData(
          iconColor: kIconAmoledDarkColor,
        ),
        extensions: const [
          BoorusamaColors(
            videoPlayerBackgroundColor: Colors.black,
            themeMode: ThemeMode.amoledDark,
            selectedColor: kSurfaceAmoledDarkColor,
          ),
        ],
        iconTheme: const IconThemeData(
          color: kIconAmoledDarkColor,
        ),
        inputDecorationTheme: const InputDecorationTheme(
          floatingLabelBehavior: FloatingLabelBehavior.always,
          filled: true,
          fillColor: kSurfaceAmoledDarkColor,
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(8)),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(8)),
            borderSide: BorderSide(
              color: kPrimaryAmoledDarkColor,
              width: 2,
            ),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(8)),
            borderSide: BorderSide(
              width: 2,
            ),
          ),
          focusedErrorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(8)),
            borderSide: BorderSide(
              width: 2,
            ),
          ),
          contentPadding: EdgeInsets.all(12),
        ),
        colorScheme: const ColorScheme(
          brightness: Brightness.dark,
          background: kBackgroundAmoledDarkColor,
          onBackground: kOnBackgroundAmoledDarkColor,
          secondaryContainer: kSecondaryContainerAmoledDarkColor,
          onSecondaryContainer: kOnSurfaceAmoledDarkColor,
          primary: kPrimaryAmoledDarkColor,
          onPrimary: kOnPrimaryAmoledDarkColor,
          secondary: kPrimaryAmoledDarkColor,
          onSecondary: kOnPrimaryAmoledDarkColor,
          error: kErrorAmoledDarkColor,
          onError: kOnErrorAmoledDarkColor,
          surface: kSurfaceAmoledDarkColor,
          onSurface: kOnSurfaceAmoledDarkColor,
        ),
      );
}
