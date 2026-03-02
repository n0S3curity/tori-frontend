import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  // ---------------------------------------------------------------------------
  // Warm Olive palette (from Figma: text #4d4730 family)
  // ---------------------------------------------------------------------------
  static const Color olive50  = Color(0xFFF4F3EF);
  static const Color olive100 = Color(0xFFE5E2D7);
  static const Color olive200 = Color(0xFFCEC9B0);
  static const Color olive300 = Color(0xFFB4AD8A);
  static const Color olive400 = Color(0xFF9E9668);
  static const Color olive500 = Color(0xFF8A8150);
  static const Color olive600 = Color(0xFF7A7248);
  static const Color olive700 = Color(0xFF6B6340);
  static const Color olive800 = Color(0xFF5C5438);
  static const Color olive900 = Color(0xFF4D4730); // Figma primary text

  // ---------------------------------------------------------------------------
  // Amber palette (CTA / accent — #f18f01 from Figma)
  // ---------------------------------------------------------------------------
  static const Color amber100 = Color(0xFFFEF3C7);
  static const Color amber200 = Color(0xFFFDE68A);
  static const Color amber400 = Color(0xFFF5A623);
  static const Color amber500 = Color(0xFFF18F01); // Figma primary accent
  static const Color amber600 = Color(0xFFD97D00);
  static const Color amber700 = Color(0xFFB86D00);

  // Warm beige background (#ede6e3 from Figma)
  static const Color beige = Color(0xFFEDE6E3);

  // ---------------------------------------------------------------------------
  // Semantic tokens (light)
  // ---------------------------------------------------------------------------
  static const Color primary      = amber500;
  static const Color primaryLight = amber400;
  static const Color primaryDark  = amber600;

  /// Teal complement for secondary UI elements (e.g., "new clients" stat)
  static const Color secondary = Color(0xFF0D9488);

  static const Color background     = beige;
  static const Color surface        = Color(0xFFFFFFFF);
  static const Color surfaceVariant = Color(0xFFF5F1EE);

  /// rgba(77, 71, 48, 0.10) — Figma card borders
  static const Color border      = Color(0x1A4D4730);
  static const Color borderFocus = amber500;

  static const Color textPrimary   = olive900;                  // #4d4730
  static const Color textSecondary = Color(0x804D4730);         // rgba 50%
  static const Color textMuted     = Color(0x664D4730);         // rgba 40%
  static const Color textHint      = Color(0x4D4D4730);         // rgba 30%
  static const Color textDisabled  = Color(0x334D4730);         // rgba 20%
  static const Color textOnPrimary = Color(0xFFFFFFFF);

  static const Color success      = Color(0xFF10B981);
  static const Color successLight = Color(0xFFD1FAE5);
  static const Color successDark  = Color(0xFF065F46);

  static const Color warning      = amber500;
  static const Color warningLight = amber100;

  static const Color error      = Color(0xFFEF4444);
  static const Color errorLight = Color(0xFFFEE2E2);
  static const Color errorDark  = Color(0xFF991B1B);

  static const Color info      = Color(0xFF3B82F6);
  static const Color infoLight = Color(0xFFDBEAFE);

  // Appointment / registration status colors
  static const Color pendingBg     = amber100;
  static const Color pendingText   = amber700;
  static const Color approvedBg    = Color(0xFFD1FAE5);
  static const Color approvedText  = Color(0xFF065F46);
  static const Color rejectedBg    = Color(0xFFFEE2E2);
  static const Color rejectedText  = Color(0xFF991B1B);
  static const Color canceledBg    = Color(0xFFE5E2D7);
  static const Color canceledText  = Color(0xFF7A7248);
  static const Color completedBg   = Color(0xFFDBEAFE);
  static const Color completedText = Color(0xFF1E40AF);

  // Dark stat card (Figma — dark olive bg with amber numbers)
  static const Color statCardDark = olive900;

  // ---------------------------------------------------------------------------
  // Dark theme
  // ---------------------------------------------------------------------------
  static const Color backgroundDark     = Color(0xFF2C2618);
  static const Color surfaceDark        = Color(0xFF3D3726);
  static const Color surfaceVariantDark = Color(0xFF4D4730);
  static const Color borderDark         = Color(0xFF6B6340);
  static const Color textPrimaryDark    = Color(0xFFF4F3EF);
  static const Color textSecondaryDark  = Color(0xFFCEC9B0);

  // ---------------------------------------------------------------------------
  // Gradients
  // ---------------------------------------------------------------------------
  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [amber400, amber600],
  );

  static const LinearGradient splashGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [olive900, Color(0xFF2C2618)],
  );

  static const LinearGradient beigeGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [beige, Color(0xFFFFFFFF)],
  );
}
