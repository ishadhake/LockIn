import 'package:flutter/material.dart';

// LockIn Theme Constants
const Color kPrimaryColor = Color(0xFF7B61FF); // Indigo-Purple
const Color kSurfaceColor = Color(0xFF0F121A); // Dark Navy Surface
const Color kTextColor = Colors.white; // White text
const Color kTextSubtleColor = Color(0xFFB0B0B0); // Subtle gray text
const Color kAccentColor = Color(0xFF3BA3FF); // Electric Blue accent
const Color kSuccessColor = Color(0xFF4CAF50); // XP / success

const BorderRadius kRadiusLarge = BorderRadius.all(Radius.circular(24));
const BorderRadius kRadiusMedium = BorderRadius.all(Radius.circular(16));
const BorderRadius kRadiusSmall = BorderRadius.all(Radius.circular(12));

LinearGradient get kPrimaryGradient => const LinearGradient(
  colors: [Color(0xFF7B61FF), Color(0xFF3BA3FF)],
  begin: Alignment.topLeft,
  end: Alignment.bottomRight,
);

LinearGradient get kSoftGradient => const LinearGradient(
  colors: [Color(0xFF2A2A2A), Color(0xFF1A1A1A)],
  begin: Alignment.topLeft,
  end: Alignment.bottomRight,
);

ThemeData buildLockInDarkTheme(TextTheme baseTextTheme) {
  final colorScheme = const ColorScheme.dark(
    primary: kPrimaryColor,
    secondary: kAccentColor,
    surface: kSurfaceColor,
    onPrimary: Colors.white,
    onSecondary: Colors.black,
    onSurface: kTextColor,
  );

  return ThemeData(
    useMaterial3: true,
    colorScheme: colorScheme,
    scaffoldBackgroundColor: kSurfaceColor,
    cardColor: const Color(0xFF242424),
    textTheme: baseTextTheme.apply(
      bodyColor: kTextColor,
      displayColor: kTextColor,
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: Color(0xFF121622),
      elevation: 0,
      foregroundColor: kTextColor,
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: const Color(0x1AFFFFFF),
      hintStyle: const TextStyle(color: kTextSubtleColor),
      border: OutlineInputBorder(
        borderRadius: kRadiusMedium,
        borderSide: const BorderSide(color: Color(0x33FFFFFF)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: kRadiusMedium,
        borderSide: const BorderSide(color: Color(0x22FFFFFF)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: kRadiusMedium,
        borderSide: const BorderSide(color: kAccentColor, width: 1.5),
      ),
    ),
  );
}
