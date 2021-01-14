import 'package:flutter/material.dart';

class AppTheme {
  // Private Constructor
  AppTheme._();

  static final lightTheme = ThemeData.light().copyWith(
    // canvasColor: ThemeData.light().canvasColor,
    primaryTextTheme: ThemeData.light()
        .textTheme
        .copyWith(headline6: TextStyle(color: Colors.black)),
    iconTheme: ThemeData.light().iconTheme.copyWith(
          color: Colors.black,
        ),
    bottomAppBarTheme:
        ThemeData.light().bottomAppBarTheme.copyWith(color: Colors.white),
    appBarTheme: ThemeData.light().appBarTheme.copyWith(
          actionsIconTheme: ThemeData.light().iconTheme,
          iconTheme: ThemeData.light().iconTheme,
          color: Colors.white,
        ),
  );
  static final darkTheme = ThemeData.dark().copyWith(
      // canvasColor: Color(0xff323232),
      primaryTextTheme: ThemeData.dark()
          .textTheme
          .copyWith(headline6: TextStyle(color: Colors.white)),
      iconTheme: ThemeData.dark().iconTheme.copyWith(
            color: Colors.white70,
          ),
      bottomAppBarTheme:
          ThemeData.dark().bottomAppBarTheme.copyWith(color: Color(0xff323232)),
      appBarTheme: ThemeData.dark().appBarTheme.copyWith(
            color: Color(0xff323232),
          ));
}
