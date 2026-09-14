import 'package:flutter/material.dart';

ThemeData buildAppTheme({Brightness brightness = Brightness.light}) {
  final dark = brightness == Brightness.dark;
  const lightBlue = Color(0xff2563eb);
  const lightBrown = Color(0xff8b5e3c);
  const lightBackground = Color(0xfff8fafc);
  const lightSurface = Color(0xffffffff);
  const darkBlue = Color(0xff3b82f6);
  const darkBrown = Color(0xffa47148);
  const darkBackground = Color(0xff0f172a);
  const darkSurface = Color(0xff1e293b);

  final scheme = ColorScheme.fromSeed(
    seedColor: dark ? darkBlue : lightBlue,
    brightness: brightness,
  ).copyWith(
    primary: dark ? darkBlue : lightBlue,
    onPrimary: Colors.white,
    primaryContainer: dark ? const Color(0xff173d7a) : const Color(0xffdbeafe),
    onPrimaryContainer:
        dark ? const Color(0xffdbeafe) : const Color(0xff102a56),
    secondary: dark ? darkBrown : lightBrown,
    onSecondary: Colors.white,
    secondaryContainer:
        dark ? const Color(0xff5b3a1d) : const Color(0xffffead7),
    onSecondaryContainer:
        dark ? const Color(0xffffead7) : const Color(0xff3a2412),
    surface: dark ? darkSurface : lightSurface,
    onSurface: dark ? const Color(0xfff8fafc) : const Color(0xff0f172a),
    surfaceContainerHighest:
        dark ? const Color(0xff263449) : const Color(0xffeef2f7),
    outline: dark ? const Color(0xff334155) : const Color(0xffe2e8f0),
    outlineVariant: dark ? const Color(0xff253146) : const Color(0xffedf1f6),
  );
  final bodyColor = dark ? const Color(0xffcbd5e1) : const Color(0xff334155);
  final borderColor = dark ? const Color(0xff334155) : const Color(0xffe2e8f0);
  final subtleFill = dark ? const Color(0xff172033) : const Color(0xfff8fafc);
  final textTheme = Typography.material2021(platform: TargetPlatform.android)
      .black
      .apply(
        bodyColor: bodyColor,
        displayColor: scheme.onSurface,
      )
      .copyWith(
        headlineMedium: TextStyle(
          color: scheme.onSurface,
          fontSize: 28,
          fontWeight: FontWeight.w800,
          height: 1.12,
        ),
        titleLarge: TextStyle(
          color: scheme.onSurface,
          fontSize: 21,
          fontWeight: FontWeight.w800,
        ),
        titleMedium: TextStyle(
          color: scheme.onSurface,
          fontSize: 16,
          fontWeight: FontWeight.w700,
        ),
        labelLarge: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w800,
        ),
      );

  return ThemeData(
    useMaterial3: true,
    colorScheme: scheme,
    scaffoldBackgroundColor: dark ? darkBackground : lightBackground,
    textTheme: textTheme,
    iconTheme: IconThemeData(color: scheme.onSurface),
    appBarTheme: AppBarTheme(
      centerTitle: false,
      elevation: 0,
      backgroundColor: dark ? darkBackground : lightBackground,
      foregroundColor: scheme.onSurface,
      surfaceTintColor: Colors.transparent,
      titleTextStyle: TextStyle(
        color: scheme.onSurface,
        fontSize: 20,
        fontWeight: FontWeight.w800,
      ),
    ),
    cardTheme: CardThemeData(
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 12),
      color: scheme.surface,
      shadowColor: Colors.black.withValues(alpha: dark ? .28 : .08),
      surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(
        side: BorderSide(color: borderColor),
        borderRadius: BorderRadius.circular(8),
      ),
    ),
    dividerTheme: DividerThemeData(color: borderColor, space: 1),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: subtleFill,
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      labelStyle: TextStyle(color: bodyColor, fontWeight: FontWeight.w600),
      prefixIconColor: dark ? const Color(0xff94a3b8) : const Color(0xff64748b),
      suffixIconColor: dark ? const Color(0xff94a3b8) : const Color(0xff64748b),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: borderColor),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: borderColor),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: scheme.primary, width: 1.6),
      ),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        backgroundColor: scheme.primary,
        foregroundColor: scheme.onPrimary,
        minimumSize: const Size(0, 50),
        elevation: 0,
        textStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.w800),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: scheme.primary,
        foregroundColor: scheme.onPrimary,
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: scheme.primary,
        side: BorderSide(color: scheme.primary, width: 1.4),
        textStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.w800),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: scheme.primary,
        textStyle: const TextStyle(fontWeight: FontWeight.w800),
      ),
    ),
    navigationBarTheme: NavigationBarThemeData(
      elevation: 0,
      height: 72,
      backgroundColor: dark ? darkSurface : Colors.white,
      indicatorColor: scheme.primaryContainer,
      surfaceTintColor: Colors.transparent,
      labelTextStyle: WidgetStateProperty.resolveWith((states) {
        final selected = states.contains(WidgetState.selected);
        return TextStyle(
          fontSize: 11,
          fontWeight: selected ? FontWeight.w800 : FontWeight.w600,
          color: selected ? scheme.primary : bodyColor,
        );
      }),
      iconTheme: WidgetStateProperty.resolveWith((states) {
        final selected = states.contains(WidgetState.selected);
        return IconThemeData(
          size: 23,
          color: selected ? scheme.primary : bodyColor,
        );
      }),
    ),
    chipTheme: ChipThemeData(
      backgroundColor: subtleFill,
      selectedColor: scheme.primaryContainer,
      side: BorderSide(color: borderColor),
      labelStyle: TextStyle(color: bodyColor, fontWeight: FontWeight.w700),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
    ),
    snackBarTheme: SnackBarThemeData(
      behavior: SnackBarBehavior.floating,
      backgroundColor: dark ? const Color(0xffe2e8f0) : const Color(0xff0f172a),
      contentTextStyle: TextStyle(
        color: dark ? const Color(0xff0f172a) : Colors.white,
        fontWeight: FontWeight.w700,
      ),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
    ),
    dialogTheme: DialogThemeData(
      backgroundColor: scheme.surface,
      surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
    ),
    expansionTileTheme: ExpansionTileThemeData(
      backgroundColor: scheme.surface,
      collapsedBackgroundColor: scheme.surface,
      iconColor: scheme.primary,
      collapsedIconColor: bodyColor,
      shape: Border(bottom: BorderSide(color: borderColor)),
      collapsedShape: Border(bottom: BorderSide(color: borderColor)),
    ),
  );
}
