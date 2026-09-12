import 'package:flutter/material.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

abstract final class ZhPalette {
  static const background = Color(0xFFFFFFFF);
  static const canvas = Color(0xFFF7F7F7);
  static const ink = Color(0xFF111111);
  static const mutedInk = Color(0xFF666666);
  // Auxiliary copy is frequently rendered at 11.5–12px. Keep it above the
  // WCAG AA 4.5:1 contrast threshold on both white and the app canvas.
  static const subtleInk = Color(0xFF707070);
  static const disabledInk = Color(0xFF8A8A8A);
  static const border = Color(0xFFE8E8E8);
  static const pressed = Color(0xFFEDEDED);
  static const danger = Color(0xFFB42318);
  static const dangerSurface = Color(0xFFFFF1F0);
}

abstract final class ZhSpace {
  static const xxs = 4.0;
  static const xs = 8.0;
  static const sm = 12.0;
  static const md = 16.0;
  static const lg = 24.0;
  static const xl = 32.0;
}

abstract final class ZhRadius {
  static const input = 14.0;
  static const card = 18.0;
  static const hero = 24.0;
  static const pill = 999.0;
}

abstract final class ZhTheme {
  static ShadThemeData get shad => ShadThemeData(
    brightness: Brightness.light,
    colorScheme: const ShadNeutralColorScheme.light().copyWith(
      background: ZhPalette.background,
      foreground: ZhPalette.ink,
      card: ZhPalette.background,
      cardForeground: ZhPalette.ink,
      primary: ZhPalette.ink,
      primaryForeground: ZhPalette.background,
      secondary: ZhPalette.canvas,
      secondaryForeground: ZhPalette.ink,
      muted: ZhPalette.canvas,
      mutedForeground: ZhPalette.mutedInk,
      accent: ZhPalette.pressed,
      accentForeground: ZhPalette.ink,
      border: ZhPalette.border,
      input: ZhPalette.border,
      ring: ZhPalette.ink,
      destructive: ZhPalette.danger,
      destructiveForeground: ZhPalette.background,
    ),
    radius: const BorderRadius.all(Radius.circular(ZhRadius.input)),
    disableSecondaryBorder: true,
  );

