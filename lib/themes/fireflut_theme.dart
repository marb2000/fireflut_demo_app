import 'package:fireflut_demo_app/common_dependencies.dart';

import 'typography.dart';

class AppColors {
  // Style guide
  final Color background = const Color(0xFF020202);
  final Color foreground = const Color(0xFFFFFFFF);
  final Color primary = const Color(0xFF3456C8);
  final Color secondary = const Color(0xFF4B9BFF);
  final Color border = const Color(0x1AFFFFFF);
  final Color accent1 = const Color(0xFF38049F);
  final Color accent2 = const Color(0xFF06F7D3);
  final Color textPrimary = const Color(0xFFFFFFFF);
  final Color textSecondary = const Color(0xFFAAAAAA);

  // Legacy
  final Color primaryColor = const Color(0xFF3456C8);
  final Color secondaryColor = const Color(0xFFECEFF1);
  final Color cardColor = const Color(0xFFECEFF1);
  final Color hintColor = const Color(0xFF90A4AE);
  final Color dividerColor = const Color(0x1AFFFFFF);
  final Color bodyTextColor = const Color(0xFF263238);
  final Color buttonBackgroundColor = const Color(0xFFFFB300);
  final Color buttonForegroundColor = Colors.black87;
  final Color outlinedButtonColor = const Color(0xFF3456C8);
  final Color errorColor = const Color(0xFFD32F2F);
  final Color tabIndicatorColor = const Color(0xFFFFB300);
  final Color bottomNavSelectedColor = const Color(0xFFFFB300);
  final Color bottomNavUnselectedColor = const Color(0xFF90A4AE);
  final Color inputErrorBorderColor = const Color(0xFFD32F2F);
  final Color listTileIconColor = const Color(0xFF607D8B);
  final Color listTileTextColor = const Color(0xFF263238);
  final Color dialogBackgroundColor = Colors.white;
  final Color snackBarBackgroundColor = const Color(0xFFFFB300);
  final Color snackBarContentTextColor = Colors.black87;

