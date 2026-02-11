import 'package:flutter/material.dart';
import 'package:kakeibo/theme/app_colors.dart';

class AppGradients {
  const AppGradients._();

  static const primary = LinearGradient(
    colors: [AppColors.hotPink, AppColors.vividPurple],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const header = LinearGradient(
    colors: [AppColors.hotPink, Color(0xFFB02D9B), AppColors.vividPurple],
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
  );

  static const button = LinearGradient(
    colors: [AppColors.hotPink, AppColors.neonMagenta],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const card = LinearGradient(
    colors: [Color(0xFFFFF0F5), Color(0xFFFCE4F6)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const successCard = LinearGradient(
    colors: [Color(0xFFECFDF5), Color(0xFFD1FAE5)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const warningCard = LinearGradient(
    colors: [Color(0xFFFFFBEB), Color(0xFFFEF3C7)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const dangerCard = LinearGradient(
    colors: [Color(0xFFFEF2F2), Color(0xFFFEE2E2)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}
