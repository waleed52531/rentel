import 'package:flutter/material.dart';

ThemeData buildAppTheme({Brightness brightness = Brightness.light}) {
  final scheme = ColorScheme.fromSeed(
      seedColor: const Color(0xff3559c7), brightness: brightness);
  final dark = brightness == Brightness.dark;
  return ThemeData(
    useMaterial3: true,
    colorScheme: scheme,
    scaffoldBackgroundColor:
        dark ? const Color(0xff10131a) : const Color(0xfff8f9fd),
    appBarTheme: const AppBarTheme(
        centerTitle: false, backgroundColor: Colors.transparent),
    cardTheme: CardThemeData(
        elevation: 0,
        color: dark ? const Color(0xff181c24) : Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18))),
    inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: dark ? const Color(0xff181c24) : Colors.white,
        border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide.none)),
    filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
            minimumSize: const Size(0, 50),
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14)))),
  );
}
