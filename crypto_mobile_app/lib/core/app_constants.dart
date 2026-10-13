import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class AppConstants {
  AppConstants._();

 
static const String apiBaseUrl =
    'https://crypto-market-research-mobile-app.onrender.com/api';

}

class AppColors {
  AppColors._();

  static const accent = Color(0xFF7C5CFC);
  static const darkCanvas = Color(0xFF0B1020);
  static const lightCanvas = Color(0xFFF4F6FC);
  static bool _isLightMode = false;

  static bool get isLightMode => _isLightMode;

  static void setLightMode(bool value) {
    _isLightMode = value;
  }

  static Color get canvas => canvasFor(_isLightMode);
  static Color canvasFor(bool lightMode) =>
      lightMode ? lightCanvas : darkCanvas;
  static Color get card =>
      _isLightMode ? const Color(0xFFFFFFFF) : const Color(0xFF151D30);
  static Color get elevated =>
      _isLightMode ? const Color(0xFFEBEFF8) : const Color(0xFF1C2640);
  static Color get positive =>
      _isLightMode ? const Color(0xFF11865B) : const Color(0xFF22C993);
  static Color get negative =>
      _isLightMode ? const Color(0xFFD83D5B) : const Color(0xFFFF647C);
  static Color get primaryText =>
      _isLightMode ? const Color(0xFF171D2D) : const Color(0xFFF5F7FF);
  static Color get secondaryText =>
      _isLightMode ? const Color(0xFF69738A) : const Color(0xFF929CB5);
  static Color get border =>
      _isLightMode ? const Color(0xFFDCE2EE) : const Color(0xFF26314B);
}
