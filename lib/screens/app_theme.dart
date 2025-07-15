import 'package:flutter/material.dart';

class AppTheme {
  // ✅ WASHMOOSE BRAND COLORS (Keep these)
  static const Color primaryColor = Color(0xFF00C2CB); // WashMoose Teal
  static const Color secondaryColor = Color(0xFF42A5F5); // Light blue
  static const Color accentColor = Color(0xFF4CAF50); // Green
  
  // ✅ PROFESSIONAL MODERN LIGHT THEME COLORS
  static const Color lightBackgroundColor = Color(0xFFFAFBFC); // Soft off-white (not harsh pure white)
  static const Color lightCardColor = Color(0xFFFFFFFF); // Clean white for cards
  static const Color lightSurfaceColor = Color(0xFFF7F8FA); // Very subtle grey for surfaces
  
  // ✅ READABLE DARK TEXT COLORS (Professional & Clear)
  static const Color lightPrimaryTextColor = Color(0xFF1A202C); // Rich dark - excellent readability
  static const Color lightSecondaryTextColor = Color(0xFF4A5568); // Medium dark - professional
  static const Color lightTertiaryTextColor = Color(0xFF718096); // Balanced grey - still readable
  static const Color lightHintTextColor = Color(0xFF9CA3AF); // Light grey for hints only
  
  // ✅ BORDER AND DIVIDER COLORS
  static const Color lightBorderColor = Color(0xFFE2E8F0); // Subtle borders
  static const Color lightDividerColor = Color(0xFFEDF2F7); // Very light dividers
  
  // ✅ BACKWARD COMPATIBILITY
  static const Color backgroundColor = lightBackgroundColor;
  static const Color cardColor = lightCardColor;
  static const Color surfaceColor = lightSurfaceColor;
  
  // ✅ PROFESSIONAL MODERN LIGHT THEME
  static ThemeData getLightTheme() {
    return ThemeData(
      brightness: Brightness.light,
      primaryColor: primaryColor,
      scaffoldBackgroundColor: lightBackgroundColor, // Soft off-white background
      cardColor: lightCardColor,
      
      // ✅ MODERN COLOR SCHEME
      colorScheme: const ColorScheme.light(
        primary: primaryColor, // WashMoose teal
        secondary: secondaryColor,
        tertiary: accentColor,
        surface: lightSurfaceColor,
        background: lightBackgroundColor,
        onPrimary: Colors.white, // White text on teal buttons
        onSecondary: Colors.white,
        onSurface: lightPrimaryTextColor, // Rich dark text
        onBackground: lightPrimaryTextColor, // Rich dark text on soft background
        outline: lightBorderColor, // Subtle borders
        surfaceVariant: lightSurfaceColor,
        onSurfaceVariant: lightSecondaryTextColor,
      ),
      
      // ✅ APP BAR (Keep WashMoose branding)
      appBarTheme: const AppBarTheme(
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        elevation: 0, // Modern flat design
        centerTitle: true,
        iconTheme: IconThemeData(color: Colors.white),
        titleTextStyle: TextStyle(
          color: Colors.white,
          fontSize: 18,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.5,
        ),
      ),
      
      // ✅ READABLE TEXT THEME (Much better contrast)
      textTheme: const TextTheme(
        // Headlines - Rich dark text
        displayLarge: TextStyle(
          color: lightPrimaryTextColor,
          fontSize: 32,
          fontWeight: FontWeight.bold,
          letterSpacing: -0.5,
        ),
        displayMedium: TextStyle(
          color: lightPrimaryTextColor,
          fontSize: 28,
          fontWeight: FontWeight.bold,
          letterSpacing: -0.25,
        ),
        displaySmall: TextStyle(
          color: lightPrimaryTextColor,
          fontSize: 24,
          fontWeight: FontWeight.w600,
        ),
        
        // Titles - Professional and readable
        titleLarge: TextStyle(
          color: lightPrimaryTextColor,
          fontSize: 20,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.15,
        ),
        titleMedium: TextStyle(
          color: lightPrimaryTextColor,
          fontSize: 18,
          fontWeight: FontWeight.w500,
          letterSpacing: 0.15,
        ),
        titleSmall: TextStyle(
          color: lightSecondaryTextColor,
          fontSize: 16,
          fontWeight: FontWeight.w500,
          letterSpacing: 0.1,
        ),
        
        // Body text - Clear and readable
        bodyLarge: TextStyle(
          color: lightPrimaryTextColor,
          fontSize: 16,
          fontWeight: FontWeight.normal,
          letterSpacing: 0.5,
          height: 1.5,
        ),
        bodyMedium: TextStyle(
          color: lightSecondaryTextColor,
          fontSize: 14,
          fontWeight: FontWeight.normal,
          letterSpacing: 0.25,
          height: 1.4,
        ),
        bodySmall: TextStyle(
          color: lightTertiaryTextColor,
          fontSize: 12,
          fontWeight: FontWeight.normal,
          letterSpacing: 0.4,
          height: 1.33,
        ),
        
        // Labels - Clear and accessible
        labelLarge: TextStyle(
          color: lightPrimaryTextColor,
          fontSize: 14,
          fontWeight: FontWeight.w500,
          letterSpacing: 1.25,
        ),
        labelMedium: TextStyle(
          color: lightSecondaryTextColor,
          fontSize: 12,
          fontWeight: FontWeight.w500,
          letterSpacing: 1.5,
        ),
        labelSmall: TextStyle(
          color: lightTertiaryTextColor,
          fontSize: 11,
          fontWeight: FontWeight.w500,
          letterSpacing: 1.5,
        ),
      ),
      
      // ✅ MODERN BOTTOM NAVIGATION
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: lightCardColor, // Clean white
        selectedItemColor: primaryColor, // Teal for selected
        unselectedItemColor: lightTertiaryTextColor, // Readable grey
        type: BottomNavigationBarType.fixed,
        elevation: 8,
        selectedLabelStyle: TextStyle(
          fontWeight: FontWeight.w600, 
          fontSize: 12,
          letterSpacing: 0.5,
        ),
        unselectedLabelStyle: TextStyle(
          fontWeight: FontWeight.normal, 
          fontSize: 12,
          letterSpacing: 0.5,
        ),
      ),
      
      // ✅ PROFESSIONAL CARDS
      cardTheme: CardThemeData(
        color: lightCardColor, // Clean white
        elevation: 2,
        margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 0),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        shadowColor: Colors.black.withOpacity(0.04), // Very subtle shadow
      ),
      
