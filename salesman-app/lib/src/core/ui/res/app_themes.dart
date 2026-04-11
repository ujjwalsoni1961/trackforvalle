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
    colorScheme: ColorScheme.dark(
      primary: AppColors.accent,
      secondary: AppColors.accent,
      surface: AppColors.bgMain,
      onPrimaryContainer: AppColors.greyDark,
      tertiary: AppColors.grey,
      onSurfaceVariant: AppColors.black,
      onSurface: AppColors.accent,
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
        foregroundColor: AppColors.greyDark,
        backgroundColor: AppColors.accent.withOpacity(0.8),
        surfaceTintColor: AppColors.accent.withOpacity(0.8),
        splashFactory: NoSplash.splashFactory,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        textStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
      ),
    ),
    snackBarTheme: SnackBarThemeData(
      contentTextStyle: TextStyle(
        color: AppColors.black,
        fontSize: 14,
        fontWeight: FontWeight.bold,
      ),
    ),
    drawerTheme: DrawerThemeData(
      backgroundColor: AppColors.bgMain,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topRight: Radius.circular(6),
          bottomRight: Radius.circular(6),
        ),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: AppColors.greyDark.withOpacity(0.8)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: AppColors.greyDark.withOpacity(0.8)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: AppColors.accent, width: 2),
      ),
      disabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: AppColors.greyDark.withOpacity(0.1)),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: AppColors.red, width: 1),
      ),
      labelStyle: TextStyle(color: AppColors.black, fontSize: 12),
      hintStyle: TextStyle(color: AppColors.grey, fontSize: 14),
      prefixIconColor: AppColors.grey,
      suffixIconColor: AppColors.grey,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      fillColor: AppColors.greyDark.withOpacity(0.05),
      filled: false,
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
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(32)),
    ),
    datePickerTheme: darkTheme.datePickerTheme,
    cardTheme: CardThemeData(
      color: AppColors.white,
      margin: EdgeInsets.zero,
      surfaceTintColor: AppColors.transparent,
      shadowColor: AppColors.black.withOpacity(0.6),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    ),
    checkboxTheme: CheckboxThemeData(
      shape: RoundedRectangleBorder(
        side: BorderSide(color: AppColors.grey, width: 1.5),
        borderRadius: BorderRadius.circular(6),
      ),
      fillColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return AppColors.white;
        }
        return AppColors.white;
      }),
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
      cursorColor: AppColors.accent, // Customize the cursor color
      selectionColor: AppColors.accent.withOpacity(
        0.5,
      ), // Background color of the selected text

      selectionHandleColor: AppColors.accent, // Color of the selection handles
      // Customize more if needed
    ),

    splashFactory: InkSparkle.constantTurbulenceSeedSplashFactory,
    appBarTheme: AppBarTheme(
      backgroundColor: AppColors.transparent,
      surfaceTintColor: AppColors.greyDark,
      systemOverlayStyle: SystemUiOverlayStyle(
        statusBarIconBrightness: Brightness.dark,
        statusBarColor: AppColors.transparent,
      ),
      scrolledUnderElevation: 0,
      titleTextStyle: GoogleFonts.aBeeZee(
        color: AppColors.black,
        fontSize: 16,
        fontWeight: FontWeight.w600,
      ),
      iconTheme: IconThemeData(color: AppColors.grey, size: 20),
      actionsIconTheme: IconThemeData(color: AppColors.grey, size: 20),
    ),
    iconTheme: IconThemeData(color: AppColors.black, size: 20),
    scaffoldBackgroundColor: AppColors.bgMain,
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
        fontWeight: FontWeight.bold,
      ),
      titleMedium: TextStyle(
        color: AppColors.black,
        fontSize: 16,
        fontWeight: FontWeight.bold,
      ),
      titleSmall: TextStyle(
        color: AppColors.black,
        fontSize: 14,
        fontWeight: FontWeight.bold,
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
        foregroundColor: AppColors.greyDark,
        backgroundColor: AppColors.accent.withOpacity(0.8),
        surfaceTintColor: AppColors.accent.withOpacity(0.8),
        splashFactory: NoSplash.splashFactory,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        textStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
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
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(
          color: AppColors.white.withOpacity(0.5),
          width: 1,
        ),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(
          color: AppColors.white.withOpacity(0.5),
          width: 1,
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(
          color: AppColors.white.withOpacity(0.5),
          width: 1,
        ),
      ),
      labelStyle: TextStyle(color: AppColors.white, fontSize: 12),
      hintStyle: TextStyle(color: AppColors.grey, fontSize: 14),
      prefixIconColor: AppColors.grey,
      suffixIconColor: AppColors.grey,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      fillColor: AppColors.bgMainDark,
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
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(32)),
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
        borderRadius: BorderRadius.circular(6),
      ),
      fillColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return AppColors.white;
        }
        return AppColors.white;
      }),
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
      cursorColor: AppColors.accent, // Customize the cursor color
      selectionColor: AppColors.accent.withOpacity(
        0.5,
      ), // Background color of the selected text
      selectionHandleColor: AppColors.accent, // Color of the selection handles
      // Customize more if needed
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
      titleTextStyle: GoogleFonts.aBeeZee(
        color: AppColors.white,
        fontSize: 16,
        fontWeight: FontWeight.w600,
      ),
      iconTheme: IconThemeData(color: AppColors.grey, size: 20),
      actionsIconTheme: IconThemeData(color: AppColors.grey, size: 20),
    ),
    iconTheme: IconThemeData(color: AppColors.white, size: 20),
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
        fontWeight: FontWeight.bold,
      ),
      titleMedium: TextStyle(
        color: AppColors.white,
        fontSize: 16,
        fontWeight: FontWeight.bold,
      ),
      titleSmall: TextStyle(
        color: AppColors.white,
        fontSize: 14,
        fontWeight: FontWeight.bold,
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