  static ThemeData get material {
    const scheme = ColorScheme.light(
      primary: ZhPalette.ink,
      onPrimary: ZhPalette.background,
      primaryContainer: ZhPalette.canvas,
      onPrimaryContainer: ZhPalette.ink,
      secondary: ZhPalette.canvas,
      onSecondary: ZhPalette.ink,
      secondaryContainer: ZhPalette.canvas,
      onSecondaryContainer: ZhPalette.ink,
      error: ZhPalette.danger,
      onError: ZhPalette.background,
      errorContainer: ZhPalette.dangerSurface,
      onErrorContainer: ZhPalette.danger,
      surface: ZhPalette.background,
      onSurface: ZhPalette.ink,
      surfaceContainerLowest: ZhPalette.background,
      surfaceContainerLow: Color(0xFFFCFCFC),
      surfaceContainer: ZhPalette.canvas,
      surfaceContainerHigh: Color(0xFFF2F2F2),
      surfaceContainerHighest: Color(0xFFEDEDED),
      outline: Color(0xFFD5D5D5),
      outlineVariant: ZhPalette.border,
      shadow: Color(0x12000000),
    );
    final base = ThemeData(
      brightness: Brightness.light,
      useMaterial3: true,
      colorScheme: scheme,
      scaffoldBackgroundColor: ZhPalette.background,
      canvasColor: ZhPalette.background,
      splashFactory: InkSparkle.splashFactory,
    );
    return base.copyWith(
      textTheme: base.textTheme.copyWith(
        headlineLarge: base.textTheme.headlineLarge?.copyWith(
          color: ZhPalette.ink,
          fontSize: 34,
          height: 1.15,
          fontWeight: FontWeight.w800,
          letterSpacing: -0.8,
        ),
        headlineMedium: base.textTheme.headlineMedium?.copyWith(
          color: ZhPalette.ink,
          fontSize: 28,
          height: 1.2,
          fontWeight: FontWeight.w800,
          letterSpacing: -0.5,
        ),
        titleLarge: base.textTheme.titleLarge?.copyWith(
          color: ZhPalette.ink,
          fontSize: 21,
          height: 1.25,
          fontWeight: FontWeight.w700,
        ),
        titleMedium: base.textTheme.titleMedium?.copyWith(
          color: ZhPalette.ink,
          fontSize: 16,
          height: 1.35,
          fontWeight: FontWeight.w700,
        ),
        bodyLarge: base.textTheme.bodyLarge?.copyWith(
          color: ZhPalette.ink,
          fontSize: 16,
          height: 1.7,
        ),
        bodyMedium: base.textTheme.bodyMedium?.copyWith(
          color: ZhPalette.ink,
          fontSize: 14,
          height: 1.6,
        ),
        bodySmall: base.textTheme.bodySmall?.copyWith(
          color: ZhPalette.mutedInk,
          height: 1.5,
        ),
        labelLarge: base.textTheme.labelLarge?.copyWith(
          color: ZhPalette.ink,
          fontWeight: FontWeight.w700,
        ),
        labelSmall: base.textTheme.labelSmall?.copyWith(
          color: ZhPalette.subtleInk,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.45,
        ),
      ),
      appBarTheme: const AppBarTheme(
        elevation: 0,
        scrolledUnderElevation: 0,
        backgroundColor: ZhPalette.background,
        foregroundColor: ZhPalette.ink,
        surfaceTintColor: Colors.transparent,
        toolbarHeight: 68,
        titleSpacing: ZhSpace.md,
        titleTextStyle: TextStyle(
          color: ZhPalette.ink,
          fontSize: 22,
          height: 1.2,
          fontWeight: FontWeight.w800,
          letterSpacing: -0.35,
        ),
      ),
      cardTheme: const CardThemeData(
        elevation: 0,
        color: ZhPalette.background,
        surfaceTintColor: Colors.transparent,
        shadowColor: Colors.transparent,
        margin: EdgeInsets.symmetric(horizontal: ZhSpace.md, vertical: 6),
        clipBehavior: Clip.antiAlias,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(ZhRadius.card)),
          side: BorderSide(color: ZhPalette.border),
        ),
      ),
      navigationBarTheme: NavigationBarThemeData(
        height: 62,
        elevation: 0,
        backgroundColor: ZhPalette.background,
        surfaceTintColor: Colors.transparent,
        indicatorColor: ZhPalette.ink,
        indicatorShape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        iconTheme: WidgetStateProperty.resolveWith((states) {
          final selected = states.contains(WidgetState.selected);
          return IconThemeData(
            color: selected ? ZhPalette.background : ZhPalette.mutedInk,
            size: selected ? 21 : 20,
          );
        }),
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          return TextStyle(
            color: states.contains(WidgetState.selected)
                ? ZhPalette.ink
                : ZhPalette.mutedInk,
            fontSize: 11,
            fontWeight: states.contains(WidgetState.selected)
                ? FontWeight.w700
                : FontWeight.w600,
          );
        }),
      ),
      inputDecorationTheme: const InputDecorationTheme(
        filled: true,
        fillColor: ZhPalette.canvas,
        contentPadding: EdgeInsets.symmetric(
          horizontal: ZhSpace.md,
          vertical: 14,
        ),
        labelStyle: TextStyle(color: ZhPalette.mutedInk),
        hintStyle: TextStyle(color: ZhPalette.subtleInk),
        floatingLabelStyle: TextStyle(
          color: ZhPalette.ink,
          fontWeight: FontWeight.w700,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(ZhRadius.input)),
          borderSide: BorderSide(color: ZhPalette.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(ZhRadius.input)),
          borderSide: BorderSide(color: ZhPalette.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(ZhRadius.input)),
          borderSide: BorderSide(color: ZhPalette.ink, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(ZhRadius.input)),
          borderSide: BorderSide(color: ZhPalette.danger),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          minimumSize: const Size(44, 48),
          backgroundColor: ZhPalette.ink,
          foregroundColor: ZhPalette.background,
          disabledBackgroundColor: const Color(0xFFD8D8D8),
          disabledForegroundColor: ZhPalette.disabledInk,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(ZhRadius.input),
          ),
          textStyle: const TextStyle(fontWeight: FontWeight.w700),
          elevation: 0,
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          minimumSize: const Size(44, 48),
          backgroundColor: ZhPalette.background,
          foregroundColor: ZhPalette.ink,
          side: const BorderSide(color: ZhPalette.border),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(ZhRadius.input),
          ),
          textStyle: const TextStyle(fontWeight: FontWeight.w700),
          elevation: 0,
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: ZhPalette.ink,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(ZhRadius.input),
          ),
          textStyle: const TextStyle(fontWeight: FontWeight.w700),
        ),
      ),
      iconButtonTheme: IconButtonThemeData(
        style: IconButton.styleFrom(
          foregroundColor: ZhPalette.ink,
          backgroundColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(ZhRadius.input),
          ),
        ),
      ),
      dividerTheme: const DividerThemeData(
        color: ZhPalette.border,
        thickness: 1,
        space: 1,
      ),
      listTileTheme: const ListTileThemeData(
        iconColor: ZhPalette.ink,
        textColor: ZhPalette.ink,
        contentPadding: EdgeInsets.symmetric(
          horizontal: ZhSpace.md,
          vertical: ZhSpace.xs,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(ZhRadius.input)),
        ),
      ),
      snackBarTheme: const SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: ZhPalette.ink,
        contentTextStyle: TextStyle(color: ZhPalette.background),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(ZhRadius.input)),
        ),
      ),
      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: ZhPalette.ink,
        linearTrackColor: ZhPalette.border,
        circularTrackColor: ZhPalette.border,
      ),
      chipTheme: base.chipTheme.copyWith(
        backgroundColor: ZhPalette.canvas,
        selectedColor: ZhPalette.ink,
        side: const BorderSide(color: ZhPalette.border),
        shape: const StadiumBorder(),
        labelStyle: const TextStyle(
          color: ZhPalette.ink,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