      // ✅ MODERN BUTTONS
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryColor,
          foregroundColor: Colors.white,
          elevation: 2,
          shadowColor: primaryColor.withOpacity(0.25),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.5,
          ),
        ),
      ),
      
      // ✅ OUTLINED BUTTONS
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: primaryColor,
          side: const BorderSide(color: primaryColor, width: 1.5),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.5,
          ),
        ),
      ),
      
      // ✅ TEXT BUTTONS
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: primaryColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          textStyle: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.5,
          ),
        ),
      ),
      
      // ✅ PROFESSIONAL INPUT FIELDS
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: lightSurfaceColor, // Subtle background
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        
        // Modern borders
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: lightBorderColor, width: 1),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: lightBorderColor, width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: primaryColor, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.red, width: 1),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.red, width: 2),
        ),
        
        // Readable text styles
        labelStyle: const TextStyle(
          color: lightSecondaryTextColor,
          fontSize: 16,
          fontWeight: FontWeight.w500,
        ),
        hintStyle: const TextStyle(
          color: lightHintTextColor,
          fontSize: 16,
          fontWeight: FontWeight.normal,
        ),
        helperStyle: const TextStyle(
          color: lightTertiaryTextColor,
          fontSize: 12,
        ),
        errorStyle: const TextStyle(
          color: Colors.red,
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
      ),
      
      // ✅ SUBTLE DIVIDERS
      dividerTheme: const DividerThemeData(
        color: lightDividerColor,
        thickness: 1,
        space: 1,
      ),
      
      // ✅ READABLE ICONS
      iconTheme: const IconThemeData(
        color: lightSecondaryTextColor,
        size: 24,
      ),
      
      // ✅ PROFESSIONAL LIST TILES
      listTileTheme: const ListTileThemeData(
        textColor: lightPrimaryTextColor,
        iconColor: lightSecondaryTextColor,
        tileColor: lightBackgroundColor,
        contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        titleTextStyle: TextStyle(
          color: lightPrimaryTextColor,
          fontSize: 16,
          fontWeight: FontWeight.w500,
        ),
        subtitleTextStyle: TextStyle(
          color: lightSecondaryTextColor,
          fontSize: 14,
        ),
      ),
      
      // ✅ FLOATING ACTION BUTTON
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        elevation: 6,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(16)),
        ),
      ),
      
      // ✅ MODERN SWITCHES
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return primaryColor;
          }
          return const Color(0xFFCBD5E0);
        }),
        trackColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return primaryColor.withOpacity(0.3);
          }
          return const Color(0xFFE2E8F0);
        }),
      ),
      
      // ✅ MODERN CHECKBOXES
      checkboxTheme: CheckboxThemeData(
        fillColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return primaryColor;
          }
          return Colors.transparent;
        }),
        checkColor: WidgetStateProperty.all(Colors.white),
        side: const BorderSide(color: lightBorderColor, width: 2),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(4),
        ),
      ),
      
      // ✅ PROFESSIONAL DIALOGS
      dialogTheme: const DialogThemeData(
        backgroundColor: lightCardColor,
        elevation: 24,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(16)),
        ),
        titleTextStyle: TextStyle(
          color: lightPrimaryTextColor,
          fontSize: 20,
          fontWeight: FontWeight.w600,
        ),
        contentTextStyle: TextStyle(
          color: lightSecondaryTextColor,
          fontSize: 16,
          height: 1.5,
        ),
      ),
      
      // ✅ MODERN SNACKBARS
      snackBarTheme: SnackBarThemeData(
        backgroundColor: lightPrimaryTextColor,
        contentTextStyle: const TextStyle(
          color: Colors.white,
          fontSize: 14,
          fontWeight: FontWeight.w500,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        behavior: SnackBarBehavior.floating,
        elevation: 6,
      ),
      
      // ✅ PROGRESS INDICATORS
      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: primaryColor,
        linearTrackColor: lightBorderColor,
        circularTrackColor: lightBorderColor,
      ),
      
      // ✅ MODERN TAB BAR
      tabBarTheme: const TabBarThemeData(
        labelColor: primaryColor,
        unselectedLabelColor: lightSecondaryTextColor,
        indicatorColor: primaryColor,
        indicatorSize: TabBarIndicatorSize.label,
        labelStyle: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.5,
        ),
        unselectedLabelStyle: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.normal,
        ),
      ),
    );
  }
  
  // ✅ FORCE PROFESSIONAL LIGHT THEME EVERYWHERE
  static ThemeData getDarkTheme() {
    return getLightTheme(); // Always return professional light theme
  }
}