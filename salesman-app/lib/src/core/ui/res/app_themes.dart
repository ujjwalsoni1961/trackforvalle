import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:track/src/core/ui/res/app_colors.dart';
import 'package:track/src/core/ui/res/page_transition.dart';

class AppThemes {
  static ThemeData lightTheme = ThemeData(
    pageTransitionsTheme: PageTransitionsTheme(
      builders: {
        TargetPlatform.android: CustomPageTransitionsBuilder(),
        TargetPlatform.iOS: CustomPageTransitionsBuilder(),
      },
    ),
    primaryColor: AppColors.accent,
    primaryColorLight: AppColors.accent,
    colorScheme: ColorScheme.light(
      primary: AppColors.accent,
      secondary: AppColors.accent,
      surface: AppColors.white,
      onPrimary: AppColors.white,
      onPrimaryContainer: AppColors.primary,
      tertiary: AppColors.grey,
      onSurfaceVariant: AppColors.black,
      onSurface: AppColors.black,
    ),
    scrollbarTheme: ScrollbarThemeData(
      thumbColor: WidgetStateProperty.all(AppColors.accent),
    ),
    expansionTileTheme: ExpansionTileThemeData(
      textColor: AppColors.black,
      collapsedTextColor: AppColors.black,
      collapsedIconColor: AppColors.black,
      iconColor: AppColors.black,
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        foregroundColor: AppColors.white,
        backgroundColor: AppColors.accent,
        surfaceTintColor: AppColors.accent,
        splashFactory: NoSplash.splashFactory,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
        textStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
        elevation: 0,
      ),
    ),
    snackBarTheme: SnackBarThemeData(
      contentTextStyle: TextStyle(
        color: AppColors.white,
        fontSize: 14,
        fontWeight: FontWeight.w500,
      ),
      backgroundColor: AppColors.primary,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
    ),
    drawerTheme: DrawerThemeData(
      backgroundColor: AppColors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topRight: Radius.circular(6),
          bottomRight: Radius.circular(6),
        ),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide(color: AppColors.grey.withOpacity(0.3)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide(color: AppColors.grey.withOpacity(0.3)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide(color: AppColors.accent, width: 2),
      ),
      disabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide(color: AppColors.grey.withOpacity(0.15)),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide(color: AppColors.red, width: 1),
      ),
      labelStyle: TextStyle(color: AppColors.grey, fontSize: 14),
      hintStyle: TextStyle(color: AppColors.grey.withOpacity(0.7), fontSize: 14),
      prefixIconColor: AppColors.grey,
      suffixIconColor: AppColors.grey,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      fillColor: AppColors.bgLight,
      filled: true,
    ),
    floatingActionButtonTheme: FloatingActionButtonThemeData(
      backgroundColor: AppColors.accent,
      extendedTextStyle: TextStyle(
        color: AppColors.white,
        fontSize: 14,
        fontWeight: FontWeight.w600,
      ),
      extendedIconLabelSpacing: 2,
      foregroundColor: AppColors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    ),
    datePickerTheme: darkTheme.datePickerTheme,
    cardTheme: CardThemeData(
      color: AppColors.white,
      margin: EdgeInsets.zero,
      surfaceTintColor: AppColors.transparent,
      shadowColor: AppColors.black.withOpacity(0.08),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    ),
    checkboxTheme: CheckboxThemeData(
      shape: RoundedRectangleBorder(
        side: BorderSide(color: AppColors.grey, width: 1.5),
        borderRadius: BorderRadius.circular(4),
      ),
      fillColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return AppColors.accent;
        }
        return AppColors.white;
      }),
      checkColor: WidgetStateProperty.all(AppColors.white),
      side: BorderSide(color: AppColors.grey, width: 1.5),
    ),
    switchTheme: SwitchThemeData(
      thumbColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return AppColors.accent;
        }
        return AppColors.grey;
      }),
      trackColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return AppColors.accent.withOpacity(0.3);
        }
        return AppColors.grey.withOpacity(0.3);
      }),
    ),

    textSelectionTheme: TextSelectionThemeData(
      cursorColor: AppColors.accent,
      selectionColor: AppColors.accent.withOpacity(0.3),
      selectionHandleColor: AppColors.accent,
    ),

    splashFactory: InkSparkle.constantTurbulenceSeedSplashFactory,
    appBarTheme: AppBarTheme(
      backgroundColor: AppColors.white,
      surfaceTintColor: AppColors.white,
      systemOverlayStyle: SystemUiOverlayStyle(
        statusBarIconBrightness: Brightness.dark,
        statusBarColor: AppColors.transparent,
      ),
      scrolledUnderElevation: 0.5,
      titleTextStyle: GoogleFonts.inter(
        color: AppColors.black,
        fontSize: 17,
        fontWeight: FontWeight.w600,
      ),
      iconTheme: IconThemeData(color: AppColors.black, size: 22),
      actionsIconTheme: IconThemeData(color: AppColors.black, size: 22),
    ),
    iconTheme: IconThemeData(color: AppColors.black, size: 22),
    scaffoldBackgroundColor: AppColors.bgLight,
    textTheme: TextTheme(
      displayLarge: TextStyle(
        color: AppColors.black,
        fontSize: 40,
        fontWeight: FontWeight.bold,
      ),
      displayMedium: TextStyle(
        color: AppColors.black,
        fontSize: 32,
        fontWeight: FontWeight.bold,
      ),
      displaySmall: TextStyle(
        color: AppColors.black,
        fontSize: 24,
        fontWeight: FontWeight.bold,
      ),
      titleLarge: TextStyle(
        color: AppColors.black,
        fontSize: 18,
        fontWeight: FontWeight.w600,
      ),
      titleMedium: TextStyle(
        color: AppColors.black,
        fontSize: 16,
        fontWeight: FontWeight.w600,
      ),
      titleSmall: TextStyle(
        color: AppColors.black,
        fontSize: 14,
        fontWeight: FontWeight.w600,
      ),
      bodyLarge: TextStyle(
        color: AppColors.black,
        fontSize: 14,
        fontWeight: FontWeight.w500,
      ),
      bodyMedium: TextStyle(
        color: AppColors.black,
        fontSize: 12,
        fontWeight: FontWeight.w500,
      ),
      bodySmall: TextStyle(
        color: AppColors.black,
        fontSize: 10,
        fontWeight: FontWeight.w500,
      ),
      labelLarge: TextStyle(color: AppColors.grey, fontSize: 14),
      labelMedium: TextStyle(color: AppColors.grey, fontSize: 12),
      labelSmall: TextStyle(color: AppColors.grey, fontSize: 10),
    ),
    useMaterial3: true,
  );

  static ThemeData darkTheme = ThemeData(
    pageTransitionsTheme: PageTransitionsTheme(
      builders: {
        TargetPlatform.android: CustomPageTransitionsBuilder(),
        TargetPlatform.iOS: CustomPageTransitionsBuilder(),
      },
    ),
    primaryColor: AppColors.accent,
    primaryColorLight: AppColors.accent,
    colorScheme: ColorScheme.dark(
      primary: AppColors.accent,
      secondary: AppColors.accent,
      surface: AppColors.bgMainDark,
      onPrimaryContainer: AppColors.greyDark,
      tertiary: AppColors.grey,
      onSurfaceVariant: AppColors.white,
    ),
    scrollbarTheme: ScrollbarThemeData(
      thumbColor: WidgetStateProperty.all(AppColors.accent),
    ),
    expansionTileTheme: ExpansionTileThemeData(
      textColor: AppColors.white,
      collapsedTextColor: AppColors.white,
      collapsedIconColor: AppColors.white,
      iconColor: AppColors.white,
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        foregroundColor: AppColors.white,
        backgroundColor: AppColors.accent,
        surfaceTintColor: AppColors.accent,
        splashFactory: NoSplash.splashFactory,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
        textStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
        elevation: 0,
      ),
    ),
    snackBarTheme: SnackBarThemeData(
      contentTextStyle: TextStyle(
        color: AppColors.white,
        fontSize: 14,
        fontWeight: FontWeight.bold,
      ),
    ),
    drawerTheme: DrawerThemeData(
      backgroundColor: AppColors.bgMainDark,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topRight: Radius.circular(6),
          bottomRight: Radius.circular(6),
        ),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide(
          color: AppColors.white.withOpacity(0.3),
          width: 1,
        ),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide(
          color: AppColors.white.withOpacity(0.3),
          width: 1,
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide(
          color: AppColors.accent,
          width: 2,
        ),
      ),
      labelStyle: TextStyle(color: AppColors.white, fontSize: 14),
      hintStyle: TextStyle(color: AppColors.grey, fontSize: 14),
      prefixIconColor: AppColors.grey,
      suffixIconColor: AppColors.grey,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      fillColor: AppColors.greyDark,
      filled: true,
    ),
    floatingActionButtonTheme: FloatingActionButtonThemeData(
      backgroundColor: AppColors.accent,
      extendedTextStyle: TextStyle(
        color: AppColors.white,
        fontSize: 14,
        fontWeight: FontWeight.w600,
      ),
      extendedIconLabelSpacing: 2,
      foregroundColor: AppColors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    ),
    cardTheme: CardThemeData(
      color: AppColors.greyDark,
      surfaceTintColor: AppColors.transparent,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    ),
    checkboxTheme: CheckboxThemeData(
      shape: RoundedRectangleBorder(
        side: BorderSide(color: AppColors.grey, width: 1.5),
        borderRadius: BorderRadius.circular(4),
      ),
      fillColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return AppColors.accent;
        }
        return AppColors.greyDark;
      }),
      checkColor: WidgetStateProperty.all(AppColors.white),
      side: BorderSide(color: AppColors.grey, width: 1.5),
    ),
    switchTheme: SwitchThemeData(
      thumbColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return AppColors.accent;
        }
        return AppColors.grey;
      }),
      trackColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return AppColors.accent.withOpacity(0.5);
        }
        return AppColors.greyDark;
      }),
    ),
    textSelectionTheme: TextSelectionThemeData(
      cursorColor: AppColors.accent,
      selectionColor: AppColors.accent.withOpacity(0.5),
      selectionHandleColor: AppColors.accent,
    ),
    splashFactory: InkSparkle.constantTurbulenceSeedSplashFactory,
    appBarTheme: AppBarTheme(
      backgroundColor: AppColors.transparent,
      surfaceTintColor: AppColors.greyDark,
      systemOverlayStyle: SystemUiOverlayStyle(
        statusBarIconBrightness: Brightness.light,
        statusBarColor: AppColors.transparent,
      ),
      scrolledUnderElevation: 0,
      titleTextStyle: GoogleFonts.inter(
        color: AppColors.white,
        fontSize: 17,
        fontWeight: FontWeight.w600,
      ),
      iconTheme: IconThemeData(color: AppColors.grey, size: 22),
      actionsIconTheme: IconThemeData(color: AppColors.grey, size: 22),
    ),
    iconTheme: IconThemeData(color: AppColors.white, size: 22),
    scaffoldBackgroundColor: AppColors.bgMainDark,
    textTheme: TextTheme(
      displayLarge: TextStyle(
        color: AppColors.white,
        fontSize: 40,
        fontWeight: FontWeight.bold,
      ),
      displayMedium: TextStyle(
        color: AppColors.white,
        fontSize: 32,
        fontWeight: FontWeight.bold,
      ),
      displaySmall: TextStyle(
        color: AppColors.white,
        fontSize: 24,
        fontWeight: FontWeight.bold,
      ),
      titleLarge: TextStyle(
        color: AppColors.white,
        fontSize: 18,
        fontWeight: FontWeight.w600,
      ),
      titleMedium: TextStyle(
        color: AppColors.white,
        fontSize: 16,
        fontWeight: FontWeight.w600,
      ),
      titleSmall: TextStyle(
        color: AppColors.white,
        fontSize: 14,
        fontWeight: FontWeight.w600,
      ),
      bodyLarge: TextStyle(
        color: AppColors.white,
        fontSize: 14,
        fontWeight: FontWeight.w500,
      ),
      bodyMedium: TextStyle(
        color: AppColors.white,
        fontSize: 12,
        fontWeight: FontWeight.w500,
      ),
      bodySmall: TextStyle(
        color: AppColors.white,
        fontSize: 10,
        fontWeight: FontWeight.w500,
      ),
      labelLarge: TextStyle(color: AppColors.grey, fontSize: 14),
      labelMedium: TextStyle(color: AppColors.grey, fontSize: 12),
      labelSmall: TextStyle(color: AppColors.grey, fontSize: 10),
    ),
    useMaterial3: true,
  );
}
