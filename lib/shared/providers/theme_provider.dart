import 'package:flutter/material.dart';
import 'package:zonix/core/utils/app_colors.dart';

class ThemeProvider extends ChangeNotifier {
  bool _isDarkMode = false;

  bool get isDarkMode => _isDarkMode;

  // El tema se detecta automáticamente del sistema
  void initializeTheme(BuildContext context) {
    _isDarkMode = MediaQuery.of(context).platformBrightness == Brightness.dark;
    notifyListeners();
  }

  // Ya no hay toggle manual, el tema sigue el sistema
  void updateTheme(BuildContext context) {
    final systemIsDark =
        MediaQuery.of(context).platformBrightness == Brightness.dark;
    if (_isDarkMode != systemIsDark) {
      _isDarkMode = systemIsDark;
      notifyListeners();
    }
  }

  // Colores dinámicos según tema
  Color get bgPrimary =>
      _isDarkMode ? AppColors.backgroundDark : AppColors.white;
  Color get bgSecondary =>
      _isDarkMode ? AppColors.grayDark : AppColors.grayLight;
  Color get textPrimary => _isDarkMode ? AppColors.white : AppColors.blueDark;
  Color get textSecondary => _isDarkMode ? Colors.white70 : AppColors.gray;
  Color get cardBg => _isDarkMode ? AppColors.grayDark : AppColors.white;
  Color get headerBg => _isDarkMode ? AppColors.blueDark : AppColors.blue;
  Color get borderColor =>
      _isDarkMode ? AppColors.grayDark : AppColors.grayLight;
}
