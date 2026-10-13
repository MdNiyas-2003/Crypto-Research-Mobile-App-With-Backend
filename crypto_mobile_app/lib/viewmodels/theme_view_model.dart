import 'package:flutter/material.dart';

import '../core/app_constants.dart';

class ThemeViewModel extends ChangeNotifier {
  bool _isLightMode = false;

  bool get isLightMode => _isLightMode;

  void toggleTheme() => setLightMode(!_isLightMode);

  void setLightMode(bool value) {
    if (_isLightMode == value) return;
    _isLightMode = value;
    AppColors.setLightMode(value);
    notifyListeners();
  }
}
