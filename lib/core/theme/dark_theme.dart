import 'package:flutter/material.dart';
import '../constants/app_colors.dart';

final ThemeData darkTheme = ThemeData(
  brightness: Brightness.dark,
  scaffoldBackgroundColor: AppColors.background,
  primaryColor: AppColors.neonGreen,
  colorScheme: const ColorScheme.dark(
    primary: AppColors.neonGreen,
    surface: AppColors.surface,
    error: AppColors.expenseRed,
  ),
  useMaterial3: true,
  fontFamily: 'Roboto', // বা তোমার পছন্দের কোনো ফন্ট
);
