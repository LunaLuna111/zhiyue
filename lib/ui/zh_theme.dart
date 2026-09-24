import 'package:flutter/material.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

abstract final class ZhPalette {
  /// The palette is intentionally centralized because a number of custom
  /// surfaces are shared by Material and shadcn widgets.  Keep the switch
  /// here so those surfaces change atomically with the app theme instead of
  /// briefly mixing light and dark colors during a settings update.
  static bool isDark = false;

  static const _lightBackground = Color(0xFFFFFFFF);
  static const _lightCanvas = Color(0xFFF7F7F7);
  static const _lightInk = Color(0xFF111111);
  static const _lightMutedInk = Color(0xFF666666);
  // Auxiliary copy is frequently rendered at 11.5–12px. Keep it above the
  // WCAG AA 4.5:1 contrast threshold on both the light and dark surfaces.
  static const _lightSubtleInk = Color(0xFF707070);
  static const _lightDisabledInk = Color(0xFF8A8A8A);
  static const _lightBorder = Color(0xFFE8E8E8);
  static const _lightPressed = Color(0xFFEDEDED);
  static const _lightDanger = Color(0xFFB42318);
  static const _lightDangerSurface = Color(0xFFFFF1F0);

  static const _darkBackground = Color(0xFF0D0F12);
  static const _darkCanvas = Color(0xFF171A1F);
  static const _darkInk = Color(0xFFF4F6F8);
  static const _darkMutedInk = Color(0xFFB7BEC8);
  static const _darkSubtleInk = Color(0xFF9AA3AF);
  static const _darkDisabledInk = Color(0xFF707985);
  static const _darkBorder = Color(0xFF2B313A);
  static const _darkPressed = Color(0xFF2A3038);
  static const _darkDanger = Color(0xFFFF8A80);
  static const _darkDangerSurface = Color(0xFF3A2024);
  static const _lightLink = Color(0xFF175199);
  static const _darkLink = Color(0xFF8AB4F8);
  static const _lightAccent = Color(0xFF1677FF);
  static const _darkAccent = Color(0xFF7AA7FF);
  static const _lightAccentSurface = Color(0xFFEAF3FF);
  static const _darkAccentSurface = Color(0xFF1E3150);
  static const _lightSoftSurface = Color(0xFFF8F8FA);
  static const _darkSoftSurface = Color(0xFF1B2026);
  static const _lightSoftBorder = Color(0xFFE3E5E8);
  static const _darkSoftBorder = Color(0xFF3A424C);
  static const _lightCodeSurface = Color(0xFFF6F6F8);
  static const _darkCodeSurface = Color(0xFF1E232A);
  static const _lightCodeBorder = Color(0xFFC9CCD3);
  static const _darkCodeBorder = Color(0xFF46505C);
  static const _lightQuoteText = Color(0xFF646873);
  static const _darkQuoteText = Color(0xFFD0D6DE);

  static Color get background => isDark ? _darkBackground : _lightBackground;
  static Color get canvas => isDark ? _darkCanvas : _lightCanvas;
  static Color get ink => isDark ? _darkInk : _lightInk;
  static Color get mutedInk => isDark ? _darkMutedInk : _lightMutedInk;
  static Color get subtleInk => isDark ? _darkSubtleInk : _lightSubtleInk;
  static Color get disabledInk => isDark ? _darkDisabledInk : _lightDisabledInk;
  static Color get border => isDark ? _darkBorder : _lightBorder;
  static Color get pressed => isDark ? _darkPressed : _lightPressed;
  static Color get danger => isDark ? _darkDanger : _lightDanger;
  static Color get dangerSurface =>
      isDark ? _darkDangerSurface : _lightDangerSurface;
  static Color get link => isDark ? _darkLink : _lightLink;
  static Color get accent => isDark ? _darkAccent : _lightAccent;
  static Color get accentSurface =>
      isDark ? _darkAccentSurface : _lightAccentSurface;
  static Color get softSurface => isDark ? _darkSoftSurface : _lightSoftSurface;
  static Color get softBorder => isDark ? _darkSoftBorder : _lightSoftBorder;
  static Color get codeSurface => isDark ? _darkCodeSurface : _lightCodeSurface;
  static Color get codeBorder => isDark ? _darkCodeBorder : _lightCodeBorder;
  static Color get quoteText => isDark ? _darkQuoteText : _lightQuoteText;
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
  static ShadThemeData get shad => shadFor(Brightness.light);

  static ShadThemeData shadFor(Brightness brightness) {
    final isDark = brightness == Brightness.dark;
    final baseScheme = isDark
        ? const ShadNeutralColorScheme.dark()
        : const ShadNeutralColorScheme.light();
    return ShadThemeData(
      brightness: brightness,
      colorScheme: baseScheme.copyWith(
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
  }

  static ThemeData get material => materialFor(Brightness.light);

  static ThemeData materialFor(Brightness brightness) {
    final isDark = brightness == Brightness.dark;
    final scheme = ColorScheme(
      brightness: brightness,
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
      surfaceContainerLow: isDark
          ? const Color(0xFF121519)
          : const Color(0xFFFCFCFC),
      surfaceContainer: ZhPalette.canvas,
      surfaceContainerHigh: isDark
          ? const Color(0xFF20252C)
          : const Color(0xFFF2F2F2),
      surfaceContainerHighest: isDark
          ? const Color(0xFF2A3038)
          : const Color(0xFFEDEDED),
      outline: isDark ? const Color(0xFF4A535F) : const Color(0xFFD5D5D5),
      outlineVariant: ZhPalette.border,
      shadow: isDark ? const Color(0x66000000) : const Color(0x12000000),
    );
    final base = ThemeData(
      brightness: brightness,
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
      appBarTheme: AppBarTheme(
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
      cardTheme: CardThemeData(
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
      inputDecorationTheme: InputDecorationTheme(
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
          disabledBackgroundColor: isDark
              ? const Color(0xFF30363D)
              : const Color(0xFFD8D8D8),
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
          side: BorderSide(color: ZhPalette.border),
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
      dividerTheme: DividerThemeData(
        color: ZhPalette.border,
        thickness: 1,
        space: 1,
      ),
      listTileTheme: ListTileThemeData(
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
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: ZhPalette.ink,
        contentTextStyle: TextStyle(color: ZhPalette.background),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(ZhRadius.input)),
        ),
      ),
      progressIndicatorTheme: ProgressIndicatorThemeData(
        color: ZhPalette.ink,
        linearTrackColor: ZhPalette.border,
        circularTrackColor: ZhPalette.border,
      ),
      chipTheme: base.chipTheme.copyWith(
        backgroundColor: ZhPalette.canvas,
        selectedColor: ZhPalette.ink,
        side: BorderSide(color: ZhPalette.border),
        shape: const StadiumBorder(),
        labelStyle: TextStyle(
          color: ZhPalette.ink,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