  ThemeData toThemeData() {
    final textTheme = TextTheme(
      headlineLarge: AppTextStyle.heading.copyWith(color: textPrimary),
      headlineMedium: AppTextStyle.subheading.copyWith(color: textPrimary),
      headlineSmall: AppTextStyle.subheading.copyWith(color: textPrimary),
      titleLarge: AppTextStyle.title.copyWith(color: textPrimary),
      titleMedium: AppTextStyle.title.copyWith(color: textPrimary),
      titleSmall: AppTextStyle.title.copyWith(color: textPrimary),
      bodyLarge: AppTextStyle.bodyLarge.copyWith(color: textPrimary),
      bodyMedium: AppTextStyle.body.copyWith(color: textPrimary),
      bodySmall: AppTextStyle.bodySmall.copyWith(color: textPrimary),
    );

    return ThemeData(
      primarySwatch: Colors.grey,
      primaryColor: textPrimary,
      secondaryHeaderColor: secondaryColor,
      canvasColor: background,
      scaffoldBackgroundColor: Colors.transparent,
      cardColor: cardColor,
      hintColor: hintColor,
      dividerColor: dividerColor,
      iconTheme: IconThemeData(color: textPrimary),
      fontFamily: 'Figtree',
      textTheme: textTheme,
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        foregroundColor: textSecondary,
        titleTextStyle: AppTextStyle.title,
        iconTheme: IconThemeData(color: textSecondary),
        elevation: 0,
        centerTitle: true,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: foreground,
          iconColor: background,
          foregroundColor: buttonForegroundColor,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
          elevation: 2,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: outlinedButtonColor,
          side: BorderSide(color: outlinedButtonColor),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(50)),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
        ),
      ),
      cardTheme: CardThemeData(
        // elevation: 1.0,
        margin: const EdgeInsets.all(0),
        color: $styles.colors.foreground.withValues(alpha: 0.1),
        shadowColor: Colors.transparent,
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.0)),
      ),
      colorScheme: ColorScheme.fromSwatch(primarySwatch: Colors.grey)
          .copyWith(secondary: textPrimary, error: errorColor),
      tabBarTheme: TabBarThemeData(
        indicator: UnderlineTabIndicator(
          borderSide: BorderSide(color: $styles.colors.secondary, width: 2),
        ),
        labelColor: textPrimary,
        indicatorSize: TabBarIndicatorSize.tab,
        labelStyle: textTheme.bodyMedium,
        unselectedLabelColor: textSecondary,
        unselectedLabelStyle: textTheme.bodyMedium,
        dividerColor: Colors.transparent,
      ),
      navigationBarTheme: NavigationBarThemeData(
          backgroundColor: primary,
          labelTextStyle:
              WidgetStateProperty.all(TextStyle(fontWeight: FontWeight.w500)),
          labelBehavior: NavigationDestinationLabelBehavior.alwaysHide,
          iconTheme: WidgetStateProperty.all(
              IconThemeData(color: $styles.colors.textPrimary)),
          indicatorColor: Colors.transparent,
          overlayColor: WidgetStateProperty.all(Colors.transparent),
          indicatorShape: CircleBorder(
            side: BorderSide(
                width: 32,
                color: $styles.colors.textPrimary.withValues(alpha: 0.05),
                strokeAlign: BorderSide.strokeAlignCenter),
          )),
      inputDecorationTheme: InputDecorationTheme(
        border: OutlineInputBorder(
          borderRadius: $styles.corners.smRadius,
          borderSide: BorderSide(color: border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: $styles.corners.smRadius,
          borderSide: BorderSide(color: border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: $styles.corners.smRadius,
          borderSide: BorderSide(color: secondary, width: 1.5),
        ),
        iconColor: textSecondary,
        prefixIconColor: textSecondary,
        suffixIconColor: textSecondary,
        labelStyle: TextStyle(color: textSecondary),
        hintStyle: TextStyle(color: hintColor),
        errorBorder: OutlineInputBorder(
          borderRadius: $styles.corners.smRadius,
          borderSide: BorderSide(color: inputErrorBorderColor, width: 1.5),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: $styles.corners.smRadius,
          borderSide: BorderSide(color: inputErrorBorderColor, width: 2),
        ),
      ),
      listTileTheme: ListTileThemeData(
        iconColor: textPrimary,
        titleTextStyle: textTheme.bodyMedium,
        subtitleTextStyle:
            textTheme.bodySmall?.copyWith(color: $styles.colors.textSecondary),
        leadingAndTrailingTextStyle:
            textTheme.bodySmall?.copyWith(color: $styles.colors.textSecondary),
        contentPadding: EdgeInsets.all(12),
        minVerticalPadding: 0,
        minTileHeight: 0,
        horizontalTitleGap: 8,
        shape: Border(
          bottom: BorderSide(color: dividerColor, width: 1.0),
        ),
      ),
      expansionTileTheme: ExpansionTileThemeData(
        iconColor: $styles.colors.foreground,
        collapsedIconColor: $styles.colors.foreground,
        textColor: $styles.colors.textSecondary,
        collapsedTextColor: $styles.colors.textSecondary,
        tilePadding: EdgeInsets.all(16.0),
        shape: Border(
          bottom: BorderSide(color: Colors.transparent, width: 0),
        ),
      ),
      dialogTheme: DialogThemeData(
        titleTextStyle: TextStyle(
            color: listTileTextColor,
            fontWeight: FontWeight.bold,
            fontSize: 20),
        contentTextStyle: TextStyle(color: listTileTextColor),
        backgroundColor: dialogBackgroundColor,
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: snackBarBackgroundColor,
        contentTextStyle: TextStyle(color: snackBarContentTextColor),
        actionTextColor: snackBarContentTextColor,
        elevation: 4,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}
